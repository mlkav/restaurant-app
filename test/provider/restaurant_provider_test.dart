import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:restaurant_app/models/api_response.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(
      fileName: ".env",
      isOptional: true,
      mergeWith: {
        'BASE_URL': 'https://restaurant-api.dicoding.dev',
        'IMAGE_BASE_URL': 'https://restaurant-api.dicoding.dev/images',
      },
    );
  });

  group('RestaurantProvider Unit Tests', () {
    test('State awal RestaurantProvider harus Loading', () {
      final provider = RestaurantProvider(
        client: MockClient((_) async => http.Response('{}', 200)),
        autoFetch: false,
      );

      expect(provider.restaurants, isA<Loading<List<Restaurant>>>());
    });

    test('Mengembalikan daftar restoran (Success) saat API call berhasil (200)', () async {
      const mockJson = '''
      {
        "error": false,
        "message": "success",
        "count": 1,
        "restaurants": [
          {
            "id": "rq3v31su2kzfzo1v06",
            "name": "Melating Restaurant",
            "description": "Lorem ipsum dolor sit amet",
            "pictureId": "14",
            "city": "Medan",
            "rating": 4.2
          }
        ]
      }
      ''';

      final client = MockClient((request) async {
        if (request.url.toString() == '${dotenv.get('BASE_URL')}/list') {
          return http.Response(mockJson, 200);
        }
        return http.Response('Not Found', 404);
      });

      final provider = RestaurantProvider(client: client, autoFetch: false);

      await provider.fetchRestaurants();

      expect(provider.restaurants, isA<Success<List<Restaurant>>>());
      final result = (provider.restaurants as Success<List<Restaurant>>).data;
      expect(result.length, 1);
      expect(result.first.name, 'Melating Restaurant');
      expect(result.first.city, 'Medan');
    });

    test('Mengembalikan Error state/message saat API call gagal (500)', () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final provider = RestaurantProvider(client: client, autoFetch: false);

      await provider.fetchRestaurants();

      expect(provider.restaurants, isA<Error<List<Restaurant>>>());
      final errorMessage = (provider.restaurants as Error<List<Restaurant>>).message;
      expect(errorMessage, contains('Failed (500)'));
    });

    test('Mengembalikan Error state saat terjadi kesalahan jaringan (exception)', () async {
      final client = MockClient((request) async {
        throw Exception('Failed to connect');
      });

      final provider = RestaurantProvider(client: client, autoFetch: false);

      await provider.fetchRestaurants();

      expect(provider.restaurants, isA<Error<List<Restaurant>>>());
      final errorMessage = (provider.restaurants as Error<List<Restaurant>>).message;
      expect(errorMessage, contains('Network error'));
    });
  });
}
