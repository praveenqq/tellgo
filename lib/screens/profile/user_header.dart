import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_state.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_bloc.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_state.dart';

/// Common reusable header:
/// - Avatar (left)
/// - "Hello, <Name> !" + "welcome back"
/// - Balance text (right)
/// - Notification bell button with red count badge
/// - Bottom divider line
///
/// Sizing/colors tuned to your header screenshot:
/// - Primary purple: #85209C
/// - Dark greeting:  #220036
/// - Secondary text: #91829A
/// - Divider:        #E7D7EB (2px)
/// - Badge red:      #FF0021
///
/// If userName or avatarImage are not provided, they will be automatically
/// fetched from AuthBloc (user's name and photo from authentication state).
class CommonAppHeader extends StatelessWidget {
  const CommonAppHeader({
    super.key,
    this.userName,
    this.balanceText,
    this.subtitle = 'welcome back',
    this.avatarImage,
    this.avatarImageUrl,
    this.onAvatarTap,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.includeSafeAreaTop = true,
    this.showDivider = true,
  });

  /// User name to display. If null, will be fetched from AuthBloc.
  final String? userName;
  /// Balance text to display. If null, will be fetched from WalletBloc.
  final String? balanceText;
  final String subtitle;

  /// ImageProvider for avatar. If null, will try to use avatarImageUrl or fetch from AuthBloc.
  final ImageProvider? avatarImage;
  /// Network image URL for avatar. If null, will try to fetch from AuthBloc.
  final String? avatarImageUrl;
  final VoidCallback? onAvatarTap;

  final VoidCallback? onNotificationTap;
  final int notificationCount;

  /// If true, adds SafeArea(top) inside the header
  /// (useful when you place it at the very top of the screen body).
  final bool includeSafeAreaTop;

  final bool showDivider;

  // --- Tokens (from screenshot) ---
  static const Color _primaryPurple = Color(0xFF85209C);
  static const Color _greetingDark = Color(0xFF220036);
  static const Color _secondaryText = Color(0xFF91829A);
  static const Color _dividerLavender = Color(0xFFE7D7EB);
  static const Color _badgeRed = Color(0xFFFF0021);

  /// Format wallet balance with currency
  String _formatBalance(double? balance, String? currency) {
    if (balance == null) return '0.00${currency ?? 'KD'}';
    return '${balance.toStringAsFixed(2)}${currency ?? 'KD'}';
  }

  /// Check if WalletBloc is available in the widget tree
  WalletBloc? _tryGetWalletBloc(BuildContext context) {
    try {
      return context.read<WalletBloc>();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Base width assumption: typical mobile 390.
    // Keep gentle scaling so it stays consistent on 360/375/430 widths.
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Get user data from auth state if not provided
        final user = authState.user;
        final displayName = userName ?? user?.name ?? 'User';
        final userPhotoUrl = avatarImageUrl ?? user?.photoUrl ?? user?.profileImageUrl;

        // Check if WalletBloc is available
        final walletBloc = _tryGetWalletBloc(context);

        // If WalletBloc is available, use BlocBuilder, otherwise just build with balanceText
        if (walletBloc != null) {
          return BlocBuilder<WalletBloc, WalletState>(
            bloc: walletBloc,
            builder: (context, walletState) {
              // Get balance from WalletBloc if not provided
              final displayBalance = balanceText ?? 
                  _formatBalance(walletState.balance?.balance, walletState.balance?.currency);
              final isLoading = walletState.isLoadingBalance && balanceText == null;

              return _buildContent(
                context: context,
                displayName: displayName,
                userPhotoUrl: userPhotoUrl,
                displayBalance: displayBalance,
                isLoadingBalance: isLoading,
              );
            },
          );
        } else {
          // WalletBloc not available, use provided balanceText or default
          return _buildContent(
            context: context,
            displayName: displayName,
            userPhotoUrl: userPhotoUrl,
            displayBalance: balanceText ?? '0.00KD',
            isLoadingBalance: false,
          );
        }
      },
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required String displayName,
    required String? userPhotoUrl,
    required String displayBalance,
    required bool isLoadingBalance,
  }) {
    return LayoutBuilder(
      builder: (context, c) {
        final scale = (c.maxWidth / 390.0).clamp(0.85, 1.15);
        double s(double px) => px * scale;

        // Key geometry (tuned to screenshot proportions)
        final rowHPad = s(16); // avatar closer to edge than divider
        final dividerHPad = s(32); // divider aligns more with "form/grid" area
        final topPad = s(14);
        final bottomPad = s(17);

        final avatarSize = s(40);
        final bellSize = s(40);
        final badgeSize = s(14);

        final greetingStyleHello = TextStyle(
          fontSize: s(18),
          fontWeight: FontWeight.w500,
          height: 1.1,
          color: _secondaryText,
        );
        final greetingStyleName = TextStyle(
          fontSize: s(18),
          fontWeight: FontWeight.w700,
          height: 1.1,
          color: _greetingDark,
        );
        final subtitleStyle = TextStyle(
          fontSize: s(11),
          fontWeight: FontWeight.w400,
          height: 1.1,
          color: _secondaryText,
        );
        final balanceStyle = TextStyle(
          fontSize: s(14),
          fontWeight: FontWeight.w600,
          height: 1.1,
          color: _primaryPurple,
        );

        Widget content = Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(rowHPad, topPad, rowHPad, bottomPad),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Avatar(
                      size: avatarSize,
                      image: avatarImage,
                      imageUrl: userPhotoUrl,
                      onTap: onAvatarTap,
                    ),
                    SizedBox(width: s(12)),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // "Hello, Hamdan !"
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: 'Hello, ', style: greetingStyleHello),
                                TextSpan(text: '$displayName !', style: greetingStyleName),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: s(4)),
                          Text(
                            subtitle,
                            style: subtitleStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: s(12)),

                    // Balance with loading indicator
                    if (isLoadingBalance)
                      SizedBox(
                        width: s(16),
                        height: s(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _primaryPurple,
                        ),
                      )
                    else
                      Text(
                        displayBalance,
                        style: balanceStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    SizedBox(width: s(16)),

                    _NotificationBell(
                      size: bellSize,
                      badgeSize: badgeSize,
                      count: notificationCount,
                      onTap: onNotificationTap,
                      purple: _primaryPurple,
                      badgeRed: _badgeRed,
                    ),
                  ],
                ),
              ),

              if (showDivider)
                Container(
                  height: s(2),
                  margin: EdgeInsets.symmetric(horizontal: dividerHPad),
                  decoration: BoxDecoration(
                    color: _dividerLavender,
                    borderRadius: BorderRadius.circular(s(1)),
                  ),
                ),
            ],
          ),
        );

        if (includeSafeAreaTop) {
          content = SafeArea(top: true, bottom: false, child: content);
        }
        return content;
      },
    );
  }
}

/// Use this if you want the header in Scaffold.appBar (shared across many screens).
class CommonHeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonHeaderAppBar({
    super.key,
    required this.header,
    this.height = 80,
  });

  final CommonAppHeader header;

  /// Toolbar-ish height (SafeArea adds status bar on top inside header if enabled).
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    // Important: avoid default AppBar elevation/shadow.
    return Material(
      color: Colors.white,
      elevation: 0,
      child: header,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.size,
    this.image,
    this.imageUrl,
    this.onTap,
  });

  final double size;
  final ImageProvider? image;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget avatarContent;
    
    if (image != null) {
      // Use provided ImageProvider
      avatarContent = Image(image: image!, fit: BoxFit.cover);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Use network image URL
      avatarContent = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, color: Colors.white, size: size * 0.55);
        },
      );
    } else {
      // Default icon
      avatarContent = Icon(Icons.person, color: Colors.white, size: size * 0.55);
    }

    final avatar = ClipOval(
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFFEDEDED),
        child: avatarContent,
      ),
    );

    if (onTap == null) return avatar;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: avatar,
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({
    required this.size,
    required this.badgeSize,
    required this.count,
    required this.onTap,
    required this.purple,
    required this.badgeRed,
  });

  final double size;
  final double badgeSize;
  final int count;
  final VoidCallback? onTap;
  final Color purple;
  final Color badgeRed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: purple,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: size * 0.55,
            ),
          ),
          if (count > 0)
            Positioned(
              // Slightly outside top-right like the screenshot
              right: -badgeSize * 0.15,
              top: -badgeSize * 0.15,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: badgeRed,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: badgeSize * 0.62,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
