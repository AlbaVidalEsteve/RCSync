import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/rc_colors.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RCColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              children: [
                const SizedBox(height: 20),
                
                // --- SELECCIÓN DE FOTO DE PERFIL ---
                Center(
                  child: Stack(
                    children: [
                      Obx(() => CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withAlpha(25),
                        backgroundImage: controller.profileImage.value != null 
                          ? FileImage(controller.profileImage.value!) 
                          : null,
                        child: controller.profileImage.value == null 
                          ? const Icon(Icons.person, size: 60, color: Colors.white24) 
                          : null,
                      )),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => controller.pickImage(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: RCColors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- CAMPO NOMBRE COMPLETO ---
                _buildInputLabel("NOMBRE Y APELLIDO"),
                TextField(
                  controller: controller.fullNameC,
                  style: const TextStyle(color: RCColors.white),
                  decoration: _inputDecoration(hint: "Tu nombre completo", icon: Icons.person_outline),
                ),

                const SizedBox(height: 20),

                // --- CAMPO EMAIL ---
                _buildInputLabel("CORREO ELECTRÓNICO"),
                TextField(
                  controller: controller.emailC,
                  style: const TextStyle(color: RCColors.white),
                  decoration: _inputDecoration(hint: "ejemplo@rcsync.com", icon: Icons.alternate_email),
                ),

                const SizedBox(height: 20),

                // --- CAMPO PASSWORD ---
                _buildInputLabel("CONTRASEÑA"),
                Obx(() => TextField(
                  controller: controller.passwordC,
                  obscureText: controller.isHidden.value,
                  style: const TextStyle(color: RCColors.white),
                  decoration: _inputDecoration(
                    hint: "••••••••", 
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      onPressed: () => controller.isHidden.toggle(),
                      icon: Icon(controller.isHidden.isTrue ? Icons.visibility_off : Icons.visibility, color: Colors.white24),
                    ),
                  ),
                )),

                const SizedBox(height: 20),

                // --- CAMPO CONFIRMAR PASSWORD ---
                _buildInputLabel("CONFIRMAR CONTRASEÑA"),
                Obx(() => TextField(
                  controller: controller.confirmPasswordC,
                  obscureText: controller.isHidden.value,
                  style: const TextStyle(color: RCColors.white),
                  decoration: _inputDecoration(hint: "Repite tu contraseña", icon: Icons.lock_reset),
                )),

                const SizedBox(height: 40),

                // --- BOTÓN REGISTRAR ---
                Obx(() => _buildMainButton(
                  label: controller.isLoading.isFalse ? "CREAR CUENTA" : "REGISTRANDO...",
                  color: RCColors.orange,
                  onPressed: () => controller.signUp(),
                )),

                const SizedBox(height: 15),

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

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(color: RCColors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: RCColors.white.withAlpha(76)),
      prefixIcon: Icon(icon, color: RCColors.orange, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withAlpha(13),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: RCColors.orange, width: 2)),
    );
  }

  Widget _buildMainButton({required String label, required Color color, required VoidCallback onPressed, bool isOutline = false}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutline ? Colors.transparent : color,
          foregroundColor: RCColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutline ? const BorderSide(color: Colors.white) : BorderSide.none,
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
