import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/app/modules/register/controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios de tema
    Theme.of(context);

    return Obx(() => Scaffold(
      backgroundColor: RCColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: RCColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "register_title".tr,
          style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          children: [
            const SizedBox(height: 10),
            
            // seleccionar foto perfil
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: RCColors.orange, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: RCColors.card,
                      backgroundImage: controller.profileImage.value != null 
                        ? FileImage(controller.profileImage.value!) 
                        : null,
                      child: controller.profileImage.value == null 
                        ? Icon(Icons.person, size: 60, color: RCColors.iconSecondary) 
                        : null,
                    ),
                  ),
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

            // campo nombre completo
            _buildInputLabel("register_name_label".tr),
            TextField(
              controller: controller.fullNameC,
              style: TextStyle(color: RCColors.textPrimary),
              decoration: _inputDecoration(hint: "hint_name".tr, icon: Icons.person_outline),
            ),

            const SizedBox(height: 20),

            // campo email
            _buildInputLabel("login_email_label".tr),
            TextField(
              controller: controller.emailC,
              style: TextStyle(color: RCColors.textPrimary),
              decoration: _inputDecoration(hint: "hint_email".tr, icon: Icons.alternate_email),
            ),

            const SizedBox(height: 20),

            // campo password
            _buildInputLabel("login_password_label".tr),
            Obx(() => TextField(
              controller: controller.passwordC,
              obscureText: controller.isHidden.value,
              style: TextStyle(color: RCColors.textPrimary),
              decoration: _inputDecoration(
                hint: "••••••••", 
                icon: Icons.lock_outline,
                suffix: IconButton(
                  onPressed: () => controller.isHidden.toggle(),
                  icon: Icon(
                    controller.isHidden.isTrue ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                    color: RCColors.iconSecondary
                  ),
                ),
              ),
            )),

            const SizedBox(height: 20),

            // campo confirmar password
            _buildInputLabel("register_confirm_password".tr),
            Obx(() => TextField(
              controller: controller.confirmPasswordC,
              obscureText: controller.isHidden.value,
              style: TextStyle(color: RCColors.textPrimary),
              decoration: _inputDecoration(hint: "hint_password_confirm".tr, icon: Icons.lock_reset),
            )),

            const SizedBox(height: 40),

            // boton registrar
            Obx(() => _buildMainButton(
              label: controller.isLoading.isFalse ? "register_btn".tr : "registering".tr,
              onPressed: () => controller.signUp(),
            )),

            const SizedBox(height: 15),

            _buildMainButton(
              label: "back_to_login".tr,
              isSecondary: true,
              onPressed: () => Get.back(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ));
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
        )
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
        borderSide: BorderSide(color: RCColors.divider)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15), 
        borderSide: const BorderSide(color: RCColors.orange, width: 2)
      ),
    );
  }

  Widget _buildMainButton({
    required String label, 
    required VoidCallback onPressed, 
    bool isSecondary = false
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
