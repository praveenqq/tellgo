import 'package:flutter/material.dart';
import 'package:tellgo_app/theme/app_theme.dart';
import 'package:tellgo_app/widgets/app_card.dart';
import 'package:tellgo_app/widgets/app_button.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Receipts'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: ListView(
        children: [
          _ReceiptCard(
            receiptNumber: 'REC-001',
            date: 'Jan 15, 2024',
            amount: '\$149.99',
            store: 'Tellgo Store',
          ),
          _ReceiptCard(
            receiptNumber: 'REC-002',
            date: 'Jan 10, 2024',
            amount: '\$79.99',
            store: 'Tellgo Store',
          ),
          _ReceiptCard(
            receiptNumber: 'REC-003',
            date: 'Jan 5, 2024',
            amount: '\$249.99',
            store: 'Tellgo Store',
          ),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final String receiptNumber;
  final String date;
  final String amount;
  final String store;

  const _ReceiptCard({
    required this.receiptNumber,
    required this.date,
    required this.amount,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        _showReceiptDetail(context);
      },
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                receiptNumber,
                style: AppTheme.headingSmall,
              ),
              Text(
                amount,
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Row(
            children: [
              Icon(
                Icons.store,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                store,
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                date,
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReceiptDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLarge),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppTheme.spacing12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receipt Details',
                      style: AppTheme.headingMedium,
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    _ReceiptDetailRow(
                      label: 'Receipt Number',
                      value: receiptNumber,
                    ),
                    _ReceiptDetailRow(
                      label: 'Date',
                      value: date,
                    ),
                    _ReceiptDetailRow(
                      label: 'Store',
                      value: store,
                    ),
                    const Divider(),
                    _ReceiptDetailRow(
                      label: 'Item 1',
                      value: '\$49.99',
                    ),
                    _ReceiptDetailRow(
                      label: 'Item 2',
                      value: '\$50.00',
                    ),
                    _ReceiptDetailRow(
                      label: 'Item 3',
                      value: '\$50.00',
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: AppTheme.headingMedium,
                        ),
                        Text(
                          amount,
                          style: AppTheme.headingMedium.copyWith(
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing32),
                    AppButton(
                      text: 'Download Receipt',
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Receipt downloaded'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptDetailRow({
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

