import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_event.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/repository/auth_repository.dart';
import 'package:tellgo_app/repository/wallet_repository.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_bloc.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_event.dart';

class AppBlocProvider extends StatelessWidget {
  final Widget child;
  final AuthRepository authRepository;

  const AppBlocProvider({
    super.key,
    required this.child,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository: authRepository)
            ..add(const CheckAuthStatus()),
        ),
        // Wallet BLoC - available app-wide for balance display in header
        BlocProvider(
          create: (context) => WalletBloc(
            walletRepository: WalletRepositoryImpl(AppDio()),
          )..add(const LoadWalletData()),
        ),
      ],
      child: child,
    );
  }
}

