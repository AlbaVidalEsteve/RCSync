import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/controllers/auth_controller.dart';
import 'package:rcsync/core/theme/rc_theme.dart';
import 'package:rcsync/core/values/languages.dart';
import 'app/routes/app_pages.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.maybeGet('SUPABASE_URL');
    final supabaseAnonKey = dotenv.maybeGet('SUPABASE_ANONKEY');

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception("Faltan las credenciales de Supabase en el archivo .env");
    }

    // Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    // Inject AuthController
    Get.put(AuthController(), permanent: true);

    runApp(const MyApp());
  } catch (e) {
    debugPrint("CRITICAL ERROR DURING INITIALIZATION: $e");
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Error al iniciar la aplicación: $e", textAlign: TextAlign.center),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "RCSync",
      translations: Languages(),
      locale: const Locale('es'),
      fallbackLocale: const Locale('en'),
      initialRoute: Supabase.instance.client.auth.currentUser == null
          ? Routes.LOGIN
          : Routes.HOME,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: RCTheme.lightTheme,
      darkTheme: RCTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
