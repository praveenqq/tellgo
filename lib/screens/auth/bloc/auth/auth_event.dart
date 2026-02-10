import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignupRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const SignupRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [name, email, password, confirmPassword];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class GoogleLoginRequested extends AuthEvent {
  const GoogleLoginRequested();
}

class AppleLoginRequested extends AuthEvent {
  const AppleLoginRequested();
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class EmailPasswordLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const EmailPasswordLoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class VerifyLoginOTPRequested extends AuthEvent {
  final String email;
  final String otp;

  const VerifyLoginOTPRequested({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}

class GuestLoginRequested extends AuthEvent {
  const GuestLoginRequested();
}

/// Event for OTP-based login (email only, no password)
/// Sends OTP to the provided email address
class LoginWithOTPRequested extends AuthEvent {
  final String email;

  const LoginWithOTPRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

