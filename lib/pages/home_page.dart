// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/api_response.dart';
import '../models/restaurant.dart';
import '../providers/restaurant_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/restaurant_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _requestNotificationPermission() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final restaurantProvider = context.watch<RestaurantProvider>();

    return WillPopScope(
      onWillPop: () => _showExitConfirmation(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Restaurant App'),
          actions: [
            IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () {
                themeProvider.toggleTheme(!themeProvider.isDarkMode);
              },
              tooltip: themeProvider.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
            ),
          ],
        ),
        body: _buildBody(restaurantProvider),
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Keluar Aplikasi?'),
              content: const Text(
                'Apakah kamu yakin ingin keluar dari aplikasi?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Keluar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _buildBody(RestaurantProvider provider) {
    final state = provider.restaurants;

    if (state is Loading<List<Restaurant>>) {
      return const LoadingIndicator(message: 'Loading restaurants...');
    } else if (state is Success<List<Restaurant>>) {
      return _buildRestaurantList(state.data);
    } else if (state is Error<List<Restaurant>>) {
      return ErrorDisplay(
        message: state.message,
        onRetry: () => provider.fetchRestaurants(),
      );
    }

    return const SizedBox();
  }

  Widget _buildRestaurantList(List<Restaurant> restaurants) {
    if (restaurants.isEmpty) {
      return const Center(child: Text('No restaurants found'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<RestaurantProvider>().fetchRestaurants();
      },
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 3,
        radius: const Radius.circular(8),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return RestaurantCard(
              restaurant: restaurant,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: restaurant.id,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
