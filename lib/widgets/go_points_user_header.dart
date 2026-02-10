import 'package:flutter/material.dart';

/// Reusable user profile header widget for Go Points screen.
/// Displays avatar with badge, user name, and stats (Points and Balance).
/// 
/// When [walletStyle] is true, shows a simplified layout with just
/// the user name and balance/credit (used for wallet screen).
class GoPointsUserHeader extends StatelessWidget {
  const GoPointsUserHeader({
    super.key,
    required this.userName,
    required this.points,
    required this.balance,
    this.scale = 1.0,
    this.onAvatarTap,
    this.avatarImage,
    this.avatarImageUrl,
    this.walletStyle = false,
  });

  final String userName;
  final String points;
  final String balance;
  final double scale;
  final VoidCallback? onAvatarTap;
  final ImageProvider? avatarImage;
  final String? avatarImageUrl;
  
  /// When true, shows simplified wallet-style layout (name + balance/credit only)
  final bool walletStyle;

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    // Colors
    const headerBg = Color(0xFFF1F1F1);
    const primaryPurple = Color(0xFF832D9F);
    const dividerGray = Color(0xFF787878);
    const avatarTile = Color(0xFFCCCCCC);

    // Typography
    final profileName = TextStyle(
      fontSize: s(22),
      fontWeight: FontWeight.w700,
      height: 28 / 22,
      color: Colors.black,
    );
    final statLabel = TextStyle(
      fontSize: s(14),
      fontWeight: FontWeight.w500,
      height: 18 / 14,
      color: const Color(0xFF5A5A5A),
    );
    final statValue = TextStyle(
      fontSize: s(16),
      fontWeight: FontWeight.w700,
      height: 22 / 16,
      color: Colors.black,
    );

    // Wallet style - simplified layout
    if (walletStyle) {
      return Container(
        width: double.infinity,
        color: headerBg,
        padding: EdgeInsets.symmetric(vertical: s(24)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User name only (no avatar)
              Text(userName, style: profileName),
              
              SizedBox(height: s(16)),
              
              // Single balance/credit display
              Text('Balance', style: statLabel),
              SizedBox(height: s(6)),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'KD ',
                      style: statValue.copyWith(
                        fontSize: s(18),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: _extractBalanceNumber(balance),
                      style: statValue.copyWith(
                        fontSize: s(18),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' Credit',
                      style: statValue.copyWith(
                        fontSize: s(14),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5A5A5A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default style - Points | Balance with divider
    return Container(
      height: s(172),
      width: double.infinity,
      color: headerBg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar + name row (centered group)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AvatarWithBadge(
                  size: s(42),
                  radius: s(6),
                  tileColor: avatarTile,
                  badgeColor: primaryPurple,
                  // Badge overlaps ~3px outside bottom-right
                  badgeOffset: Offset(-s(3), -s(3)),
                  iconSize: s(24),
                  badgeSize: s(15),
                  badgeIconSize: s(11),
                  onTap: onAvatarTap,
                  avatarImage: avatarImage,
                  avatarImageUrl: avatarImageUrl,
                ),
                SizedBox(width: s(15)),
                Text(userName, style: profileName),
              ],
            ),

            SizedBox(height: s(30)),

            // Stats row with divider
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatColumn(
                    label: 'Points',
                    value: points,
                    labelStyle: statLabel,
                    valueStyle: statValue,
                    valueTopGap: s(6),
                  ),
                  SizedBox(width: s(44)),
                  Container(
                    width: s(1), // Scaled divider width
                    color: dividerGray,
                    margin: EdgeInsets.symmetric(vertical: s(6)),
                  ),
                  SizedBox(width: s(44)),
                  _StatColumn(
                    label: 'Balance',
                    value: balance,
                    labelStyle: statLabel,
                    valueStyle: statValue,
                    valueTopGap: s(6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Extract the numeric part from balance string (e.g., "50.00 KD" -> "50.00")
  String _extractBalanceNumber(String balance) {
    // Remove "KD" and "KWD" and any extra spaces
    final cleaned = balance.replaceAll('KD', '').replaceAll('KWD', '').trim();
    // Try to parse and format with 2 decimal places for currency
    final number = double.tryParse(cleaned);
    if (number != null) {
      return number.toStringAsFixed(2);
    }
    return cleaned;
  }
}

/// Avatar tile with bottom-right plus badge (overlapping slightly outside).
class _AvatarWithBadge extends StatelessWidget {
  const _AvatarWithBadge({
    required this.size,
    required this.radius,
    required this.tileColor,
    required this.badgeColor,
    required this.badgeOffset,
    required this.iconSize,
    required this.badgeSize,
    required this.badgeIconSize,
    this.onTap,
    this.avatarImage,
    this.avatarImageUrl,
  });

  final double size;
  final double radius;
  final Color tileColor;
  final Color badgeColor;
  final Offset badgeOffset; // negative values push badge outside
  final double iconSize;
  final double badgeSize;
  final double badgeIconSize;
  final VoidCallback? onTap;
  final ImageProvider? avatarImage;
  final String? avatarImageUrl;

  @override
  Widget build(BuildContext context) {
    Widget avatarContent;
    
    if (avatarImage != null) {
      avatarContent = Image(image: avatarImage!, fit: BoxFit.cover);
    } else if (avatarImageUrl != null && avatarImageUrl!.isNotEmpty) {
      avatarContent = Image.network(
        avatarImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, color: Colors.white, size: iconSize);
        },
      );
    } else {
      avatarContent = Icon(Icons.person, color: Colors.white, size: iconSize);
    }

    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: avatarContent,
          ),
        ),
        Positioned(
          right: badgeOffset.dx,
          bottom: badgeOffset.dy,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.add, color: Colors.white, size: badgeIconSize),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return avatar;
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
    required this.valueTopGap,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final double valueTopGap;

  @override
  Widget build(BuildContext context) {
    // Parse value to separate number and "KD" for balance display
    final isBalance = label == 'Balance';
    String? numberPart;
    String? kdPart;
    
    if (isBalance && value.contains('KD')) {
      final parts = value.split('KD');
      numberPart = parts[0].trim();
      kdPart = 'KD';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle),
        SizedBox(height: valueTopGap),
        isBalance && numberPart != null && kdPart != null
            ? RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: numberPart,
                      style: valueStyle,
                    ),
                    TextSpan(
                      text: ' $kdPart',
                      style: valueStyle.copyWith(
                        fontSize: valueStyle.fontSize! * 0.7, // 70% of original size
                      ),
                    ),
                  ],
                ),
              )
            : Text(value, style: valueStyle),
      ],
    );
  }
}


