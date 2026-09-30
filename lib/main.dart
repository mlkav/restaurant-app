import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/pages/main_page.dart';

import 'reminder/reminder_service.dart';
import 'pages/detail_page.dart';
import 'pages/review_page.dart';
import 'providers/favorite_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/scheduling_provider.dart';
import 'providers/theme_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(
    fileName: ".env",
    isOptional: true,
    mergeWith: {
      'BASE_URL': 'https://restaurant-api.dicoding.dev',
      'IMAGE_BASE_URL': 'https://restaurant-api.dicoding.dev/images',
    },
  );

  await ReminderService.instance.init(navigatorKey);
  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => SchedulingProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Restaurant App',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: GoogleFonts.poppins().fontFamily,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
                brightness: Brightness.light,
              ),
            ),

            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: GoogleFonts.poppins().fontFamily,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
                brightness: Brightness.dark,
              ),
            ),

            initialRoute: '/',
            routes: {
              '/': (_) => const MainPage(),
              '/detail': (context) {
                final id = ModalRoute.of(context)!.settings.arguments as String;
                return DetailPage(restaurantId: id);
              },
              '/review': (context) {
                final args = ModalRoute.of(context)!.settings.arguments as Map;
                return ReviewPage(
                  restaurantId: args['id'],
                  restaurantName: args['name'],
                );
              },
            },
          );
        },
      ),
    );
  }
}
