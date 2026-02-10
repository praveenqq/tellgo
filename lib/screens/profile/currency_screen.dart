import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tellgo_app/theme/app_theme.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String _selectedCurrency = 'KWD';

  final List<Map<String, String>> _currencies = [
    {'code': 'KWD', 'name': 'Kuwaiti Dinar', 'symbol': 'KD'},
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'SAR', 'name': 'Saudi Riyal', 'symbol': 'SR'},
  ];

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
          'Currency',
          style: AppTheme.headingMedium.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: _currencies.length,
        itemBuilder: (context, index) {
          final currency = _currencies[index];
          final isSelected = _selectedCurrency == currency['code'];
          return Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: RadioListTile<String>(
              value: currency['code']!,
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
              title: Text(
                currency['name']!,
                style: AppTheme.bodyLarge.copyWith(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                currency['symbol']!,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              secondary: isSelected
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing12,
                        vertical: AppTheme.spacing6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        currency['code']!,
                        style: AppTheme.bodySmall.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textOnPrimary,
                        ),
                      ),
                    )
                  : null,
              activeColor: AppTheme.primaryPurple,
            ),
          );
        },
      ),
    );
  }
}

