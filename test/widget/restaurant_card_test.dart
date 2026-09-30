import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/widgets/restaurant_card.dart';

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

  const dummyRestaurant = Restaurant(
    id: 'rq3v31su2kzfzo1v06',
    name: 'Melating Restaurant',
    description: 'Lorem ipsum dolor sit amet',
    pictureId: '14',
    city: 'Medan',
    rating: 4.2,
  );

  Widget createWidgetUnderTest({VoidCallback? onTap, Widget? trailing}) {
    return MaterialApp(
      home: Scaffold(
        body: RestaurantCard(
          restaurant: dummyRestaurant,
          onTap: onTap ?? () {},
          trailing: trailing,
        ),
      ),
    );
  }

  group('RestaurantCard Widget Tests', () {
    testWidgets('Merender nama, kota, dan rating restoran dengan benar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Melating Restaurant'), findsOneWidget);
      expect(find.text('Medan'), findsOneWidget);
      expect(find.text('4.2'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('Memanggil callback onTap saat kartu restoran ditekan',
        (WidgetTester tester) async {
      bool isTapped = false;

      await tester.pumpWidget(createWidgetUnderTest(onTap: () {
        isTapped = true;
      }));

      await tester.tap(find.byType(RestaurantCard));
      await tester.pump();

      expect(isTapped, isTrue);
    });

    testWidgets('Merender widget trailing jika disediakan',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        trailing: const Icon(Icons.favorite, key: Key('favorite_icon')),
      ));

      expect(find.byKey(const Key('favorite_icon')), findsOneWidget);
    });
  });
}
