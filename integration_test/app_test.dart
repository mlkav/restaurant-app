import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/pages/detail_page.dart';
import 'package:restaurant_app/pages/main_page.dart';

import 'package:restaurant_app/providers/favorite_provider.dart';
import 'package:restaurant_app/providers/navigation_provider.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/providers/scheduling_provider.dart';
import 'package:restaurant_app/providers/theme_provider.dart';
import 'package:restaurant_app/widgets/restaurant_card.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  const mockListJson = '''
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

  const mockDetailJson = '''
  {
    "error": false,
    "message": "success",
    "restaurant": {
      "id": "rq3v31su2kzfzo1v06",
      "name": "Melating Restaurant",
      "description": "Restoran nyaman di pusat kota Medan",
      "city": "Medan",
      "address": "Jln. Pandu No. 12",
      "pictureId": "14",
      "rating": 4.2,
      "categories": [{"name": "Modern"}],
      "menus": {
        "foods": [{"name": "Nasi Goreng"}],
        "drinks": [{"name": "Es Teh"}]
      },
      "customerReviews": [
        {
          "name": "Ahmad",
          "review": "Makanan sangat enak!",
          "date": "13 November 2023"
        }
      ]
    }
  }
  ''';

  group('End-to-End Integration Tests', () {
    testWidgets(
        'User dapat memuat halaman utama, membuka detail restoran, dan melihat informasinya',
        (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        final url = request.url.toString();
        if (url.endsWith('/list')) {
          return http.Response(mockListJson, 200);
        } else if (url.contains('/detail/')) {
          return http.Response(mockDetailJson, 200);
        }
        return http.Response('Not Found', 404);
      });

      final restaurantProvider = RestaurantProvider(client: mockClient, autoFetch: true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider.value(value: restaurantProvider),
            ChangeNotifierProvider(create: (_) => FavoriteProvider()),
            ChangeNotifierProvider(create: (_) => NavigationProvider()),
            ChangeNotifierProvider(create: (_) => SchedulingProvider()),
          ],
          child: MaterialApp(
            initialRoute: '/',
            routes: {
              '/': (_) => const MainPage(),
              '/detail': (context) {
                final id = ModalRoute.of(context)!.settings.arguments as String;
                return DetailPage(restaurantId: id);
              },
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi Halaman Utama memuat restoran
      expect(find.text('Restaurant App'), findsOneWidget);
      expect(find.text('Melating Restaurant'), findsOneWidget);
      expect(find.text('Medan'), findsOneWidget);

      // Tap kartu restoran untuk masuk ke Detail
      await tester.tap(find.byType(RestaurantCard).first);
      await tester.pumpAndSettle();

      // Verifikasi Halaman Detail memuat informasi asli restoran
      expect(find.text('Restoran nyaman di pusat kota Medan'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Menus'), findsOneWidget);
      expect(find.text('Nasi Goreng'), findsOneWidget);
      expect(find.text('Es Teh'), findsOneWidget);
    });
  });
}
