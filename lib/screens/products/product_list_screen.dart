import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tellgo_app/theme/app_theme.dart';
import 'package:tellgo_app/widgets/product_card.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Products',
          style: AppTheme.headingSmall.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textHint,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textSecondary,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.filter_list,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {},
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing16,
                  ),
                ),
              ),
            ),
          ),
          // Product grid/list
          ProductCard(
            title: 'Product 1',
            subtitle: 'Amazing product description',
            price: '\$29.99',
            onTap: () {
              context.push('/product/1');
            },
          ),
          ProductCard(
            title: 'Product 2',
            subtitle: 'Another great product',
            price: '\$49.99',
            onTap: () {
              context.push('/product/2');
            },
          ),
          ProductCard(
            title: 'Product 3',
            subtitle: 'Premium quality item',
            price: '\$79.99',
            onTap: () {
              context.push('/product/3');
            },
          ),
          ProductCard(
            title: 'Product 4',
            subtitle: 'Best seller product',
            price: '\$99.99',
            onTap: () {
              context.push('/product/4');
            },
          ),
          ProductCard(
            title: 'Product 5',
            subtitle: 'New arrival',
            price: '\$39.99',
            onTap: () {
              context.push('/product/5');
            },
          ),
        ],
      ),
    );
  }
}
