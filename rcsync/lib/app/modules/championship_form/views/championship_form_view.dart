import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import '../controllers/championship_form_controller.dart';

class ChampionshipFormView extends GetView<ChampionshipFormController> {
  const ChampionshipFormView({super.key});

  @override
  Widget build(BuildContext context) {
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
          decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [RCColors.orange, Color(0xFFF68B28)])
          ),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: controller.nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nombre del Campeonato',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true, fillColor: const Color(0xFF1A222D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButtonFormField<int>(
                    value: controller.selectedYear.value,
                    dropdownColor: const Color(0xFF1A222D),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Año',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true, fillColor: const Color(0xFF1A222D),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    items: List.generate(5, (index) => DateTime.now().year + index).map((year) {
                      return DropdownMenuItem(value: year, child: Text(year.toString()));
                    }).toList(),
                    onChanged: (v) => controller.selectedYear.value = v!,
                  )),
                ),
                const SizedBox(width: 20),
                Obx(() => Row(
                  children: [
                    const Text('Activo', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Switch(
                        value: controller.isActive.value,
                        onChanged: (v) => controller.isActive.value = v,
                        activeColor: RCColors.orange
                    ),
                  ],
                ))
              ],
            ),
            const SizedBox(height: 30),
            const Text('Categorías', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.categoryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Añadir categoría (ej. GT)',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true, fillColor: const Color(0xFF1A222D),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                    icon: const Icon(Icons.add_circle, color: RCColors.orange, size: 40),
                    onPressed: controller.addCategory
                )
              ],
            ),
            const SizedBox(height: 20),

            // Nueva vista de la lista de categorías con soporte para PDFs
            Obx(() => Column(
              children: controller.categoriesList.asMap().entries.map((entry) {
                int index = entry.key;
                var cat = entry.value;

                bool hasNewPdf = cat['pdf_file'] != null;
                bool hasExistingUrl = cat['rulebook_url'] != null;

                return Card(
                  color: const Color(0xFF1A222D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(cat['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      hasNewPdf ? '📄 PDF listo para subir'
                          : (hasExistingUrl ? '✅ Reglamento subido' : '⚠️ Sin reglamento adjunto'),
                      style: TextStyle(
                          color: hasNewPdf ? RCColors.orange : (hasExistingUrl ? Colors.green : Colors.white54),
                          fontSize: 12
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Adjuntar Reglamento (PDF)',
                          icon: Icon(hasExistingUrl && !hasNewPdf ? Icons.edit_document : Icons.picture_as_pdf, color: RCColors.orange),
                          onPressed: () => controller.pickPdfForCategory(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => controller.removeCategory(index),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),

            const SizedBox(height: 40),
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