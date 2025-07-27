import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/model/restaurant_detail_response.dart';
import 'package:restaurant_app/provider/detail/restaurant_detail_provider.dart';
import 'package:restaurant_app/static/restaurant_detail_result_state.dart';

class CustomerReviewWidget extends StatefulWidget {
  final RestaurantDetail restaurantDetail;
  const CustomerReviewWidget({super.key, required this.restaurantDetail});

  @override
  State<CustomerReviewWidget> createState() => _CustomerReviewWidgetState();
}

class _CustomerReviewWidgetState extends State<CustomerReviewWidget> {
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitReview(BuildContext context) async {
    final provider = Provider.of<RestaurantDetailProvider>(
      context,
      listen: false,
    );

    if (_formKey.currentState!.validate()) {
      provider.setSubmitting(true);
      try {
        await provider.addReview(
          widget.restaurantDetail.id,
          _nameController.text,
          _reviewController.text,
        );

        _nameController.clear();
        _reviewController.clear();
        _showSnackBar('Review berhasil dikirim!', Colors.green);
      } catch (_) {
        _showSnackBar('Gagal mengirim review', Colors.red);
      } finally {
        provider.setSubmitting(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantDetailProvider>(
      builder: (context, provider, _) {
        final state = provider.resultState;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Review
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Customer Reviews",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.restaurantDetail.rating}/5",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Review List
            if (state is RestaurantDetailLoadingState)
              const Center(child: CircularProgressIndicator())
            else if (state is RestaurantDetailErrorState)
              Center(child: Text('Error: ${state.error}'))
            else if (state is RestaurantDetailLoadedState)
              state.data.customerReviews.isEmpty
                  ? const Center(child: Text("No reviews available."))
                  : Column(
                    children:
                        state.data.customerReviews.map((review) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        review.review,
                                        textAlign: TextAlign.justify,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  review.date,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  )
            else
              const Center(child: Text("No data available.")),

            const SizedBox(height: 24),

            // Form Review
            Text(
              "Tambah Review",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nama",
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? "Nama wajib diisi"
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      labelText: "Ulasan",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? "Ulasan wajib diisi"
                                : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed:
                        provider.isSubmitting
                            ? null
                            : () => _submitReview(context),
                    child:
                        provider.isSubmitting
                            ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text("Kirim Review"),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
