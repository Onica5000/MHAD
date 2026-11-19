import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'lock_crypto.dart';

/// What a locked copy or file says it is.
const String kLockedFormat = 'pa-mhad-locked';
const int kLockedFormatVersion = 1;

/// PBKDF2-HMAC-SHA-256 rounds: OWASP's recommended setting (the figure the
/// owner was shown, 2026-11-18). Each header records its own rounds, so this
/// can be raised later without breaking copies or files made before.
const int kLockIterations = 600000;

const int _saltBytes = 16;
const int _nonceBytes = 12;

/// The in-browser copy expires; a downloaded file doesn't.
enum LockedKind { copy, file }

/// The readable label of a locked copy or file: format, version, how the key
/// was made, the nonce, the kind and (for a copy) when it expires. It is
/// sealed into the encryption as additional data — change anything in it
/// (say, push the expiry back) and the copy can no longer be opened.
class LockedHeader {
  LockedHeader({
    required this.iterations,
    required this.salt,
    required this.nonce,
    required this.kind,
    this.expires,
    this.saved,
  });

  final int iterations;
  final Uint8List salt;
  final Uint8List nonce;
  final LockedKind kind;

  /// When an in-browser copy stops being usable (UTC); null for files.
  final DateTime? expires;

  /// When the copy was last saved (UTC) — shown on the resume screen before
  /// unlocking; null for files.
  final DateTime? saved;

  /// Fixed key order: [aad] is these exact bytes.
  Map<String, Object> toJson() => {
        'format': kLockedFormat,
        'v': kLockedFormatVersion,
        'kdf': {
          'name': 'PBKDF2',
          'hash': 'SHA-256',
          'iterations': iterations,
          'salt': base64Encode(salt),
        },
        'cipher': {'name': 'AES-GCM', 'nonce': base64Encode(nonce)},
        'kind': kind.name,
        if (expires != null) 'expires': expires!.millisecondsSinceEpoch,
        if (saved != null) 'saved': saved!.millisecondsSinceEpoch,
      };

  /// The additional authenticated data: the header as written.
  Uint8List get aad => Uint8List.fromList(utf8.encode(jsonEncode(toJson())));

  /// Null unless [j] is a locked header this version can read.
  static LockedHeader? fromJson(Map<String, dynamic> j) {
    if (j['format'] != kLockedFormat || j['v'] != kLockedFormatVersion) {
      return null;
    }
    final kdf = j['kdf'];
    final cipher = j['cipher'];
    if (kdf is! Map ||
        kdf['name'] != 'PBKDF2' ||
        kdf['hash'] != 'SHA-256' ||
        cipher is! Map ||
        cipher['name'] != 'AES-GCM') {
      return null;
    }
    final kind = LockedKind.values.asNameMap()[j['kind']];
    final iterations = kdf['iterations'];
    final expires = j['expires'];
    final saved = j['saved'];
    if (kind == null || iterations is! int || iterations < 1) return null;
    if ((expires != null && expires is! int) ||
        (saved != null && saved is! int)) {
      return null;
    }
    return LockedHeader(
      iterations: iterations,
      salt: base64Decode(kdf['salt'] as String),
      nonce: base64Decode(cipher['nonce'] as String),
      kind: kind,
      expires: _utc(expires as int?),
      saved: _utc(saved as int?),
    );
  }
}

DateTime? _utc(int? ms) =>
    ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

/// A locked copy or file: the header plus the sealed (gzipped) payload.
class LockedBlob {
  const LockedBlob(this.header, this.sealed);
  final LockedHeader header;
  final Uint8List sealed;

  String encode() =>
      jsonEncode({...header.toJson(), 'data': base64Encode(sealed)});

  /// Null when [text] isn't a locked MHAD copy or file this version reads
  /// (an older .mhad file, for instance).
  static LockedBlob? tryParse(String text) {
    try {
      final j = jsonDecode(text);
      if (j is! Map<String, dynamic>) return null;
      final header = LockedHeader.fromJson(j);
      final data = j['data'];
      if (header == null || data is! String) return null;
      return LockedBlob(header, base64Decode(data));
    } catch (_) {
      return null;
    }
  }
}

/// A passphrase turned into a key, held in memory while the person works.
class LockSession {
  LockSession._(this.key, this.salt, this.iterations);
  final LockKey key;
  final Uint8List salt;
  final int iterations;

  /// A new passphrase: a fresh random salt, then the key.
  static Future<LockSession> create(LockCrypto crypto, String passphrase,
      {int iterations = kLockIterations}) async {
    final salt = _randomBytes(_saltBytes);
    return LockSession._(
        await crypto.deriveKey(passphrase, salt, iterations), salt, iterations);
  }

  /// The key for an existing copy or file, from its own salt and rounds.
  static Future<LockSession> forHeader(
          LockCrypto crypto, String passphrase, LockedHeader header) async =>
      LockSession._(
          await crypto.deriveKey(passphrase, header.salt, header.iterations),
          header.salt,
          header.iterations);
}

/// Locks [payload] (anything JSON-encodable): gzip, then AES-256-GCM under a
/// fresh random nonce, with the header as additional data.
Future<LockedBlob> sealPayload(
  LockCrypto crypto,
  LockSession session,
  Object? payload, {
  required LockedKind kind,
  DateTime? expires,
  DateTime? saved,
}) async {
  final header = LockedHeader(
    iterations: session.iterations,
    salt: session.salt,
    nonce: _randomBytes(_nonceBytes),
    kind: kind,
    expires: expires?.toUtc(),
    saved: saved?.toUtc(),
  );
  final plain = Uint8List.fromList(
      GZipEncoder().encode(utf8.encode(jsonEncode(payload))));
  return LockedBlob(
      header, await crypto.seal(session.key, header.nonce, plain, header.aad));
}

/// Opens [blob]. Throws [LockOpenException] on a wrong passphrase or when
/// anything in the blob was changed.
Future<Object?> openPayload(
    LockCrypto crypto, LockSession session, LockedBlob blob) async {
  final plain = await crypto.open(
      session.key, blob.header.nonce, blob.sealed, blob.header.aad);
  try {
    return jsonDecode(utf8.decode(GZipDecoder().decodeBytes(plain)));
  } catch (_) {
    throw const LockOpenException();
  }
}

final Random _random = Random.secure();

Uint8List _randomBytes(int n) =>
    Uint8List.fromList(List<int>.generate(n, (_) => _random.nextInt(256)));
