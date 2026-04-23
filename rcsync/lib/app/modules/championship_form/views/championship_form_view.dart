import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import '../controllers/championship_form_controller.dart';

class ChampionshipFormView extends GetView<ChampionshipFormController> {
  const ChampionshipFormView({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: RCColors.background,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // HEADER CON GRADIENTE (igual que home_screen)
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
                    controller.isEditing.value ? 'cha_edit'.tr : 'cha_new'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                // Botón de volver (círculo negro)
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
            // CONTENIDO CON OVERLAP (offset -60)
            Transform.translate(
              offset: const Offset(0, -60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // TARJETA DE FORMULARIO
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
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputField(
                              label: "cha_name".tr,
                              icon: Icons.emoji_events_outlined,
                              controller: controller.nameController,
                              validator: (v) => (v == null || v.isEmpty) ? 'required'.tr : null,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildProfileStyleDropdown<int>(
                                    label: "cha_year".tr,
                                    icon: Icons.calendar_today_outlined,
                                    value: controller.selectedYear.value,
                                    items: List.generate(10, (index) => DateTime.now().year - 5 + index).map((year) {
                                      return DropdownMenuItem(
                                        value: year,
                                        child: Text(year.toString(), style: TextStyle(color: RCColors.textPrimary)),
                                      );
                                    }).toList(),
                                    onChanged: (v) => controller.selectedYear.value = v!,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.power_settings_new, size: 14, color: RCColors.textSecondary),
                                        const SizedBox(width: 6),
                                        Text("cha_active".tr, style: TextStyle(color: RCColors.textSecondary, fontSize: 13)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Obx(() => Switch(
                                      value: controller.isActive.value,
                                      onChanged: (v) => controller.isActive.value = v,
                                      activeThumbColor: RCColors.orange,
                                      activeTrackColor: RCColors.orange.withOpacity(0.3),
                                    )),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 20),

                            // DROPDOWN para seleccionar categoría existente
                            _buildInputLabel("cha_select_existing".tr, icon: Icons.list_alt),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
                                    value: controller.selectedExistingCategory.value,
                                    dropdownColor: RCColors.card,
                                    style: TextStyle(color: RCColors.textPrimary, fontSize: 14),
                                    decoration: _inputDecoration(),
                                    items: controller.availableCategories.map((cat) {
                                      return DropdownMenuItem(
                                        value: cat,
                                        child: Text(cat['name'], style: TextStyle(color: RCColors.textPrimary)),
                                      );
                                    }).toList(),
                                    onChanged: (value) => controller.selectedExistingCategory.value = value,
                                    hint: Text("cha_select_cat".tr, style: TextStyle(color: RCColors.textSecondary.withOpacity(0.5))),
                                  )),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: RCColors.orange, size: 40),
                                  onPressed: controller.addExistingCategory,
                                  tooltip: "cha_add_selected".tr,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // INPUT para crear nueva categoría
                            _buildInputLabel("cha_create_new".tr, icon: Icons.add_box_outlined),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: controller.newCategoryController,
                                    style: TextStyle(color: RCColors.textPrimary, fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: 'cha_cat_hint'.tr,
                                      hintStyle: TextStyle(color: RCColors.textSecondary.withOpacity(0.4)),
                                      filled: true,
                                      fillColor: RCColors.background.withOpacity(0.5),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: RCColors.divider)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: RCColors.orange, width: 1)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.create_new_folder, color: RCColors.orange, size: 40),
                                  onPressed: () => controller.addNewCategory(),
                                  tooltip: "cha_create_and_add".tr,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SECCIÓN DE CATEGORÍAS CONFIGURADAS
                    _buildCategoriesSection(),
                    const SizedBox(height: 30),
                    _buildSaveButton(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
        borderSide: BorderSide(color: RCColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: RCColors.orange, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(label, icon: icon),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: RCColors.textPrimary, fontSize: 14),
          validator: validator,
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  Widget _buildProfileStyleDropdown<T>({
    required String label,
    required IconData icon,
    T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(label, icon: icon),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          dropdownColor: RCColors.card,
          style: TextStyle(color: RCColors.textPrimary, fontSize: 14),
          decoration: _inputDecoration(),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInputLabel(String text, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: RCColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: RCColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Obx(() {
      if (controller.selectedCategories.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    "cha_configured".tr,
                    style: TextStyle(
                      color: RCColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                ...controller.selectedCategories.asMap().entries.map((entry) {
                  int index = entry.key;
                  var cat = entry.value;

                  bool hasNewPdf = cat['pdf_file'] != null;
                  bool hasExistingUrl = cat['rulebook_url'] != null;

                  return Card(
                    color: RCColors.background.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: RCColors.divider)
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: cat['is_new'] == true
                          ? const Icon(Icons.fiber_new, color: Colors.green, size: 20)
                          : null,
                      title: Text(cat['name'],
                          style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                        hasNewPdf ? 'cha_pdf_ready'.tr
                            : (hasExistingUrl ? 'cha_pdf_ok'.tr : 'cha_pdf_no'.tr),
                        style: TextStyle(
                            color: hasNewPdf ? RCColors.orange : (hasExistingUrl ? Colors.green : RCColors.textSecondary.withOpacity(0.6)),
                            fontSize: 11
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Adjuntar Reglamento (PDF)',
                            icon: Icon(hasExistingUrl && !hasNewPdf ? Icons.edit_document : Icons.picture_as_pdf,
                                color: RCColors.orange, size: 20),
                            onPressed: () => controller.pickPdfForCategory(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => controller.removeCategory(index),
                          )
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: controller.isLoading.value
            ? null
            : const LinearGradient(colors: [RCColors.orange, Color(0xFFF68B28)]),
        color: controller.isLoading.value ? RCColors.card : null,
        boxShadow: controller.isLoading.value ? null : [
          BoxShadow(
            color: RCColors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : () => controller.saveChampionship(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: controller.isLoading.value
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
            controller.isEditing.value ? 'cha_btn_save'.tr : 'cha_btn_create'.tr,
            style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)
        ),
      ),
    );
  }
}