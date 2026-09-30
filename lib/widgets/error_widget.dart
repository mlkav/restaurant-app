import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorDisplay({super.key, required this.message, required this.onRetry});

  String _getUserFriendlyMessage() {
    if (message.contains('Failed host lookup') ||
        message.contains('SocketException') ||
        message.contains('No address associated with hostname')) {
      return 'Unable to connect to the server. Please check your internet connection and try again.';
    } else if (message.contains('timeout') || message.contains('Timeout')) {
      return 'The request is taking too long. Please check your connection and try again.';
    } else if (message.contains('404') || message.contains('Not Found')) {
      return 'The requested content was not found.';
    } else if (message.contains('500') ||
        message.contains('Internal Server Error')) {
      return 'Server is experiencing issues. Please try again later.';
    } else {
      return 'Unable to load data. Please check your connection and try again.';
    }
  }

  IconData _getErrorIcon() {
    if (message.contains('Failed host lookup') ||
        message.contains('SocketException') ||
        message.contains('No address associated with hostname')) {
      return Icons.wifi_off;
    } else if (message.contains('404') || message.contains('Not Found')) {
      return Icons.search_off;
    } else if (message.contains('500')) {
      return Icons.cloud_off;
    } else {
      return Icons.error_outline;
    }
  }

  String _getErrorTitle() {
    if (message.contains('Failed host lookup') ||
        message.contains('SocketException')) {
      return 'Connection Error';
    } else if (message.contains('404')) {
      return 'Not Found';
    } else if (message.contains('500')) {
      return 'Server Error';
    } else {
      return 'Something Went Wrong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userMessage = _getUserFriendlyMessage();
    final errorIcon = _getErrorIcon();
    final errorTitle = _getErrorTitle();
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(errorIcon, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              errorTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              userMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.orange[700],
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 100,
                    ),
                    child: Text(
                      'Make sure you have an active internet connection',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
