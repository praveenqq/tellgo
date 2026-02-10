// import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tellgo_app/core/bloc/app_bloc_provider.dart';
import 'package:tellgo_app/firebase_options.dart';
import 'package:tellgo_app/repository/auth_repository.dart';
import 'package:tellgo_app/routes/app_router.dart';
import 'package:tellgo_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue running the app even if Firebase fails to initialize
    // This allows the app to work in development/debug scenarios
  }

  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => const MainApp(),
    // ),
    const MainApp(),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBlocProvider(
      authRepository: FirebaseAuthRepository(),
      child: MaterialApp.router(
        title: 'Tellgo',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        // Device preview configuration
        // useInheritedMediaQuery: true,
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
      ),
    );
  }
}
