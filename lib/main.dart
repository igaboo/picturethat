import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/providers/theme_provider.dart';
import 'firebase_options.dart';
import 'package:picture_that/auth_wrapper.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // fix for android 14 edge to edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent),
  );

  // initialize firebase and fcm
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeFcm();

  // keep the splash screen until the theme is loaded
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  // load the theme
  final container = ProviderContainer();
  await container.read(themeProvider.notifier).loadTheme();

  // remove the splash screen
  FlutterNativeSplash.remove();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(themeProvider);

    return MaterialApp(
      title: "Picture That",
      themeMode: themeConfig.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: themeConfig.color,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: themeConfig.color,
      ),
      home: AuthWrapper(),
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
    );
  }
}
