import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mhad/services/geo_service.dart';

void main() {
  group('GeoService', () {
    test('lookupZip parses city / state / lat / lng', () async {
      final client = MockClient((req) async {
        expect(req.url.toString(), contains('zippopotam.us/us/19103'));
        return http.Response(
          '{"places":[{"place name":"Philadelphia","state":"Pennsylvania",'
          '"state abbreviation":"PA","latitude":"39.9513",'
          '"longitude":"-75.1741"}]}',
          200,
        );
      });
      final z = await GeoService(client: client).lookupZip('19103');
      expect(z, isNotNull);
      expect(z!.city, 'Philadelphia');
      expect(z.stateAbbr, 'PA');
      expect(z.lat, closeTo(39.9513, 0.001));
      expect(z.lng, closeTo(-75.1741, 0.001));
    });

    test('lookupZip rejects non-5-digit input without a network call', () async {
      var called = false;
      final client = MockClient((req) async {
        called = true;
        return http.Response('', 200);
      });
      final z = await GeoService(client: client).lookupZip('123');
      expect(z, isNull);
      expect(called, isFalse);
    });

    test('countyForLatLng parses the county name', () async {
      final client = MockClient((req) async {
        expect(req.url.host, 'geo.fcc.gov');
        return http.Response(
          '{"County":{"FIPS":"42101","name":"Philadelphia"},'
          '"State":{"code":"PA"}}',
          200,
        );
      });
      final county =
          await GeoService(client: client).countyForLatLng(39.95, -75.17);
      expect(county, 'Philadelphia');
    });

    test('errors return null (fail-safe)', () async {
      final client = MockClient((req) async => http.Response('boom', 500));
      final geo = GeoService(client: client);
      expect(await geo.lookupZip('19103'), isNull);
      expect(await geo.countyForLatLng(1, 2), isNull);
    });
  });
}
