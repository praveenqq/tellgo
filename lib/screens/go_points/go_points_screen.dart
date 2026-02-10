import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/repository/loyalty_repository.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_bloc.dart';
import 'package:tellgo_app/screens/go_points/bloc/loyalty_bloc.dart';
import 'package:tellgo_app/screens/go_points/bloc/loyalty_event.dart';
import 'package:tellgo_app/screens/go_points/bloc/loyalty_state.dart';
import 'package:tellgo_app/screens/profile/user_header.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_bloc.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_state.dart';
import 'package:tellgo_app/widgets/go_points_user_header.dart';
import 'package:tellgo_app/widgets/go_points_transaction_history.dart';

/// Pixel-perfect-ish rebuild of the provided "Go Points" screen.
/// Base design width: 521px (from the screenshot).
///
/// Drop this file into your Flutter project and use:
///   MaterialApp(home: GoPointsScreen())
class GoPointsScreen extends StatelessWidget {
  const GoPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoyaltyBloc(
        loyaltyRepository: LoyaltyRepositoryImpl(AppDio()),
      )..add(const LoadLoyaltyData()),
      child: const _GoPointsScreenContent(),
    );
  }
}

class _GoPointsScreenContent extends StatelessWidget {
  const _GoPointsScreenContent();

  double _clampDouble(double v, double min, double max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  @override
  Widget build(BuildContext context) {
    // Get user name from AuthBloc
    final authState = context.watch<AuthBloc>().state;
    final userName = authState.user?.name ?? 'User';
    final w = MediaQuery.of(context).size.width;
    final scale = w / 521.0;

    double s(double px) => px * scale;

    // Primary left inset observed ~66px on 521px wide screenshot.
    final sidePad = _clampDouble(s(66), 24, 70);

    // Colors (tokens)
    const bg = Color(0xFFFFFFFF);
    const textSecondary = Color(0xFF7E7F7F);

    // Typography (approx)
    final appTitle = TextStyle(
      fontSize: s(16),
      fontWeight: FontWeight.w700,
      height: 20 / 16,
      color: Colors.black,
    );
    final sectionHeading = TextStyle(
      fontSize: s(18),
      fontWeight: FontWeight.w700,
      height: 24 / 18,
      color: Colors.black,
    );
    final body = TextStyle(
      fontSize: s(14),
      fontWeight: FontWeight.w400,
      height: 20 / 14,
      color: textSecondary,
    );

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        top: true,
        bottom: true,
        child: BlocBuilder<LoyaltyBloc, LoyaltyState>(
          builder: (context, loyaltyState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Common header at the top - balance fetched from WalletBloc
                const CommonAppHeader(
                  includeSafeAreaTop: false, // SafeArea is already handled by parent
                ),

                // Title row
                Padding(
                  padding: EdgeInsets.only(
                    left: sidePad,
                    right: sidePad,
                    top: s(27),
                  ),
                  child: Text('Go Points', style: appTitle),
                ),

                SizedBox(height: s(25)), // title → header gap (approx)

                // User header widget with balance from WalletBloc and points from LoyaltyBloc
                BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, walletState) {
                    final balance = walletState.balance;
                    final balanceText = balance != null
                        ? '${balance.balance.toStringAsFixed(2)} ${balance.currency ?? 'KD'}'
                        : '0.00 KD';

                    // Get points from loyalty state
                    final points = loyaltyState.points;
                    final pointsText = points != null
                        ? points.availablePoints.toStringAsFixed(0)
                        : '0';

                    return GoPointsUserHeader(
                      userName: userName,
                      points: pointsText,
                      balance: balanceText,
                      scale: scale,
                    );
                  },
                ),

                // Info section
                Padding(
                  padding: EdgeInsets.only(
                    left: sidePad,
                    right: sidePad,
                    top: s(50),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('What are telgo points?', style: sectionHeading),
                      SizedBox(height: s(26)),
                      Text(
                        'Go Points is the internal points and rewards system of Telgo Company. '
                        'Every 200 points equal 1 Kuwaiti Dinar and for every Dinar spent on '
                        'purchasing packages you earn 5 points.',
                        style: body,
                      ),
                    ],
                  ),
                ),

                // Transaction History widget
                Expanded(
                  child: _buildTransactionSection(
                    context,
                    loyaltyState,
                    scale,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionSection(
    BuildContext context,
    LoyaltyState loyaltyState,
    double scale,
  ) {
    // Show loading indicator while loading
    if (loyaltyState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF832D9F),
        ),
      );
    }

    // Show error state
    if (loyaltyState.errorMessage != null && loyaltyState.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade400,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load transactions',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                context.read<LoyaltyBloc>().add(const LoadLoyaltyData());
              },
              child: const Text(
                'Retry',
                style: TextStyle(color: Color(0xFF832D9F)),
              ),
            ),
          ],
        ),
      );
    }

    // Convert loyalty transactions to TransactionItem for the widget
    final transactions = loyaltyState.transactions
        .map((t) => TransactionItem(
              title: t.title ?? t.description ?? 'Transaction',
              time: t.formattedDate,
              pointsDelta: t.pointsDelta,
            ))
        .toList();

    // Show empty state if no transactions
    if (transactions.isEmpty) {
      return GoPointsTransactionHistory(
        transactions: const [],
        scale: scale,
        sidePadding: 66.0,
        scrollRailWidth: 65.0,
        trackLeftInset: 20.0,
        trackWidth: 7.0,
        initialExpanded: true,
        emptyMessage: 'No transactions yet',
      );
    }

    return GoPointsTransactionHistory(
      transactions: transactions,
      scale: scale,
      sidePadding: 66.0,
      scrollRailWidth: 65.0,
      trackLeftInset: 20.0,
      trackWidth: 7.0,
      initialExpanded: true,
    );
  }
}
