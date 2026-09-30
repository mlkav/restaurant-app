import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'pages/detail_page.dart';
import 'pages/home_page.dart';
import 'pages/review_page.dart';
import 'pages/search_page.dart';
import 'providers/restaurant_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Google Fonts
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
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final lightColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          );

          final darkColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Restaurant App',
            // Light
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightColorScheme,
              appBarTheme: AppBarTheme(
                backgroundColor: lightColorScheme.primary,
                foregroundColor: lightColorScheme.onPrimary,
                iconTheme: IconThemeData(color: lightColorScheme.onPrimary),
              ),
              // Google Fonts Light theme
              textTheme: GoogleFonts.poppinsTextTheme(
                ThemeData.light().textTheme,
              ),
            ),
            // Dark
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkColorScheme,
              appBarTheme: AppBarTheme(
                backgroundColor: darkColorScheme.primary,
                foregroundColor: darkColorScheme.onPrimary,
                iconTheme: IconThemeData(color: darkColorScheme.onPrimary),
              ),
              // Google Fonts Dark theme
              textTheme: GoogleFonts.poppinsTextTheme(
                ThemeData.dark().textTheme,
              ),
            ),
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const HomePage(),
              '/detail': (context) {
                final id = ModalRoute.of(context)!.settings.arguments as String;
                return DetailPage(restaurantId: id);
              },
              '/search': (context) => const SearchPage(),
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
