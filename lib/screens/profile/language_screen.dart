import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tellgo_app/theme/app_theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'EN';

  final List<Map<String, String>> _languages = [
    {'code': 'EN', 'name': 'English'},
    {'code': 'AR', 'name': 'العربية'},
    {'code': 'FR', 'name': 'Français'},
    {'code': 'ES', 'name': 'Español'},
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
          'Language',
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
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final language = _languages[index];
          final isSelected = _selectedLanguage == language['code'];
          return Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: RadioListTile<String>(
              value: language['code']!,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
              title: Text(
                language['name']!,
                style: AppTheme.bodyLarge.copyWith(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
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
                        language['code']!,
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

