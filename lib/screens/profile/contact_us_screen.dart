import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tellgo_app/theme/app_theme.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

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
          'Contact Us',
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
              'Get in Touch',
              style: AppTheme.headingSmall.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            _ContactItem(
              icon: Icons.email_outlined,
              title: 'Email',
              value: 'support@tellgo.com',
              onTap: () {
                // TODO: Open email
              },
            ),
            const SizedBox(height: AppTheme.spacing16),
            _ContactItem(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: '+965 1234 5678',
              onTap: () {
                // TODO: Make call
              },
            ),
            const SizedBox(height: AppTheme.spacing16),
            _ContactItem(
              icon: Icons.chat_bubble_outline,
              title: 'Live Chat',
              value: 'Available 24/7',
              onTap: () {
                // TODO: Open chat
              },
            ),
            const SizedBox(height: AppTheme.spacing32),
            Text(
              'Send us a Message',
              style: AppTheme.headingSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Subject',
                hintText: 'Enter subject',
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Enter your message',
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Send message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message sent successfully!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacing16,
                  ),
                ),
                child: Text(
                  'Send Message',
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

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryPurple,
                size: 28,
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      value,
                      style: AppTheme.bodyLarge.copyWith(
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

