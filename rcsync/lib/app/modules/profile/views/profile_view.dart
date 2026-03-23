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
              height: 200, // Aumentado para dar más aire
              padding: const EdgeInsets.only(top: 60), // Bajamos el texto desde arriba
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
                    "MI PERFIL",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 20), // <--- ESTE ES EL PADDING EXTRA DEBAJO DEL TEXTO
                ],
              ),
            ),

            // AGRUPAMOS LA TARJETA Y EL BOTÓN DE CERRAR SESIÓN PARA QUE SUBAN JUNTOS
            Transform.translate(
              offset: const Offset(0, -70), // Ajustado para que encaje con el nuevo header
              child: Column(
                children: [
                  // CARD DE PERFIL (Estilo Oscuro)
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

                        // CAMPO: NOMBRE
                        _buildInputField(
                          label: "Nombre Completo",
                          controller: controller.nameC,
                          icon: Icons.person_outline,
                        ),

                        // CAMPO: EMAIL
                        _buildInputField(
                          label: "Correo Electrónico",
                          controller: controller.emailC,
                          icon: Icons.email_outlined,
                        ),

                        // CAMPO: ROL (BLOQUEADO)
                        _buildRoleField(),

                        const Divider(color: Colors.white10, height: 25),

                        // SECCIÓN: TRANSPONDERS
                        _buildTranspondersSection(),

                        const SizedBox(height: 25),

                        // BOTÓN EDITAR / GUARDAR
                        Obx(() => SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: const LinearGradient(
                                colors: [RCColors.orange, Color(0xFFF68B28)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: RCColors.orange.withAlpha(76),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (controller.isEditMode.value) {
                                  controller.updateProfile();
                                } else {
                                  controller.toggleEdit();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: Text(
                                controller.isEditMode.value ? "GUARDAR CAMBIOS" : "EDITAR PERFIL",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // BOTÓN CERRAR SESIÓN
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
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white.withAlpha(13), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: RCColors.orange, width: 1),
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
              border: Border.all(color: RCColors.darkBlue.withAlpha(100)),
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

  Widget _buildTranspondersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.sensors, size: 16, color: Colors.white70),
            SizedBox(width: 8),
            Text("Mis Transponders", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 10),

        // Input para añadir nuevo
        Obx(() {
          if (!controller.isEditMode.value) return const SizedBox();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.newTransponderC,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Número de transponder...",
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: RCColors.background.withAlpha(128),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => controller.addTransponder(),
                  icon: const Icon(Icons.add_circle, color: RCColors.orange, size: 35),
                )
              ],
            ),
          );
        }),

        // Listado de transponders
        Obx(() => Column(
          children: controller.transponders.map((transponder) {
            String val = transponder['number'].toString();
            String id = transponder['id_transponder'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: RCColors.background.withAlpha(100),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(13)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tag, color: RCColors.orange, size: 18),
                      const SizedBox(width: 10),
                      Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
                    ],
                  ),
                  if (controller.isEditMode.value)
                    GestureDetector(
                      onTap: () => controller.removeTransponder(id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        )),
      ],
    );
  }
}
