import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/favorite_provider.dart';

import '../models/api_response.dart';
import '../models/restaurant.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_indicator.dart';

String get _imageBaseUrl => dotenv.get(
  'IMAGE_BASE_URL',
  fallback: 'https://restaurant-api.dicoding.dev/images',
);

class DetailPage extends StatefulWidget {
  final String restaurantId;
  const DetailPage({super.key, required this.restaurantId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RestaurantProvider>();
      provider.fetchRestaurantDetail(widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final state = provider.restaurantDetail;

    return Scaffold(
      body: _buildBody(context, state, provider),
      floatingActionButton: _buildFloatingActionButton(context, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ApiResponse<Restaurant> state,
    RestaurantProvider provider,
  ) {
    if (state is Loading<Restaurant>) {
      return const LoadingIndicator(message: 'Loading details...');
    } else if (state is Success<Restaurant>) {
      return _buildDetailContent(context, state.data);
    } else if (state is Error<Restaurant>) {
      return ErrorDisplay(
        message: state.message,
        onRetry: () => provider.fetchRestaurantDetail(widget.restaurantId),
      );
    }

    return Container();
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    ApiResponse<Restaurant> state,
  ) {
    if (state is Success<Restaurant>) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'btn_add_review',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/review',
                arguments: {'id': widget.restaurantId, 'name': state.data.name},
              );
            },
            child: const Icon(Icons.add_comment),
          ),
          const SizedBox(height: 16),
          // Favorite Button
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, _) {
              return FloatingActionButton(
                heroTag: 'btn_toggle_favorite',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);

                  await favoriteProvider.toggleFavorite(state.data);

                  final isFavorite = await favoriteProvider.isFavorite(
                    state.data.id,
                  );

                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite
                            ? 'Added to favorites!'
                            : 'Removed from favorites',
                      ),
                      backgroundColor: isFavorite ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                backgroundColor: Colors.pink,
                child: FutureBuilder<bool>(
                  future: favoriteProvider.isFavorite(state.data.id),
                  builder: (context, snapshot) {
                    final isFavorite = snapshot.data ?? false;
                    return Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    );
                  },
                ),
              );
            },
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildDetailContent(BuildContext context, Restaurant restaurant) {
    return CustomScrollView(
      primary: true,
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'restaurant-image-${restaurant.id}',
              child: Image.network(
                '$_imageBaseUrl/medium/${restaurant.pictureId}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            title: Hero(
              tag: 'restaurant-name-${restaurant.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  restaurant.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating dan City
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toString(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.city,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Address
                  if (restaurant.address != null &&
                      restaurant.address!.isNotEmpty) ...[
                    Text(
                      'Address',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(restaurant.address!),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(restaurant.description),
                  const SizedBox(height: 24),

                  // Menus
                  _buildMenusSection(context, restaurant),
                  const SizedBox(height: 24),

                  // Reviews
                  _buildReviewsSection(context, restaurant),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildMenusSection(BuildContext context, Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menus',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Foods
        if (restaurant.menus?.foods != null &&
            restaurant.menus!.foods.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Foods', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  primary: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: restaurant.menus!.foods.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.restaurant, size: 16),
                              const SizedBox(width: 8),
                              Text(restaurant.menus!.foods[index].name),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

        // Drinks
        if (restaurant.menus?.drinks != null &&
            restaurant.menus!.drinks.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Drinks', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  primary: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: restaurant.menus!.drinks.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_drink, size: 16),
                              const SizedBox(width: 8),
                              Text(restaurant.menus!.drinks[index].name),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context, Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Reviews',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (restaurant.customerReviews != null) ...[
              const SizedBox(width: 8),
              Chip(
                label: Text('${restaurant.customerReviews!.length}'),
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (restaurant.customerReviews == null ||
            restaurant.customerReviews!.isEmpty)
          const Text('No reviews yet. Be the first to review!')
        else
          Column(
            children: restaurant.customerReviews!.map((review) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              review.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            review.date,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(review.review),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
