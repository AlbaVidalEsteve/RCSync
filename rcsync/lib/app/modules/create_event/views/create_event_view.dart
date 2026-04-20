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
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isEditing.value ? "profile_save".tr : "create_event_title".tr, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        )),
        backgroundColor: RCColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [RCColors.orange, Color(0xFFF68B28)],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: RCColors.orange));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField("create_event_name".tr, controller.nameController, Icons.event),
                _buildTextField("create_event_desc".tr, controller.descriptionController, Icons.description, maxLines: 3),
                _buildTextField("Precio (€)", controller.prizeController, Icons.monetization_on, keyboardType: TextInputType.number),
                
                const SizedBox(height: 10),
                Text("create_event_img".tr, style: TextStyle(color: RCColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildImagePicker(), 
                
                const SizedBox(height: 20),
                Text("create_event_config".tr, style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                _buildDropdown("create_event_circuit".tr, controller.selectedCircuitId, controller.circuitsList, 'id_circuit'),
                _buildDropdown("create_event_champ".tr, controller.selectedChampionshipId, controller.championshipsList, 'id_championship'),

                const SizedBox(height: 20),
                Text("create_event_dates".tr, style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                _buildDatePicker("create_event_date_start".tr, controller.eventDateIni),
                _buildDatePicker("create_event_date_end".tr, controller.eventDateFin),
                
                const SizedBox(height: 20),
                Text("Fechas de Inscripción", style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                _buildDatePicker("create_event_reg_start".tr, controller.eventRegIni),
                _buildDatePicker("create_event_reg_end".tr, controller.eventRegFin),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => controller.saveEvent(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RCColors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Obx(() => Text(
                      controller.isEditing.value ? "profile_save".tr : "create_event_btn".tr, 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                    )),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      }),
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
          Text("create_event_img_hint".tr, style: TextStyle(color: RCColors.textSecondary)),
        ],
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController textController, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: textController,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: RCColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: RCColors.textSecondary),
          prefixIcon: Icon(icon, color: RCColors.orange),
          filled: true,
          fillColor: RCColors.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: RCColors.divider)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, Rxn<int> selectedValue, List<dynamic> items, String idKey) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Obx(() => DropdownButtonFormField<int>(
        value: selectedValue.value,
        dropdownColor: RCColors.card,
        style: TextStyle(color: RCColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: RCColors.textSecondary),
          filled: true,
          fillColor: RCColors.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: RCColors.divider)),
        ),
        items: [
          const DropdownMenuItem<int>(value: null, child: Text("General")),
          ...items.map((item) => DropdownMenuItem<int>(
            value: item[idKey],
            child: Text(item['name'] ?? '', style: TextStyle(color: RCColors.textPrimary)),
          )),
        ],
        onChanged: (val) => selectedValue.value = val,
      )),
    );
  }

  Widget _buildDatePicker(String label, Rxn<DateTime> dateTarget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Obx(() {
        final locale = Get.locale?.toString() ?? 'es_ES';
        final dateStr = dateTarget.value == null 
            ? "profile_save".tr // Reutilizando clave o asignar una nueva
            : DateFormat('dd/MM/yyyy', locale).format(dateTarget.value!);
        return ListTile(
          onTap: () => controller.pickDate(Get.context!, dateTarget),
          tileColor: RCColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: RCColors.divider),
          ),
          title: Text(label, style: TextStyle(color: RCColors.textSecondary, fontSize: 14)),
          subtitle: Text(dateStr, style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.calendar_month, color: RCColors.orange),
        );
      }),
    );
  }
}
