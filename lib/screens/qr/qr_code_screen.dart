import 'package:flutter/material.dart';
import 'package:tellgo_app/theme/app_theme.dart';
import 'package:tellgo_app/widgets/app_button.dart';

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QR Code Display Area
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(
                    color: AppTheme.borderColor,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppTheme.textPrimary,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: const Icon(
                        Icons.qr_code_2,
                        size: 150,
                        color: AppTheme.backgroundColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing32),
              Text(
                'Scan QR Code',
                style: AppTheme.headingMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Position the QR code within the frame to scan',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing48),
              // Scan Button
              AppButton(
                text: 'Scan QR Code',
                icon: Icons.qr_code_scanner,
                onPressed: () {
                  // Handle QR scan
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QR Code scanned successfully'),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTheme.spacing16),
              // Generate QR Button
              AppButton(
                text: 'Generate QR Code',
                type: AppButtonType.outlined,
                icon: Icons.qr_code,
                onPressed: () {
                  // Handle QR generation
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

