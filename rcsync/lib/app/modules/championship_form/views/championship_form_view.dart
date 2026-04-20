import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import '../controllers/championship_form_controller.dart';

class ChampionshipFormView extends GetView<ChampionshipFormController> {
  const ChampionshipFormView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios de tema
    Theme.of(context);

    return Scaffold(
      backgroundColor: RCColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      // HEADER CON GRADIENTE
                      Container(
                        width: double.infinity,
                        height: 180,
                        padding: const EdgeInsets.only(top: 70),
                        alignment: Alignment.topCenter,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [RCColors.orange, Color(0xFFF68B28)],
                          ),
                        ),
                        child: Obx(() => Text(
                          controller.isEditing.value ? 'cha_edit'.tr : 'cha_new'.tr,
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 1.2
                          ),
                        )),
                      ),
                      
                      // TARJETA DE FORMULARIO SOLAPADA
                      Container(
                        margin: const EdgeInsets.only(top: 140, left: 20, right: 20, bottom: 20),
                        child: _buildFormCard(),
                      ),
                    ],
                  ),
                  
                  // LISTA DE CATEGORÍAS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildCategoriesSection(),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // BOTÓN GUARDAR FIJO ABAJO
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Obx(() => _buildSaveButton()),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RCColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  child: Obx(() => _buildProfileStyleDropdown<int>(
                    label: "cha_year".tr,
                    icon: Icons.calendar_today_outlined,
                    value: controller.selectedYear.value,
                    items: List.generate(5, (index) => DateTime.now().year + index).map((year) {
                      return DropdownMenuItem(
                        value: year, 
                        child: Text(year.toString(), style: TextStyle(color: RCColors.textPrimary))
                      );
                    }).toList(),
                    onChanged: (v) => controller.selectedYear.value = v!,
                  )),
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
                        activeColor: RCColors.orange,
                        activeTrackColor: RCColors.orange.withOpacity(0.3),
                    )),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            _buildInputLabel("cha_add_cat".tr, icon: Icons.directions_car_outlined),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.categoryController,
                    style: TextStyle(color: RCColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'cha_cat_hint'.tr,
                      hintStyle: TextStyle(color: RCColors.textSecondary.withOpacity(0.4)),
                      filled: true,
                      fillColor: RCColors.background.withOpacity(0.5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
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
          ],
        ),
      ),
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
          decoration: InputDecoration(
            filled: true,
            fillColor: RCColors.background.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: RCColors.orange, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStyleDropdown<T>({
    required String label,
    required IconData icon, T? value,
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
          decoration: InputDecoration(
            filled: true,
            fillColor: RCColors.background.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
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
      if (controller.categoriesList.isEmpty) return const SizedBox.shrink();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
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
          ...controller.categoriesList.asMap().entries.map((entry) {
            int index = entry.key;
            var cat = entry.value;

            bool hasNewPdf = cat['pdf_file'] != null;
            bool hasExistingUrl = cat['rulebook_url'] != null;

            return Card(
              color: RCColors.card,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Get.isDarkMode ? Colors.transparent : RCColors.divider.withOpacity(0.08))
              ),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(cat['name'], style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
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
                      icon: Icon(hasExistingUrl && !hasNewPdf ? Icons.edit_document : Icons.picture_as_pdf, color: RCColors.orange, size: 20),
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
      );
    });
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Container(
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
      ),
    );
  }
}
