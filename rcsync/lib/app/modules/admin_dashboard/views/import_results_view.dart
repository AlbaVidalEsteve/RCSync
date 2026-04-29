import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/app/data/models/race_event_model.dart';
import 'package:rcsync/app/modules/admin_dashboard/controllers/import_results_controller.dart';

class ImportResultsView extends GetView<ImportResultsController> {
  const ImportResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ImportResultsController());

    return Scaffold(
      backgroundColor: RCColors.background,
      body: Column(
        children: [
          // Header standard
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 180,
                padding: const EdgeInsets.only(top: 60),
                alignment: Alignment.topCenter,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [RCColors.orange, Color(0xFFF68B28)],
                  ),
                ),
                child: Text(
                  'import_results'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // Botón de volver
              Positioned(
                top: 50,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.black38,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
            ],
          ),

          // Contenido
          Expanded(
            child: SingleChildScrollView(
              child: Transform.translate(
                offset: const Offset(0, -60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // tarjeta seleccion
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: RCColors.card,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(Get.isDarkMode ? 0.3 : 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            // Seleccionar Evento
                            _buildSelectionField(
                              label: 'select_event'.tr,
                              icon: Icons.event,
                              child: Obx(() => DropdownButtonFormField<RaceEventModel>(
                                value: controller.selectedEvent.value,
                                dropdownColor: RCColors.card,
                                style: TextStyle(color: RCColors.textPrimary, fontSize: 14),
                                decoration: _inputDecoration(),
                                items: controller.events.map((event) {
                                  return DropdownMenuItem(
                                    value: event,
                                    child: Text(event.name, style: TextStyle(color: RCColors.textPrimary)),
                                  );
                                }).toList(),
                                onChanged: (value) => controller.onEventSelected(value),
                                hint: Text('select_event'.tr, style: TextStyle(color: RCColors.textSecondary.withOpacity(0.5))),
                              )),
                            ),
                            const SizedBox(height: 20),

                            // Seleccionar Categoría
                            _buildSelectionField(
                              label: 'select_category'.tr,
                              icon: Icons.category,
                              child: Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
                                value: controller.selectedCategory.value,
                                dropdownColor: RCColors.card,
                                style: TextStyle(color: RCColors.textPrimary, fontSize: 14),
                                decoration: _inputDecoration(),
                                items: controller.availableCategories.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat['name'], style: TextStyle(color: RCColors.textPrimary)),
                                  );
                                }).toList(),
                                onChanged: (value) => controller.selectedCategory.value = value,
                                hint: Text('select_category'.tr, style: TextStyle(color: RCColors.textSecondary.withOpacity(0.5))),
                              )),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // tarjeta instrucciones
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: RCColors.card,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(Get.isDarkMode ? 0.3 : 0.1),
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
                                Icon(Icons.info_outline, color: RCColors.orange, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'import_instructions'.tr,
                                  style: TextStyle(
                                    color: RCColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _buildInstructionItem('• ${'file_format_info'.tr}'),
                            _buildInstructionItem('• ${'headers_info'.tr}'),
                            _buildInstructionItem('• ${'columns_info'.tr}'),
                            _buildInstructionItem('• ${'matching_info'.tr}'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // boton importar (estilo rcbutton)
                      Obx(() => SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: controller.isLoading.value || controller.selectedEvent.value == null || controller.selectedCategory.value == null
                                ? null
                                : const LinearGradient(colors: [RCColors.orange, Color(0xFFF68B28)]),
                            color: controller.isLoading.value || controller.selectedEvent.value == null || controller.selectedCategory.value == null
                                ? RCColors.card.withOpacity(0.5)
                                : null,
                            boxShadow: controller.isLoading.value || controller.selectedEvent.value == null || controller.selectedCategory.value == null
                                ? null
                                : [
                              BoxShadow(
                                color: RCColors.orange.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: controller.selectedEvent.value != null && controller.selectedCategory.value != null && !controller.isLoading.value
                                ? () => controller.pickAndImportExcel()
                                : null,
                            icon: controller.isLoading.value
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : Icon(Icons.upload_file, color: Colors.white),
                            label: Text(
                              controller.isLoading.value ? 'loading'.tr : 'select_excel_file'.tr,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                      )),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: RCColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: RCColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: RCColors.background.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: RCColors.divider, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: RCColors.orange, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(color: RCColors.textSecondary, fontSize: 12, height: 1.4),
      ),
    );
  }
}