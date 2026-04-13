import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import '../controllers/create_event_controller.dart';

class CreateEventView extends GetView<CreateEventController> {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RCColors.background,
      appBar: AppBar(
        title: Text("Crear Nuevo Evento", style: TextStyle(color: RCColors.white)),
        backgroundColor: RCColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: RCColors.white),
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
                _buildTextField("Nombre del Evento", controller.nameController, Icons.event),
                _buildTextField("Descripción", controller.descriptionController, Icons.description, maxLines: 3),
                
                const SizedBox(height: 10),
                Text("Imagen del Evento", style: TextStyle(color: RCColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildImagePicker(),
                
                const SizedBox(height: 20),
                Text("Configuración", style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                _buildDropdown("Seleccionar Circuito", controller.selectedCircuitId, controller.circuits, 'id_circuit'),
                _buildDropdown("Seleccionar Campeonato", controller.selectedChampionshipId, controller.championships, 'id_championship'),

                const SizedBox(height: 20),
                Text("Fechas", style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                _buildDatePicker("Fecha Inicio Evento", controller.startDate),
                _buildDatePicker("Fecha Fin Evento", controller.endDate),
                _buildDatePicker("Inicio Inscripciones", controller.regStartDate),
                _buildDatePicker("Fin Inscripciones", controller.regEndDate),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => controller.createEvent(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RCColors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("CREAR EVENTO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
        height: 150,
        decoration: BoxDecoration(
          color: RCColors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: RCColors.divider),
        ),
        child: controller.selectedImageBytes.value != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(controller.selectedImageBytes.value!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo, color: RCColors.orange, size: 40),
                  const SizedBox(height: 10),
                  Text("Toca para subir una imagen", style: TextStyle(color: RCColors.textSecondary)),
                ],
              ),
      ),
    ));
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
        validator: (value) => value == null || value.isEmpty ? "Campo obligatorio" : null,
      ),
    );
  }

  Widget _buildDropdown(String label, RxnInt selectedValue, RxList<Map<String, dynamic>> items, String idKey) {
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
        items: items.map((item) {
          return DropdownMenuItem<int>(
            value: item[idKey],
            child: Text(item['name'] ?? '', style: TextStyle(color: RCColors.textPrimary)),
          );
        }).toList(),
        onChanged: (val) => selectedValue.value = val,
      )),
    );
  }

  Widget _buildDatePicker(String label, Rxn<DateTime> dateTarget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Obx(() => ListTile(
        onTap: () => controller.selectDate(Get.context!, dateTarget),
        tileColor: RCColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: RCColors.divider),
        ),
        title: Text(label, style: TextStyle(color: RCColors.textSecondary, fontSize: 14)),
        subtitle: Text(
          dateTarget.value == null ? "Seleccionar fecha" : "${dateTarget.value!.day}/${dateTarget.value!.month}/${dateTarget.value!.year}",
          style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.calendar_month, color: RCColors.orange),
      )),
    );
  }
}
