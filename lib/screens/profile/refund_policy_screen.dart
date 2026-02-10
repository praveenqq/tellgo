import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tellgo_app/theme/app_theme.dart';

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Return & Refund Policy',
          style: AppTheme.headingMedium.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Return Policy',
              style: AppTheme.headingSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              'You have 30 days to return an item from the date you received it. To be eligible for a return, your item must be unused and in the same condition that you received it.',
              style: AppTheme.bodyMedium.copyWith(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              'Refund Policy',
              style: AppTheme.headingSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              'Once we receive your item, we will inspect it and notify you that we have received your returned item. We will immediately notify you on the status of your refund after inspecting the item.',
              style: AppTheme.bodyMedium.copyWith(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              'If your return is approved, we will initiate a refund to your credit card (or original method of payment). You will receive the credit within a certain amount of days, depending on your card issuer\'s policies.',
              style: AppTheme.bodyMedium.copyWith(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              'Contact Us',
              style: AppTheme.headingSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              'If you have any questions about our Return and Refund Policy, please contact us at support@tellgo.com',
              style: AppTheme.bodyMedium.copyWith(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

