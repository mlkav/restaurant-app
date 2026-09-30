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
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (!mounted) return;
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, _) {
            return TextField(
              controller: _searchController,
              autofocus: true,
              cursorColor: colorScheme.primary,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: InputBorder.none,
                suffixIcon: value.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          provider.clearSearch();
                        },
                      )
                    : null,
              ),
            );
          },
        ),
      ),
      body: SafeArea(child: _buildBody(provider)),
    );
  }

  // ================= BODY WRAPPER =================
  Widget _buildBody(RestaurantProvider provider) {
    final state = provider.searchResults;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: _buildBodyContent(provider, state),
          ),
        );
      },
    );
  }

  // ================= BODY CONTENT =================
  Widget _buildBodyContent(
    RestaurantProvider provider,
    ApiResponse<List<Restaurant>> state,
  ) {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState();
    }

    if (state is Loading<List<Restaurant>>) {
      return const Center(child: LoadingIndicator(message: 'Searching...'));
    }

    if (state is Success<List<Restaurant>>) {
      return _buildSearchResults(state.data, provider.searchQuery);
    }

    if (state is Error<List<Restaurant>>) {
      return ErrorDisplay(
        message: state.message,
        onRetry: () => provider.searchRestaurants(provider.searchQuery),
      );
    }

    return const SizedBox.shrink();
  }

  // ================= SEARCH RESULT =================
  Widget _buildSearchResults(List<Restaurant> restaurants, String query) {
    if (restaurants.isEmpty) {
      return _buildEmptyState(query: query);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
    );
  }

  // ================= EMPTY STATE =================
  Widget _buildEmptyState({String query = ''}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              query.isEmpty ? Icons.search : Icons.search_off,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              query.isEmpty
                  ? 'Search for restaurants'
                  : 'No results found for "$query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            if (query.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Try different keywords',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
