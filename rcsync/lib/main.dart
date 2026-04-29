import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/controllers/auth_controller.dart';
import 'package:rcsync/core/theme/rc_theme.dart';
import 'package:rcsync/core/values/languages.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/routes/app_pages.dart';
import 'package:rcsync/core/theme/rc_colors.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('es_ES', null);
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.maybeGet('SUPABASE_URL');
    final supabaseAnonKey = dotenv.maybeGet('SUPABASE_ANONKEY');

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception("Faltan las credenciales de Supabase en el archivo .env");
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si es web ancho mayor a 600 px
        if (constraints.maxWidth > 600) {
          return Center(
            child: Container(
              width: 500, // Ancho fijo similar a móvil
              decoration: BoxDecoration(
                color: RCColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: _buildApp(),
            ),
          );
        }
        // Para móviles comportamiento normal
        return _buildApp();
      },
    );
  }

  Widget _buildApp() {
    return GetMaterialApp(
      title: "RCSync",
      translations: Languages(),
      locale: const Locale('es'),
      fallbackLocale: const Locale('en'),
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: RCTheme.lightTheme,
      darkTheme: RCTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}