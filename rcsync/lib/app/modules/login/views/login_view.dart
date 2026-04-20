import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/rc_colors.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RCColors.background,
      body: Stack(
        children: [
          // --- CAPA DE FONDO ---
          Column(
            children: [
              Expanded(
                child: Container(color: RCColors.background),
              ),
            ],
          ),

          // --- CONTENIDO ---
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              children: [
                const SizedBox(height: 40),

                // --- LOGO ---
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/images/logo_rcsync.jpeg',
                    height: 500,
                  ),
                ),

                const SizedBox(height: 40),

                // --- INPUT EMAIL ---
                _buildInputLabel("login_email_label".tr),
                TextField(
                  autocorrect: false,
                  controller: controller.emailC,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: RCColors.textPrimary),
                  decoration: _inputDecoration(
                    hint: "ejemplo@rcsync.com",
                    icon: Icons.alternate_email,
                  ),
                ),

                const SizedBox(height: 20),

                // --- INPUT PASSWORD ---
                _buildInputLabel("login_password_label".tr),
                Obx(() => TextField(
                  autocorrect: false,
                  controller: controller.passwordC,
                  textInputAction: TextInputAction.done,
                  obscureText: controller.isHidden.value,
                  style: TextStyle(color: RCColors.textPrimary),
                  decoration: _inputDecoration(
                    hint: "••••••••",
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      onPressed: () => controller.isHidden.toggle(),
                      icon: Icon(
                        controller.isHidden.isTrue
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: RCColors.iconSecondary,
                      ),
                    ),
                  ),
                )),

                const SizedBox(height: 40),

                // --- BOTÓN ACCEDER ---
                Obx(() => _buildMainButton(
                  label: controller.isLoading.isFalse ? "login_btn".tr : "login_loading".tr,
                  color: RCColors.orange,
                  onPressed: () {
                    if (controller.isLoading.isFalse) {
                      controller.login();
                    }
                  },
                )),

                const SizedBox(height: 15),

                // --- BOTÓN REGISTRARSE ---
                _buildMainButton(
                  label: "login_register_btn".tr,
                  color: Colors.transparent,
                  isOutline: true,
                  onPressed: () => Get.toNamed('/register'),
                ),

                const SizedBox(height: 20),
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
      child: Text(
        text,
        style: TextStyle(
          color: RCColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: RCColors.textSecondary.withOpacity(0.5)),
      prefixIcon: Icon(icon, color: RCColors.orange, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: RCColors.card,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: RCColors.divider),
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
          foregroundColor: isOutline ? RCColors.textPrimary : Colors.white,
          elevation: isOutline ? 0 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutline ? BorderSide(color: RCColors.textPrimary) : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
