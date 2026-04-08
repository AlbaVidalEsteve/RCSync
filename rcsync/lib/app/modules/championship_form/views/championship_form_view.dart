import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import '../controllers/championship_form_controller.dart';

class ChampionshipFormView extends StatelessWidget {
  const ChampionshipFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChampionshipFormController());

    return Scaffold(
      backgroundColor: RCColors.background,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Obx(() => Text(
          controller.isEditing.value ? 'Modificar Campeonato' : 'Nuevo Campeonato',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [RCColors.orange, Color(0xFFF68B28)])),
        ),
      ),
      body: Form( // <-- YA NO ESTÁ ENVUELTO EN OBX
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: controller.nameController, style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Nombre del Campeonato', labelStyle: const TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: RCColors.orange))),
              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 20),
            Obx(() => Row(
              children: [
                const Text('Año:', style: TextStyle(color: Colors.white, fontSize: 16)), const SizedBox(width: 20),
                DropdownButton<int>(
                  value: controller.selectedYear.value, dropdownColor: const Color(0xFF1A222D), style: const TextStyle(color: Colors.white, fontSize: 16),
                  underline: Container(height: 1, color: Colors.white.withOpacity(0.3)),
                  items: List.generate(5, (i) => DateTime.now().year + i).map((year) => DropdownMenuItem(value: year, child: Text(year.toString()))).toList(),
                  onChanged: (val) { if (val != null) controller.selectedYear.value = val; },
                ),
              ],
            )),
            const SizedBox(height: 10),
            Obx(() => SwitchListTile(
              contentPadding: EdgeInsets.zero, title: const Text('Activo', style: TextStyle(color: Colors.white)), subtitle: const Text('Se mostrará a los pilotos para inscribirse', style: TextStyle(color: Colors.white54, fontSize: 12)),
              activeThumbColor: RCColors.orange, value: controller.isActive.value, onChanged: (val) => controller.isActive.value = val,
            )),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton.icon(
              onPressed: controller.pickPdf, icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: Text(controller.selectedFile.value == null ? 'Subir Reglamento PDF (Opcional)' : controller.selectedFile.value!.name, style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            )),
            const SizedBox(height: 30),
            const Text('Categorías', style: TextStyle(color: RCColors.orange, fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: TextField(controller: controller.categoryController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Ej: GT SUPERSTOCK', hintStyle: const TextStyle(color: Colors.white30), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: RCColors.orange))))),
                IconButton(icon: const Icon(Icons.add_box, color: RCColors.orange, size: 40), onPressed: controller.addCategory)
              ],
            ),
            const SizedBox(height: 20),
            Obx(() => Wrap(spacing: 10, runSpacing: 10, children: controller.categoriesList.map((cat) => Chip(label: Text(cat, style: const TextStyle(color: Colors.white)), backgroundColor: RCColors.orange.withOpacity(0.8), deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18), onDeleted: () => controller.removeCategory(cat), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none))).toList())),
            const SizedBox(height: 40),

            // --- EL BOTÓN REACTIVO DE GUARDAR ---
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.saveChampionship,
              style: ElevatedButton.styleFrom(
                backgroundColor: RCColors.orange, padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                disabledBackgroundColor: RCColors.orange.withOpacity(0.5),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(controller.isEditing.value ? 'Guardar Cambios' : 'Crear Campeonato', style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ))
          ],
        ),
      ),
    );
  }
}