import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_event.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_state.dart';
import 'package:tellgo_app/responsive.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_bloc.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_state.dart';
import 'package:tellgo_app/theme/app_theme.dart';

// Profile screen design colors
const _kProfileBackground = Color(0xFFFFFFFF);
const _kTileFill = Color(0xFFF1F1F1);
const _kTileBorder = Color(0xFFC8B6D8);
const _kSignOutRed = Color(0xFFEE1C1F);
const _kGreetingSubtext = Color(0xFF9E9E9E);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = R.hPad(w);
    final scale = R.sxScale(w);
    final tileHeight = (56 * scale).clamp(48.0, 64.0);
    final tileGap = 12 * scale;
    final borderRadius = 12.0 * scale;
    final contentWidth = MediaQuery.sizeOf(context).width - 2 * hPad;

    return Scaffold(
      backgroundColor: _kProfileBackground,
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHeader(hPad: hPad),
              SizedBox(height: 24 * scale),
              _GreetingBlock(hPad: hPad, scale: scale),
              SizedBox(height: 24 * scale),
              _WalletBalance(hPad: hPad, scale: scale),
              SizedBox(height: 20 * scale),
              _SettingsTiles(
                hPad: hPad,
                scale: scale,
                tileHeight: tileHeight,
                tileGap: tileGap,
                borderRadius: borderRadius,
                contentWidth: contentWidth,
              ),
              SizedBox(height: 32 * scale),
              _SignOutButton(scale: scale),
              SizedBox(height: 24 * scale),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.hPad});

  final double hPad;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: hPad),
            child: SizedBox(
              child: Text('My Account', style: AppTheme.headingSmall),
            ),
          ),
        ),
      ],
    );
  }
}

class _GreetingBlock extends StatelessWidget {
  const _GreetingBlock({required this.hPad, required this.scale});

  final double hPad;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = (64 * scale).clamp(52.0, 72.0);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        final userName = user?.name ?? 'User';
        final userPhotoUrl = user?.photoUrl ?? user?.profileImageUrl;
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: _kTileFill,
                      borderRadius: BorderRadius.circular(14 * scale),
                    ),
                    child: userPhotoUrl != null && userPhotoUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14 * scale),
                            child: Image.network(
                              userPhotoUrl,
                              width: size,
                              height: size,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person_outline,
                                  size: 32 * scale,
                                  color: _kGreetingSubtext,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.person_outline,
                            size: 32 * scale,
                            color: _kGreetingSubtext,
                          ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 24 * scale,
                      height: 24 * scale,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/profile/plus_icon.png',
                          width: 14 * scale,
                          height: 14 * scale,
                          color: Colors.white,
                          errorBuilder:
                              (_, __, ___) => const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 14,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hello,$userName !',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 18 * scale,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'welcome back',
                      style: AppTheme.bodyMedium.copyWith(
                        color: _kGreetingSubtext,
                        fontSize: 14 * scale,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WalletBalance extends StatelessWidget {
  const _WalletBalance({required this.hPad, required this.scale});

  final double hPad;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        final balance = walletState.balance;
        final balanceText = balance != null
            ? '${balance.currency ?? 'KD'} ${balance.balance.toStringAsFixed(2)}'
            : 'KD 0.00';

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet balance',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 14 * scale,
                ),
              ),
              SizedBox(height: 4),
              if (walletState.isLoadingBalance)
                SizedBox(
                  width: 24 * scale,
                  height: 24 * scale,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  balanceText,
                  style: AppTheme.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 28 * scale,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

enum _TileType { standard, split }

class _TileData {
  const _TileData({
    required this.title,
    required this.iconPath,
    this.type = _TileType.standard,
    this.value,
  });

  final String title;
  final String iconPath;
  final _TileType type;
  final String? value;
}

class _SettingsTiles extends StatelessWidget {
  const _SettingsTiles({
    required this.hPad,
    required this.scale,
    required this.tileHeight,
    required this.tileGap,
    required this.borderRadius,
    required this.contentWidth,
  });

  final double hPad;
  final double scale;
  final double tileHeight;
  final double tileGap;
  final double borderRadius;
  final double contentWidth;

  List<_TileData> _getTiles(String walletBalance) {
    return [
      const _TileData(title: 'Orders', iconPath: 'assets/icons/profile/orders.png'),
      const _TileData(
        title: 'Account Information',
        iconPath: 'assets/icons/profile/account_info.png',
      ),
      const _TileData(
        title: 'Language',
        iconPath: 'assets/icons/profile/language.png',
        type: _TileType.split,
        value: 'EN',
      ),
      const _TileData(
        title: 'Go Points',
        iconPath: 'assets/icons/profile/go_points.png',
      ),
      _TileData(
        title: 'Wallet',
        iconPath: 'assets/icons/profile/wallet.png',
        type: _TileType.split,
        value: walletBalance,
      ),
      const _TileData(
        title: 'Gift Cards',
        iconPath: 'assets/icons/profile/gift_cards.png',
      ),
      const _TileData(
        title: 'Currency',
        iconPath: 'assets/icons/profile/currency.png',
        type: _TileType.split,
        value: 'KWD',
      ),
      const _TileData(
        title: 'Contact Us',
        iconPath: 'assets/icons/profile/contact_us.png',
      ),
      const _TileData(
        title: 'Return & Refund Policy',
        iconPath: 'assets/icons/profile/return_refund.png',
      ),
      const _TileData(title: 'Rate App', iconPath: 'assets/icons/profile/rate_us.png'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        final balance = walletState.balance;
        final walletBalanceText = balance != null
            ? '${balance.balance.toStringAsFixed(2)} ${balance.currency ?? 'KD'}'
            : '0.00 KD';
        final tiles = _getTiles(walletBalanceText);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) SizedBox(height: tileGap),
                _SettingsTile(
                  data: tiles[i],
                  tileHeight: tileHeight,
                  borderRadius: borderRadius,
                  contentWidth: contentWidth,
                  scale: scale,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.data,
    required this.tileHeight,
    required this.borderRadius,
    required this.contentWidth,
    required this.scale,
  });

  final _TileData data;
  final double tileHeight;
  final double borderRadius;
  final double contentWidth;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final isSplit = data.type == _TileType.split;
    final rightWidth = contentWidth * 0.37;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: tileHeight,
          decoration: BoxDecoration(
            color: _kTileFill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: _kTileBorder, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: isSplit ? _buildSplitTile(rightWidth) : _buildStandardTile(),
        ),
      ),
    );
  }

  Widget _buildStandardTile() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Row(
        children: [
          _buildIcon(),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              data.title,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 15 * scale,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppTheme.primaryPurple,
            size: 24 * scale,
          ),
        ],
      ),
    );
  }

  Widget _buildSplitTile(double rightWidth) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Row(
        children: [
          Expanded(
            child: Container(
              color: _kTileFill,
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Row(
                children: [
                  _buildIcon(),
                  SizedBox(width: 12 * scale),
                  Expanded(
                    child: Text(
                      data.title,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 15 * scale,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: rightWidth,
            child: Container(
              height:
                  tileHeight, // Make the purple container as tall as the parent tile
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(borderRadius),
                  bottomRight: Radius.circular(borderRadius),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      data.value ?? '',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14 * scale,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 20 * scale,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Image.asset(
      data.iconPath,
      width: 24 * scale,
      height: 24 * scale,
      errorBuilder:
          (_, __, ___) => Icon(
            Icons.settings,
            size: 24 * scale,
            color: AppTheme.textPrimary,
          ),
    );
  }

  void _onTap(BuildContext context) {
    switch (data.title) {
      case 'Orders':
        context.push('/orders');
        break;
      case 'Account Information':
        context.push('/account-information');
        break;
      case 'Language':
        context.push('/language');
        break;
      case 'Go Points':
        context.push('/go-points');
        break;
      case 'Wallet':
        context.push('/wallet');
        break;
      case 'Gift Cards':
        context.push('/gift-cards');
        break;
      case 'Currency':
        context.push('/currency');
        break;
      case 'Contact Us':
        context.push('/contact-us');
        break;
      case 'Return & Refund Policy':
        context.push('/refund-policy');
        break;
      case 'Rate App':
        context.push('/rate-app');
        break;
    }
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.scale});

  final double scale;

  void _handleSignOut(BuildContext context) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Dispatch logout event
              context.read<AuthBloc>().add(const LogoutRequested());
              // Navigate to login screen
              context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: _kSignOutRed),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () => _handleSignOut(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20 * scale,
            vertical: 12 * scale,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/profile/sign_out.png',
                width: 22 * scale,
                height: 22 * scale,
                color: _kSignOutRed,
                errorBuilder:
                    (_, __, ___) => Icon(
                      Icons.logout,
                      color: _kSignOutRed,
                      size: 22 * scale,
                    ),
              ),
              SizedBox(width: 8 * scale),
              Text(
                'Sign Out',
                style: AppTheme.bodyMedium.copyWith(
                  color: _kSignOutRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 16 * scale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
