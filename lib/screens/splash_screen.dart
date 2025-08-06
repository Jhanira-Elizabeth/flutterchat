import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../firebase_options.dart';
import '../main.dart'; // o donde tengas AppRoot
import '../providers/theme_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await dotenv.load(fileName: ".env");
      await Hive.initFlutter();

      // Firebase init (con verificación)
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Aquí podrías abrir cajas Hive, revisar login, etc.

      // Espera un poco para mostrar el splash
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      print('Error al inicializar: $e');
    }

    // Cuando termines, navega a AppRoot (tu pantalla principal)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const AppRoot(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('assets/images/logo_provisional.png'),
          width: 200,
        ),
      ),
    );
  }
}
