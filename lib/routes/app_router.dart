import 'package:go_router/go_router.dart';
import 'package:tellgo_app/screens/auth/splash_screen.dart';
import 'package:tellgo_app/screens/auth/onboarding_screen.dart';
import 'package:tellgo_app/screens/auth/login_screen.dart';
import 'package:tellgo_app/screens/auth/signup_screen.dart';
import 'package:tellgo_app/screens/auth/verify_email_screen.dart';
import 'package:tellgo_app/screens/main/main_screen.dart';
import 'package:tellgo_app/screens/products/product_list_screen.dart';
import 'package:tellgo_app/screens/products/product_detail_screen.dart';
import 'package:tellgo_app/screens/profile/profile_screen.dart';
import 'package:tellgo_app/screens/profile/my_account_screen.dart';
import 'package:tellgo_app/screens/go_points/go_points_screen.dart';
import 'package:tellgo_app/screens/profile/language_screen.dart';
import 'package:tellgo_app/screens/wallet/wallet_screen.dart' show TopUpScreen;
import 'package:tellgo_app/screens/gift_card/gift_card.dart';
import 'package:tellgo_app/screens/profile/currency_screen.dart';
import 'package:tellgo_app/screens/profile/contact_us_screen.dart';
import 'package:tellgo_app/screens/profile/refund_policy_screen.dart';
import 'package:tellgo_app/screens/profile/rate_app_screen.dart';
import 'package:tellgo_app/screens/orders/orders_screen.dart';
import 'package:tellgo_app/screens/orders_detail/order_details.dart';
import 'package:tellgo_app/screens/qr/qr_code_screen.dart';
import 'package:tellgo_app/screens/receipt/receipt_screen.dart';
import 'package:tellgo_app/screens/payment/payment_screen.dart';
import 'package:tellgo_app/screens/notifications/notifications.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/my-account',
        name: 'my-account',
        builder: (context, state) => const MyAccountScreen(),
      ),
      GoRoute(
        path: '/go-points',
        name: 'go-points',
        builder: (context, state) => const GoPointsScreen(),
      ),
      GoRoute(
        path: '/account-information',
        name: 'account-information',
        builder: (context, state) => const MyAccountScreen(),
      ),
      GoRoute(
        path: '/language',
        name: 'language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/wallet',
        name: 'wallet',
        builder: (context, state) => const TopUpScreen(),
      ),
      GoRoute(
        path: '/gift-cards',
        name: 'gift-cards',
        builder: (context, state) => const GiftCardScreen(),
      ),
      GoRoute(
        path: '/currency',
        name: 'currency',
        builder: (context, state) => const CurrencyScreen(),
      ),
      GoRoute(
        path: '/contact-us',
        name: 'contact-us',
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: '/refund-policy',
        name: 'refund-policy',
        builder: (context, state) => const RefundPolicyScreen(),
      ),
      GoRoute(
        path: '/rate-app',
        name: 'rate-app',
        builder: (context, state) => const RateAppScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/orders/:orderId',
        name: 'order-details',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return OrderDetailsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/qr',
        name: 'qr',
        builder: (context, state) => const QrCodeScreen(),
      ),
      GoRoute(
        path: '/receipt',
        name: 'receipt',
        builder: (context, state) => const ReceiptScreen(),
      ),
      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
  );
}

