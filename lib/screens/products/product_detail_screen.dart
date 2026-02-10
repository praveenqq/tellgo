import 'package:flutter/material.dart';
import 'package:tellgo_app/theme/app_theme.dart';
import 'package:tellgo_app/widgets/app_button.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            AppBar(
              backgroundColor: AppTheme.backgroundColor,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppTheme.textPrimary),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {},
                ),
              ],
            ),
            // Product Image
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      color: AppTheme.surfaceColor,
                      child: const Icon(
                        Icons.image,
                        size: 100,
                        color: AppTheme.textHint,
                      ),
                    ),
                    // Product Info
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Name $productId',
                            style: AppTheme.headingLarge,
                          ),
                          const SizedBox(height: AppTheme.spacing8),
                          Row(
                            children: [
                              Text(
                                '\$99.99',
                                style: AppTheme.headingMedium.copyWith(
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacing16),
                              Text(
                                '\$149.99',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing12,
                                  vertical: AppTheme.spacing4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGreen.withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusSmall),
                                ),
                                child: Text(
                                  '33% OFF',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.accentGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing24),
                          const Divider(),
                          const SizedBox(height: AppTheme.spacing24),
                          Text(
                            'Description',
                            style: AppTheme.headingSmall,
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          Text(
                            'This is a detailed description of the product. '
                            'It includes all the features and benefits that '
                            'make this product amazing and worth purchasing.',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing24),
                          Text(
                            'Specifications',
                            style: AppTheme.headingSmall,
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          _SpecificationRow(
                            label: 'Brand',
                            value: 'Tellgo',
                          ),
                          _SpecificationRow(
                            label: 'Weight',
                            value: '500g',
                          ),
                          _SpecificationRow(
                            label: 'Dimensions',
                            value: '10 x 10 x 5 cm',
                          ),
                          _SpecificationRow(
                            label: 'Warranty',
                            value: '1 Year',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderColor),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.remove, size: 20),
                        const SizedBox(width: AppTheme.spacing16),
                        Text('1', style: AppTheme.bodyLarge),
                        const SizedBox(width: AppTheme.spacing16),
                        const Icon(Icons.add, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: AppButton(
                      text: 'Add to Cart',
                      onPressed: () {
                        // Handle add to cart
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product added to cart'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecificationRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecificationRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

