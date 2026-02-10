import 'package:flutter/material.dart';
import 'package:tellgo_app/theme/app_theme.dart';
import 'package:tellgo_app/widgets/app_card.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? price;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ProductCard({
    super.key,
    required this.title,
    this.subtitle,
    this.price,
    this.imageUrl,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusMedium),
                topRight: Radius.circular(AppTheme.radiusMedium),
              ),
              child: Container(
                height: 200,
                width: double.infinity,
                color: AppTheme.surfaceColor,
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: AppTheme.textHint,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.headingSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    subtitle!,
                    style: AppTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (price != null) ...[
                  const SizedBox(height: AppTheme.spacing8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price!,
                        style: AppTheme.headingMedium.copyWith(
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

