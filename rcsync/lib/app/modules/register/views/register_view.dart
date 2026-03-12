import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/rc_colors.dart'; // Ajusta la ruta a tu archivo de colores
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RCColors.background,
      body: Stack(
        children: [
          // --- CAPA DE FONDO: DOS TONOS SÓLIDOS (Estilo rcsync) ---
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(color: RCColors.background), // Azul Oscuro
              ),
              Expanded(
                flex: 7,
                child: Container(color: RCColors.background), // Azul Marca
              ),
            ],
          ),

          // --- CONTENIDO DEL FORMULARIO ---
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              children: [
                const SizedBox(height: 40),

                // --- LOGO (Sincronizado con Login) ---
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/images/logo_rcsync.jpeg',
                    height: 500,
                  ),
                ),

                const SizedBox(height: 20),

                // --- CAMPO NOMBRE ---
                _buildInputLabel("NOMBRE"),
                TextField(
                  autocorrect: false,
                  controller: controller.nameC,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: RCColors.white),
                  decoration: _inputDecoration(
                    hint: "Tu nombre de piloto",
                    icon: Icons.person_outline,
                  ),
                ),

                const SizedBox(height: 20),

                // --- CAMPO EMAIL ---
                _buildInputLabel("CORREO ELECTRÓNICO"),
                TextField(
                  autocorrect: false,
                  controller: controller.emailC,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: RCColors.white),
                  decoration: _inputDecoration(
                    hint: "ejemplo@rcsync.com",
                    icon: Icons.alternate_email,
                  ),
                ),

                const SizedBox(height: 20),

                // --- CAMPO PASSWORD ---
                _buildInputLabel("CONTRASEÑA"),
                Obx(() => TextField(
                  autocorrect: false,
                  controller: controller.passwordC,
                  textInputAction: TextInputAction.done,
                  obscureText: controller.isHidden.value,
                  style: const TextStyle(color: RCColors.white),
                  decoration: _inputDecoration(
                    hint: "••••••••",
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      onPressed: () => controller.isHidden.toggle(),
                      icon: Icon(
                        controller.isHidden.isTrue
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )),

                const SizedBox(height: 40),

                // --- BOTÓN REGISTRAR ---
                Obx(() => _buildMainButton(
                  label: controller.isLoading.isFalse ? "CREAR CUENTA" : "REGISTRANDO...",
                  color: RCColors.orange,
                  onPressed: () {
                    if (controller.isLoading.isFalse) {
                      controller.signUp();
                    }
                  },
                )),

                const SizedBox(height: 15),

                // --- BOTÓN VOLVER ---
                _buildMainButton(
                  label: "VOLVER AL LOGIN",
                  color: Colors.transparent,
                  isOutline: true,
                  onPressed: () => Get.back(),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MISMOS HELPERS ESTÉTICOS QUE EN EL LOGIN ---

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: RCColors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: RCColors.white.withOpacity(0.3)),
      prefixIcon: Icon(icon, color: RCColors.orange, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: RCColors.background,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: RCColors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RCColors.orange, width: 2),
      ),
    );
  }

  Widget _buildMainButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isOutline = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutline ? Colors.transparent : color,
          foregroundColor: RCColors.white,
          elevation: isOutline ? 0 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutline ? const BorderSide(color: Colors.white) : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
    );
  }
}