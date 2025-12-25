import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Restaurant App',
            theme: ThemeData.light().copyWith(
              primaryColor: Colors.green,
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: Colors.green,
                secondary: Colors.blue,
              ),
              appBarTheme: const AppBarTheme(
                color: Colors.green,
                iconTheme: IconThemeData(color: Colors.white),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: Colors.green,
              appBarTheme: const AppBarTheme(
                color: Colors.green,
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
