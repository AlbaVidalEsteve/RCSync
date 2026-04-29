import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/app/modules/login/controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios de tema
    Theme.of(context);

    return Scaffold(
      backgroundColor: RCColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          children: [
            const SizedBox(height: 40),

            // logo
            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/images/logo.png',
                height: 250,
              ),
            ),

            const SizedBox(height: 40),

            // input email
            _buildInputLabel("login_email_label".tr),
            TextField(
              autocorrect: false,
              controller: controller.emailC,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: RCColors.textPrimary),
              decoration: _inputDecoration(
                hint: "hint_email".tr,
                icon: Icons.alternate_email,
              ),
            ),

            const SizedBox(height: 20),

            // input pass
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

            // boton acceder
            Obx(() => _buildMainButton(
              label: controller.isLoading.isFalse ? "login_btn".tr : "loading".tr,
              onPressed: () {
                if (controller.isLoading.isFalse) {
                  controller.login();
                }
              },
            )),

            const SizedBox(height: 15),

            // boton registro
            _buildMainButton(
              label: "create_account_btn".tr,
              isSecondary: true,
              onPressed: () => Get.toNamed('/register'),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: RCColors.textSecondary,
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
      hintStyle: TextStyle(color: RCColors.textSecondary.withOpacity(0.4)),
      prefixIcon: Icon(icon, color: RCColors.orange, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: RCColors.card,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: RCColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: RCColors.orange, width: 2),
      ),
    );
  }

  Widget _buildMainButton({
    required String label,
    required VoidCallback onPressed,
    bool isSecondary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: isSecondary 
            ? null 
            : const LinearGradient(colors: [RCColors.orange, Color(0xFFF68B28)]),
          color: isSecondary ? RCColors.card : null,
          border: isSecondary ? Border.all(color: RCColors.divider) : null,
          boxShadow: isSecondary ? null : [
            BoxShadow(
              color: RCColors.orange.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSecondary ? RCColors.textSecondary : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
