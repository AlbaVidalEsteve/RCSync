import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/rc_colors.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios de tema
    Theme.of(context);

    return Obx(() => Scaffold(
      backgroundColor: RCColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER CON GRADIENTE
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.only(top: 60),
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [RCColors.orange, Color(0xFFF68B28)],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "profile_title".tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // CUERPO DEL PERFIL
            Transform.translate(
              offset: const Offset(0, -70),
              child: Column(
                children: [
                  // TARJETA DE DATOS DE PERFIL
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: RCColors.card,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // FOTO DE PERFIL
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: RCColors.orange, width: 3),
                              ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: RCColors.background,
                                backgroundImage: controller.profileData['image_profile'] != null
                                    ? NetworkImage(controller.profileData['image_profile'])
                                    : null,
                                child: controller.profileData['image_profile'] == null
                                    ? Icon(Icons.person, size: 55, color: RCColors.iconSecondary)
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
                        const SizedBox(height: 20),

                        // CAMPOS DE TEXTO
                        _buildInputField(
                          label: "full_name".tr,
                          controller: controller.nameC,
                          icon: Icons.person_outline,
                        ),
                        _buildInputField(
                          label: "email".tr,
                          controller: controller.emailC,
                          icon: Icons.email_outlined,
                        ),
                        _buildRoleField(),

                        Divider(color: RCColors.divider, height: 25),

                        // SECCIÓN TRANSPONDERS DESPLEGABLE
                        _buildTranspondersCollapsible(),

                        const SizedBox(height: 25),

                        // BOTONES DE ACCIÓN (EDITAR / GUARDAR-CANCELAR)
                        controller.isEditMode.value
                            ? Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      text: "cancel".tr,
                                      onPressed: () => controller.cancelEdit(),
                                      isSecondary: true,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _buildActionButton(
                                      text: "save".tr,
                                      onPressed: () => controller.updateProfile(),
                                    ),
                                  ),
                                ],
                              )
                            : _buildActionButton(
                                text: "edit_profile".tr,
                                onPressed: () => controller.toggleEdit(),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TARJETA DE SETTINGS
                  _buildSettingsCard(),

                  const SizedBox(height: 20),

                  // CERRAR SESIÓN
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: TextButton.icon(
                        onPressed: () => controller.logout(),
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: Text(
                          "logout".tr,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Espacio extra para el bottom bar
          ],
        ),
      ),
    ));
  }

  Widget _buildSettingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RCColors.card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_outlined, color: RCColors.orange, size: 20),
              const SizedBox(width: 10),
              Text(
                "settings".tr,
                style: TextStyle(
                  color: RCColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // IDIOMA
          _buildDropdownField(
            label: "language".tr,
            icon: Icons.language,
            value: controller.selectedLanguage.value,
            items: controller.languages,
            onChanged: (val) => controller.changeLanguage(val),
          ),
          
          const SizedBox(height: 20),

          // TEMA
          _buildDropdownField(
            label: "theme".tr,
            icon: Icons.brightness_6_outlined,
            value: controller.selectedThemeName.value,
            items: controller.themeModes.keys.toList(),
            onChanged: (val) => controller.changeTheme(val),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: RCColors.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: RCColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: RCColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: RCColors.card,
              icon: Icon(Icons.keyboard_arrow_down, color: RCColors.textSecondary),
              style: TextStyle(color: RCColors.textPrimary, fontSize: 15),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required String text, required VoidCallback onPressed, bool isSecondary = false}) {
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
            text,
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

  Widget _buildInputField({required String label, required TextEditingController controller, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) Icon(icon, size: 16, color: RCColors.textSecondary),
            if (icon != null) const SizedBox(width: 8),
            Text(label, style: TextStyle(color: RCColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: this.controller.isEditMode.value,
          style: TextStyle(color: RCColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: RCColors.background.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildRoleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.stars_outlined, size: 16, color: RCColors.textSecondary),
            const SizedBox(width: 8),
            Text("role".tr, style: TextStyle(color: RCColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Builder(builder: (context) {
          String role = controller.profileData['rol'] ?? 'Piloto';
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_sharp, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 10),
                Text(
                  role.toUpperCase(),
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildTranspondersCollapsible() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => controller.isTranspondersExpanded.value = !controller.isTranspondersExpanded.value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.sensors, size: 16, color: RCColors.textSecondary),
                    const SizedBox(width: 8),
                    Text("transponders".tr, style: TextStyle(color: RCColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                Icon(
                  controller.isTranspondersExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: RCColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (controller.isTranspondersExpanded.value) ...[
          const SizedBox(height: 10),
          // Input nuevo
          if (controller.isEditMode.value) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.newTransponderNumberC,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: RCColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "ts_number".tr,
                      hintStyle: TextStyle(color: RCColors.textSecondary.withOpacity(0.4)),
                      filled: true,
                      fillColor: RCColors.background.withOpacity(0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.newTransponderLabelC,
                    style: TextStyle(color: RCColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "ts_name".tr,
                      hintStyle: TextStyle(color: RCColors.textSecondary.withOpacity(0.4)),
                      filled: true,
                      fillColor: RCColors.background.withOpacity(0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => controller.addTransponder(),
                  icon: const Icon(Icons.add_circle, color: RCColors.orange),
                )
              ],
            ),
            const SizedBox(height: 15),
          ],
          // Lista
          Column(
            children: controller.transponders.map((t) {
              String id = t["id_transponder"].toString();
              var controllers = controller.transponderControllers[id];
              bool isNewLocal = id.startsWith("temp_");
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: RCColors.background.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: RCColors.divider),
                ),
                child: controller.isEditMode.value && controllers != null
                  ? Row(
                      children: [
                        Expanded(child: TextField(
                          controller: controllers["number"],
                          enabled: isNewLocal,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: isNewLocal ? RCColors.textPrimary : RCColors.textSecondary, 
                            fontSize: 14
                          ),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        )),
                        const VerticalDivider(color: Colors.grey),
                        Expanded(child: TextField(
                          controller: controllers["label"],
                          style: TextStyle(color: RCColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        )),
                        GestureDetector(
                          onTap: () => controller.removeTransponder(id),
                          child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${t['number']} - ${t['label']}", 
                          style: TextStyle(color: RCColors.textPrimary, fontSize: 15)
                        ),
                        const Icon(Icons.tag, color: RCColors.orange, size: 16),
                      ],
                    ),
              );
            }).toList(),
          ),
        ]
      ],
    );
  }
}
