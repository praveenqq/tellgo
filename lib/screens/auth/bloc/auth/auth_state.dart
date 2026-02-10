import 'package:tellgo_app/core/bloc/base_state.dart';
import 'package:tellgo_app/models/user_model.dart';

enum SSOProvider { none, google, apple, facebook, whatsapp }

class AuthState extends BaseState {
  final bool isAuthenticated;
  final UserModel? user;
  final bool isLoading;
  final SSOProvider loadingProvider; // Track which SSO provider is loading
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.loadingProvider = SSOProvider.none,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    bool? isLoading,
    SSOProvider? loadingProvider,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      loadingProvider: loadingProvider ?? this.loadingProvider,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool isProviderLoading(SSOProvider provider) => loadingProvider == provider;
  bool get isAnySSOLoading => loadingProvider != SSOProvider.none;

  @override
  List<Object?> get props => [isAuthenticated, user, isLoading, loadingProvider, errorMessage];
}

// Initial state
class AuthInitial extends AuthState {
  const AuthInitial() : super();
}

// Loading states
class AuthLoading extends AuthState {
  const AuthLoading() : super(isLoading: true);
}

class AuthSSOLoading extends AuthState {
  final SSOProvider provider;
  
  const AuthSSOLoading(this.provider) : super(loadingProvider: provider);
}

// Success states
class AuthLoginSuccess extends AuthState {
  final UserModel userData;

  const AuthLoginSuccess(this.userData)
      : super(isAuthenticated: true, user: userData);
}

class AuthSignupSuccess extends AuthState {
  final UserModel userData;

  const AuthSignupSuccess(this.userData)
      : super(isAuthenticated: true, user: userData);
}

class AuthForgotPasswordSuccess extends AuthState {
  final String email;

  const AuthForgotPasswordSuccess(this.email) : super();

  @override
  List<Object?> get props => [email];
}

class AuthEmailLinkSent extends AuthState {
  final String email;

  const AuthEmailLinkSent(this.email) : super();

  @override
  List<Object?> get props => [email];
}

/// State when OTP is sent successfully to the user's email
class AuthOTPSent extends AuthState {
  final String email;

  const AuthOTPSent(this.email) : super();

  @override
  List<Object?> get props => [email];
}

// Error states
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message) : super(errorMessage: message);

  @override
  List<Object?> get props => [message];
}

