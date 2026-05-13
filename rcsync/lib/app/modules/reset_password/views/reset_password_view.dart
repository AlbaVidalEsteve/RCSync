import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/app/modules/reset_password/controllers/reset_password_controller.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: RCColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          children: [
            const SizedBox(height: 40),

            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/images/logo.png',
                height: 180,
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'reset_title'.tr,
              style: TextStyle(
                color: RCColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'reset_info'.tr,
              style: TextStyle(
                color: RCColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            _buildInputLabel('reset_new_password'.tr),
            Obx(() => TextField(
              autocorrect: false,
              controller: controller.passwordC,
              textInputAction: TextInputAction.next,
              obscureText: controller.isHiddenNew.value,
              style: TextStyle(color: RCColors.textPrimary),
              decoration: _inputDecoration(
                hint: '••••••••',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  onPressed: () => controller.isHiddenNew.toggle(),
                  icon: Icon(
                    controller.isHiddenNew.isTrue
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: RCColors.iconSecondary,
                  ),
                ),
              ),
            )),

            const SizedBox(height: 8),
            Obx(() => _buildStrengthBar(controller.passwordStrength.value)),
            const SizedBox(height: 16),

            _buildInputLabel('reset_confirm_password'.tr),
            Obx(() => TextField(
              autocorrect: false,
              controller: controller.confirmC,
              textInputAction: TextInputAction.done,
              obscureText: controller.isHiddenConfirm.value,
              onSubmitted: (_) => controller.updatePassword(),
              style: TextStyle(color: RCColors.textPrimary),
              decoration: _inputDecoration(
                hint: '••••••••',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  onPressed: () => controller.isHiddenConfirm.toggle(),
                  icon: Icon(
                    controller.isHiddenConfirm.isTrue
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: RCColors.iconSecondary,
                  ),
                ),
              ),
            )),

            const SizedBox(height: 32),

            Obx(() => _buildMainButton(
              label: controller.isLoading.isFalse
                  ? 'reset_btn'.tr
                  : 'loading'.tr,
              onPressed: controller.isLoading.isFalse
                  ? controller.updatePassword
                  : () {},
            )),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthBar(int strength) {
    if (strength == 0) return const SizedBox.shrink();
    final labels = ['', 'reg_pass_weak'.tr, 'reg_pass_medium'.tr, 'reg_pass_strong'.tr];
    final colors = [Colors.transparent, Colors.redAccent, Colors.orangeAccent, Colors.green];
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strength / 3,
              minHeight: 4,
              backgroundColor: RCColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(colors[strength]),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          labels[strength],
          style: TextStyle(color: colors[strength], fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: RCColors.textSecondary.withValues(alpha: 0.4)),
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
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
              colors: [RCColors.orange, Color(0xFFF68B28)]),
          boxShadow: [
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
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
