import 'package:http/http.dart' as http;

http.Client createPinnedClient() =>
    throw UnsupportedError('Platform not supported');

bool isAllowedHost(String host) =>
    throw UnsupportedError('Platform not supported');
