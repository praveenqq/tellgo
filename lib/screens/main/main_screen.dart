import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tellgo_app/screens/data_plans/data_plans_screen.dart';
import 'package:tellgo_app/screens/home/view/home_view.dart';
import 'package:tellgo_app/screens/profile/profile_screen.dart';
import 'package:tellgo_app/theme/app_theme.dart';

// Bottom nav design colors
const _kNavBackground = Color(0xFFFFFFFF);
const _kNavDivider = Color(0xFFC8B6D8); // light lavender
const _kNavTopBorder = Color(0xFFE8E0F0); // very light gray/lavender
const _kNavInactiveLabel = Color(0xFF2D3436); // dark/black

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeView(),
    const DataPlansScreen(),
    const ProfileScreen(),
  ];

  static const _navHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: _kNavBackground,
          border: Border(top: BorderSide(color: _kNavTopBorder, width: 1)),
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: SizedBox(
            height: _navHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BottomNavSegment(
                  iconPath: 'assets/icons/bottomNav/home.png',
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                if (_currentIndex != 0 && _currentIndex != 1)
                  _NavDivider(height: _navHeight),
                _BottomNavSegment(
                  iconPath: 'assets/icons/bottomNav/esim.png',
                  label: 'Data Plans',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                if (_currentIndex == 0) _NavDivider(height: _navHeight),
                _BottomNavSegment(
                  iconPath: 'assets/icons/bottomNav/my_account.png',
                  label: 'My Account',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDivider extends StatelessWidget {
  const _NavDivider({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final dividerHeight = height * 0.65;
    return SizedBox(
      width: 1,
      child: Center(
        child: Container(width: 1, height: dividerHeight, color: _kNavDivider),
      ),
    );
  }
}

class _BottomNavSegment extends StatelessWidget {
  const _BottomNavSegment({
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ColoredBox(
          color: isSelected ? AppTheme.primaryPurple : _kNavBackground,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 24,
                height: 24,
                color: isSelected ? Colors.white : _kNavInactiveLabel,
                colorBlendMode: BlendMode.srcIn,
                errorBuilder:
                    (_, __, ___) => Icon(
                      Icons.circle_outlined,
                      size: 24,
                      color: isSelected ? Colors.white : _kNavInactiveLabel,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : _kNavInactiveLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
