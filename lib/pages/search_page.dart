import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/api_response.dart';
import '../models/restaurant.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/restaurant_card.dart';

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
      final query = _searchController.text.trim();
      final provider = context.read<RestaurantProvider>();
      if (query.isNotEmpty) {
        provider.searchRestaurants(query);
      } else {
        provider.clearSearch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search restaurants...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black),
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
    final state = provider.searchResults;

    if (_searchController.text.isEmpty) {
      return _buildEmptyState();
    }

    if (state is Loading<List<Restaurant>>) {
      return const Center(child: LoadingIndicator(message: 'Searching...'));
    } else if (state is Success<List<Restaurant>>) {
      return _buildSearchResults(state.data, provider.searchQuery);
    } else if (state is Error<List<Restaurant>>) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: ErrorDisplay(
            message: state.message,
            onRetry: () => provider.searchRestaurants(provider.searchQuery),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSearchResults(List<Restaurant> restaurants, String query) {
    if (restaurants.isEmpty) {
      return _buildEmptyState(query: query);
    }

    return Scrollbar(
      thumbVisibility: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return RestaurantCard(
            restaurant: restaurant,
            onTap: () {
              Navigator.pushNamed(context, '/detail', arguments: restaurant.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({String query = ''}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                query.isEmpty ? Icons.search : Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                query.isEmpty
                    ? 'Search for restaurants'
                    : 'No results found for "$query"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if (query.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Try different keywords',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
