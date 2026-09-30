// lib/pages/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/api_response.dart';
import '../models/restaurant.dart';
import '../providers/favorite_provider.dart';
import '../widgets/restaurant_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoriteProvider>();
    final favorites = provider.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Restaurants')),
      body: _buildBody(favorites),
    );
  }

  Widget _buildBody(ApiResponse<List<Restaurant>> state) {
    if (state is Loading<List<Restaurant>>) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is Error<List<Restaurant>>) {
      return _buildError(state.message);
    }

    if (state is Success<List<Restaurant>>) {
      return _buildFavoritesList(state.data);
    }

    return const SizedBox.shrink();
  }

  // ================= ERROR STATE =================
  Widget _buildError(String message) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load favorites',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      context.read<FavoriteProvider>().loadFavorites();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= LIST =================
  Widget _buildFavoritesList(List<Restaurant> restaurants) {
    if (restaurants.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];

        return Dismissible(
          key: Key(restaurant.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Theme.of(context).colorScheme.error,
            child: const Icon(Icons.delete, color: Colors.white),
          ),

          confirmDismiss: (_) {
            return _showDeleteConfirmation(context, restaurant.name);
          },

          onDismissed: (_) async {
            final provider = context.read<FavoriteProvider>();
            final messenger = ScaffoldMessenger.of(context);

            await provider.removeFavorite(restaurant.id);

            if (!mounted) return;

            messenger.showSnackBar(
              SnackBar(
                content: Text('${restaurant.name} removed from favorites'),
              ),
            );
          },

          child: RestaurantCard(
            restaurant: restaurant,
            onTap: () {
              Navigator.pushNamed(context, '/detail', arguments: restaurant.id);
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final provider = context.read<FavoriteProvider>();
                final messenger = ScaffoldMessenger.of(context);

                final confirmed = await _showDeleteConfirmation(
                  context,
                  restaurant.name,
                );

                if (!mounted || confirmed != true) return;

                await provider.removeFavorite(restaurant.id);

                messenger.showSnackBar(
                  SnackBar(content: Text('${restaurant.name} removed')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height -
            kToolbarHeight -
            MediaQuery.of(context).padding.top,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_border, size: 80),
                const SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the heart icon on any restaurant to add it to your favorites',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= DIALOG =================
  Future<bool?> _showDeleteConfirmation(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove from favorites?'),
          content: Text(
            'Are you sure you want to remove "$name" from favorites?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('REMOVE'),
            ),
          ],
        );
      },
    );
  }
}
