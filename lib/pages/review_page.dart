import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/restaurant_provider.dart';
import '../models/api_response.dart';

class ReviewPage extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const ReviewPage({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<RestaurantProvider>();

    await provider.addReview(
      id: widget.restaurantId,
      name: _nameController.text.trim(),
      review: _reviewController.text.trim(),
    );

    final state = provider.addReviewState;

    if (!mounted) return;

    if (state is Success<void>) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }

    if (state is Error<void>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final isLoading = provider.addReviewState is Loading<void>;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Review')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(widget.restaurantName,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reviewController,
                decoration: const InputDecoration(labelText: 'Review'),
                maxLines: 4,
                validator: (v) =>
                    v == null || v.length < 10 ? 'Min 10 chars' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitReview,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
