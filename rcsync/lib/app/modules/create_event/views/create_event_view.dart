import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:intl/intl.dart';
import '../controllers/create_event_controller.dart';

class CreateEventView extends GetView<CreateEventController> {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: Obx(() => Text(
                    controller.isEditing.value ? "evt_edit_title".tr : "evt_create_title".tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  )),
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
            // CONTENIDO CON OVERLAP
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
                          children: [
                            _buildTextField("evt_name".tr, controller.nameController, Icons.event),
                            const SizedBox(height: 15),
                            _buildTextField("evt_desc".tr, controller.descriptionController, Icons.description, maxLines: 3),
                            const SizedBox(height: 15),
                            _buildTextField("evt_price".tr, controller.prizeController, Icons.monetization_on, keyboardType: TextInputType.number),
                            const SizedBox(height: 20),
                            Text("evt_img".tr, style: TextStyle(color: RCColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildImagePicker(),
                            const SizedBox(height: 20),
                            Text("evt_config".tr, style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildDropdown("evt_circuit".tr, controller.selectedCircuitId, controller.circuitsList, 'id_circuit'),
                            const SizedBox(height: 15),
                            _buildDropdown("evt_champ_opt".tr, controller.selectedChampionshipId, controller.championshipsList, 'id_championship'),
                            const SizedBox(height: 20),
                            Text("evt_dates".tr, style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildDatePicker("evt_start".tr, controller.eventDateIni),
                            const SizedBox(height: 10),
                            _buildDatePicker("evt_end".tr, controller.eventDateFin),
                            const SizedBox(height: 20),
                            Text("evt_reg_dates".tr, style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildDatePicker("evt_reg_start".tr, controller.eventRegIni),
                            const SizedBox(height: 10),
                            _buildDatePicker("evt_reg_end".tr, controller.eventRegFin),
                          ],
                        ),
                      ),
                    ),
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

  Widget _buildImagePicker() {
    return Obx(() => GestureDetector(
      onTap: () => controller.pickImage(),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: RCColors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: controller.selectedImage.value != null || controller.existingImageUrl.value != null ? RCColors.orange : RCColors.divider),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: _buildImagePreviewLogic(),
        ),
      ),
    ));
  }

  Widget _buildImagePreviewLogic() {
    if (controller.selectedImage.value?.bytes != null) {
      return Image.memory(controller.selectedImage.value!.bytes!, fit: BoxFit.cover);
    } else if (controller.existingImageUrl.value != null && controller.existingImageUrl.value!.isNotEmpty) {
      return Image.network(controller.existingImageUrl.value!, fit: BoxFit.cover);
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_a_photo, color: RCColors.orange, size: 40),
          const SizedBox(height: 10),
          Text("evt_touch_img".tr, style: TextStyle(color: RCColors.textSecondary)),
        ],
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController textController, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: RCColors.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: RCColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: textController,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: RCColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: RCColors.background.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: RCColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: RCColors.orange, width: 1)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, Rxn<int> selectedValue, List<dynamic> items, String idKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.arrow_drop_down_circle_outlined, size: 16, color: RCColors.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: RCColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<int>(
          value: selectedValue.value,
          dropdownColor: RCColors.card,
          style: TextStyle(color: RCColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: RCColors.background.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: RCColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: RCColors.orange, width: 1)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: [
            DropdownMenuItem<int>(value: null, child: Text("evt_none".tr, style: TextStyle(color: RCColors.textSecondary))),
            ...items.map((item) => DropdownMenuItem<int>(
              value: item[idKey],
              child: Text(item['name'] ?? '', style: TextStyle(color: RCColors.textPrimary)),
            )),
          ],
          onChanged: (val) => selectedValue.value = val,
        )),
      ],
    );
  }

  Widget _buildDatePicker(String label, Rxn<DateTime> dateTarget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16, color: RCColors.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: RCColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          final locale = Get.locale?.toLanguageTag() ?? 'es-ES';
          final dateStr = dateTarget.value == null
              ? "evt_sel_date".tr
              : DateFormat.yMd(locale).format(dateTarget.value!);
          return GestureDetector(
            onTap: () => controller.pickDate(Get.context!, dateTarget),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: RCColors.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: RCColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateStr, style: TextStyle(color: RCColors.textPrimary)),
                  const Icon(Icons.calendar_month, color: RCColors.orange, size: 20),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(colors: [RCColors.orange, Color(0xFFF68B28)]),
        boxShadow: [
          BoxShadow(
            color: RCColors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: () => controller.saveEvent(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Obx(() => Text(
          controller.isEditing.value ? "evt_save".tr : "evt_create_btn".tr,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
        )),
      ),
    );
  }
}