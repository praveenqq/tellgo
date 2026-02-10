import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tellgo_app/theme/app_theme.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  int _selectedRating = 0;

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
          'Rate App',
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
          children: [
            const SizedBox(height: AppTheme.spacing32),
            Icon(
              Icons.star_outline,
              size: 80,
              color: AppTheme.primaryPurple,
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              'How would you rate our app?',
              style: AppTheme.headingSmall.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing32),
            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing8,
                    ),
                    child: Icon(
                      index < _selectedRating
                          ? Icons.star
                          : Icons.star_outline,
                      size: 48,
                      color: index < _selectedRating
                          ? AppTheme.accentYellow
                          : AppTheme.textSecondary,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppTheme.spacing32),
            // Feedback Text Field
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Tell us more (optional)',
                hintText: 'Share your feedback...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing32),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedRating > 0
                    ? () {
                        // TODO: Submit rating
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Thank you for your $_selectedRating-star rating!',
                            ),
                            backgroundColor: AppTheme.accentGreen,
                          ),
                        );
                        Future.delayed(const Duration(seconds: 1), () {
                          if (context.mounted) {
                            context.pop();
                          }
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacing16,
                  ),
                ),
                child: Text(
                  'Submit Rating',
                  style: AppTheme.button.copyWith(
                    color: AppTheme.textOnPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

