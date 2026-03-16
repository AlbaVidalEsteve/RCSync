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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6A11CB), Color(0xFFF24E02)],
                ),
              ),
              child: const Center(
                child: Text(
                  "Perfil",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // CARD DE PERFIL
            Transform.translate(
              offset: const Offset(0, -50),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // FOTO DE PERFIL
                    Stack(
                      children: [
                        Obx(() => CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: controller.profileData['image_profile'] != null
                              ? NetworkImage(controller.profileData['image_profile'])
                              : null,
                          child: controller.profileData['image_profile'] == null
                              ? Icon(Icons.person, size: 60, color: Colors.grey[400])
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
                                color: Color(0xFFF24E02),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // CAMPO: NOMBRE
                    _buildInputField(
                      label: "Nombre",
                      controller: controller.nameC,
                      icon: null,
                    ),

                    // CAMPO: EMAIL
                    _buildInputField(
                      label: "Email",
                      controller: controller.emailC,
                      icon: Icons.email_outlined,
                    ),

                    // CAMPO: ROL (BLOQUEADO)
                    _buildRoleField(),

                    const SizedBox(height: 20),

                    // SECCIÓN: TRANSPONDERS
                    _buildTranspondersSection(),

                    const SizedBox(height: 30),

                    // BOTÓN EDITAR / GUARDAR
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6DD5FA), Color(0xFFF24E02)],
                          ),
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
                            controller.isEditMode.value ? "GUARDAR CAMBIOS" : "EDITAR",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),

            // BOTÓN CERRAR SESIÓN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () => controller.logout(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE),
                    side: const BorderSide(color: Colors.transparent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "Cerrar Sesión",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
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
            if (icon != null) Icon(icon, size: 16, color: Colors.grey[600]),
            if (icon != null) const SizedBox(width: 5),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => TextField(
          controller: controller,
          enabled: this.controller.isEditMode.value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRoleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bookmark_outline, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 5),
            Text("Rol", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          String role = controller.profileData['rol'] ?? 'Piloto';
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.withAlpha(50)),
            ),
            child: Text(
              role.toUpperCase(),
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTranspondersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.credit_card, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 5),
            Text("Transponders", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        
        // Input para añadir nuevo
        Obx(() {
          if (!controller.isEditMode.value) return const SizedBox();
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.newTransponderC,
                  decoration: InputDecoration(
                    hintText: "Nuevo ID...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => controller.addTransponder(),
                icon: const Icon(Icons.add_circle, color: Color(0xFFF24E02), size: 30),
              )
            ],
          );
        }),
        
        const SizedBox(height: 10),

        // Listado de transponders
        Obx(() => Column(
          children: controller.transponders.map((transponder) {
            String val = transponder['number'].toString();
            String id = transponder['id_transponder'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(val, style: const TextStyle(fontWeight: FontWeight.w500)),
                  if (controller.isEditMode.value)
                    GestureDetector(
                      onTap: () => controller.removeTransponder(id),
                      child: const Icon(Icons.close, color: Colors.red, size: 18),
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
