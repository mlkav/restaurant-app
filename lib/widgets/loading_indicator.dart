import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
