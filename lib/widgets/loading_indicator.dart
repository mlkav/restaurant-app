// lib/widgets/loading_indicator.dart

import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colorScheme.primary,
            backgroundColor: colorScheme.surfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: colorScheme.onBackground)),
        ],
      ),
    );
  }
}
