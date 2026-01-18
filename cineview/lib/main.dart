import 'package:cineview/presentation/providers/auth_provider.dart';
import 'package:cineview/presentation/screen/faq_page.dart';
import 'package:cineview/presentation/screen/settings_page.dart';
import 'package:cineview/presentation/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AuthProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
