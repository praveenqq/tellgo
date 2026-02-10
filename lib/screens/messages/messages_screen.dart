import 'package:flutter/material.dart';
import 'package:tellgo_app/theme/app_theme.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: AppTheme.headingSmall.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'No messages yet',
              style: AppTheme.headingMedium.copyWith(
                fontSize: 20,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Your messages will appear here',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

