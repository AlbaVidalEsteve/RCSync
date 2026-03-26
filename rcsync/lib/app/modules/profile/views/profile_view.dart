import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/rc_colors.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: const Column(
                children: [
                  Text(
                    "Mi Perfil",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            // CUERPO DEL PERFIL
            Transform.translate(
              offset: const Offset(0, -70),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: RCColors.cardDark,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
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
                            Obx(() => Container(
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
                                    ? const Icon(Icons.person, size: 55, color: Colors.white24)
                                    : null,
                              ),
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
                        const SizedBox(height: 20),

                        // CAMPOS DE TEXTO
                        _buildInputField(
                          label: "Nombre Completo",
                          controller: controller.nameC,
                          icon: Icons.person_outline,
                        ),
                        _buildInputField(
                          label: "Correo Electrónico",
                          controller: controller.emailC,
                          icon: Icons.email_outlined,
                        ),
                        _buildRoleField(),

                        const Divider(color: Colors.white10, height: 25),

                        // SECCIÓN TRANSPONDERS DESPLEGABLE
                        _buildTranspondersCollapsible(),

                        const SizedBox(height: 25),

                        // BOTONES DE ACCIÓN (EDITAR / GUARDAR-CANCELAR)
                        Obx(() => controller.isEditMode.value
                            ? Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      text: "CANCELAR",
                                      onPressed: () => controller.cancelEdit(),
                                      isSecondary: true,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _buildActionButton(
                                      text: "GUARDAR",
                                      onPressed: () => controller.updateProfile(),
                                    ),
                                  ),
                                ],
                              )
                            : _buildActionButton(
                                text: "EDITAR PERFIL",
                                onPressed: () => controller.toggleEdit(),
                              )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // CERRAR SESIÓN
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: TextButton.icon(
                        onPressed: () => controller.logout(),
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: const Text(
                          "Cerrar Sesión",
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent.withAlpha(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
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
          color: isSecondary ? Colors.white10 : null,
          boxShadow: isSecondary ? null : [
            BoxShadow(
              color: RCColors.orange.withAlpha(76),
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
              color: isSecondary ? Colors.white70 : Colors.white,
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
            if (icon != null) Icon(icon, size: 16, color: Colors.white70),
            if (icon != null) const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => TextField(
          controller: controller,
          enabled: this.controller.isEditMode.value,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: RCColors.background.withAlpha(128),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        )),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildRoleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.stars_outlined, size: 16, color: Colors.white70),
            SizedBox(width: 8),
            Text("Rol de Usuario", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          String role = controller.profileData['rol'] ?? 'Piloto';
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withAlpha(50),
              borderRadius: BorderRadius.circular(15),
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
    return Obx(() => Column(
      children: [
        GestureDetector(
          onTap: () => controller.isTranspondersExpanded.value = !controller.isTranspondersExpanded.value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.sensors, size: 16, color: Colors.white70),
                    SizedBox(width: 8),
                    Text("Mis Transponders", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                Icon(
                  controller.isTranspondersExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white70,
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
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Número",
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: RCColors.background.withAlpha(128),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.newTransponderLabelC,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Nombre",
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: RCColors.background.withAlpha(128),
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
                  color: RCColors.background.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: controller.isEditMode.value && controllers != null
                  ? Row(
                      children: [
                        Expanded(child: TextField(
                          controller: controllers["number"],
                          enabled: isNewLocal, // SOLO EDITABLE SI ES NUEVO (NO GUARDADO EN DB AÚN)
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: isNewLocal ? Colors.white : Colors.white38, 
                            fontSize: 14
                          ),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        )),
                        const VerticalDivider(color: Colors.white24),
                        Expanded(child: TextField(
                          controller: controllers["label"],
                          style: const TextStyle(color: Colors.white, fontSize: 14),
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
                        Text("${t['number']} - ${t['label']}", style: const TextStyle(color: Colors.white, fontSize: 15)),
                        const Icon(Icons.tag, color: RCColors.orange, size: 16),
                      ],
                    ),
              );
            }).toList(),
          ),
        ]
      ],
    ));
  }
}
