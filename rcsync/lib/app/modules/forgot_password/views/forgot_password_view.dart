import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/app/modules/forgot_password/controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: RCColors.background,
      appBar: AppBar(
        backgroundColor: RCColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: RCColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          children: [
            const SizedBox(height: 20),

            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/images/logo.png',
                height: 180,
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'forgot_password_title'.tr,
              style: TextStyle(
                color: RCColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'forgot_password_info'.tr,
              style: TextStyle(
                color: RCColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            _buildInputLabel('login_email_label'.tr),
            TextField(
              autocorrect: false,
              controller: controller.emailC,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.sendResetEmail(),
              style: TextStyle(color: RCColors.textPrimary),
              decoration: _inputDecoration(
                hint: 'hint_email'.tr,
                icon: Icons.alternate_email,
              ),
            ),

            const SizedBox(height: 32),

            Obx(() => _buildMainButton(
              label: controller.isLoading.isFalse
                  ? 'forgot_password_btn'.tr
                  : 'loading'.tr,
              onPressed: controller.isLoading.isFalse
                  ? controller.sendResetEmail
                  : () {},
            )),

            const SizedBox(height: 15),

            _buildMainButton(
              label: 'back_to_login'.tr,
              isSecondary: true,
              onPressed: () => Get.back(),
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

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: RCColors.textSecondary.withValues(alpha: 0.4)),
      prefixIcon: Icon(icon, color: RCColors.orange, size: 20),
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
          boxShadow: isSecondary
              ? null
              : [
                  BoxShadow(
                    color: RCColors.orange.withValues(alpha: 0.3),
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
