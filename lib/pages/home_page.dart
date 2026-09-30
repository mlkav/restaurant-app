import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/restaurant_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/restaurant_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final restaurantProvider = context.watch<RestaurantProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          // Theme icon
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: themeProvider.isDarkMode
                  ? const Icon(
                      Icons.light_mode,
                      key: ValueKey('light'),
                      color: Colors.amber,
                    )
                  : const Icon(
                      Icons.dark_mode,
                      key: ValueKey('dark'),
                      color: Color.fromARGB(255, 57, 59, 60),
                    ),
            ),
            onPressed: () {
              // Toggle theme
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
          ),
        ],
      ),
      body: _buildBody(context, restaurantProvider),
    );
  }

  Widget _buildBody(BuildContext context, RestaurantProvider provider) {
    final state = provider.restaurants;

    if (state is Loading<List<Restaurant>>) {
      return const LoadingIndicator(message: 'Loading restaurants...');
    } else if (state is Success<List<Restaurant>>) {
      return _buildRestaurantList(context, state.data);
    } else if (state is Error<List<Restaurant>>) {
      return ErrorDisplay(
        message: state.message,
        onRetry: () => provider.fetchRestaurants(),
      );
    }

    return Container();
  }

  Widget _buildRestaurantList(
    BuildContext context,
    List<Restaurant> restaurants,
  ) {
    if (restaurants.isEmpty) {
      return const Center(child: Text('No restaurants found'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<RestaurantProvider>().fetchRestaurants();
      },
      child: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 3,
        radius: const Radius.circular(8),
        child: ListView.builder(
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
