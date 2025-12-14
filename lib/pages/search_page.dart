import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';
import '../models/api_response.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        final provider = context.read<RestaurantProvider>();
        provider.searchRestaurants(_searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search restaurants...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      provider.clearSearch();
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(RestaurantProvider provider) {
    if (_searchController.text.isEmpty) {
      return const Center(
        child: Text('Type to search restaurants'),
      );
    }

    final state = provider.searchResults;

    if (state is Loading<List<Restaurant>>) {
      return const LoadingIndicator(message: 'Searching...');
    } else if (state is Success<List<Restaurant>>) {
      return _buildSearchResults(state.data, provider.searchQuery);
    } else if (state is Error<List<Restaurant>>) {
      return ErrorDisplay(
        message: state.message,
        onRetry: () => provider.searchRestaurants(provider.searchQuery),
      );
    }

    return Container();
  }

  Widget _buildSearchResults(List<Restaurant> restaurants, String query) {
    if (restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No results found for "$query"'),
          ],
        ),
      );
    }

    return ListView.builder(
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
    );
  }
}
