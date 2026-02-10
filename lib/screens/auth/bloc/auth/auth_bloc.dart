import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_event.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_state.dart';
import 'package:tellgo_app/repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<AppleLoginRequested>(_onAppleLoginRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<EmailPasswordLoginRequested>(_onEmailPasswordLoginRequested);
    on<VerifyLoginOTPRequested>(_onVerifyLoginOTPRequested);
    on<GuestLoginRequested>(_onGuestLoginRequested);
    on<LoginWithOTPRequested>(_onLoginWithOTPRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthLoginSuccess(user));
      } else {
        emit(const AuthInitial());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(AuthLoginSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      if (event.password != event.confirmPassword) {
        emit(const AuthError('Passwords do not match'));
        return;
      }

      final user = await authRepository.signup(
        event.name,
        event.email,
        event.password,
      );
      emit(AuthSignupSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.logout();
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthSSOLoading(SSOProvider.google));
    try {
      final user = await authRepository.loginWithGoogle();
      emit(AuthLoginSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAppleLoginRequested(
    AppleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthSSOLoading(SSOProvider.apple));
    try {
      final user = await authRepository.loginWithApple();
      emit(AuthLoginSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.forgotPassword(event.email);
      emit(AuthForgotPasswordSuccess(event.email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onEmailPasswordLoginRequested(
    EmailPasswordLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.loginWithEmailPassword(
        event.username,
        event.password,
      );
      emit(AuthLoginSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyLoginOTPRequested(
    VerifyLoginOTPRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.verifyLoginOTP(event.email, event.otp);
      emit(AuthLoginSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGuestLoginRequested(
    GuestLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.registerGuest();
      emit(AuthLoginSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginWithOTPRequested(
    LoginWithOTPRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.loginWithOTP(event.email);
      emit(AuthOTPSent(event.email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

