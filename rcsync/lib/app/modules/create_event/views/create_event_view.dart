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
        // Lógica de Master (Título dinámico) + Tus estilos
        title: Obx(() => Text(
          controller.isEditing.value ? "Modificar Evento" : "Crear Nuevo Evento", 
          style: const TextStyle(color: RCColors.white)
        )),
        backgroundColor: RCColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: RCColors.white),
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
                // Usamos tus métodos de construcción de UI pero con los controladores de Master
                _buildTextField("Nombre del Evento", controller.nameController, Icons.event),
                _buildTextField("Descripción", controller.descriptionController, Icons.description, maxLines: 3),
                _buildTextField("Precio de Inscripción (€)", controller.prizeController, Icons.monetization_on, keyboardType: TextInputType.number),
                
                const SizedBox(height: 10),
                Text("Imagen del Evento", style: TextStyle(color: RCColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildImagePicker(), // Tu diseño de picker con la lógica de preview de Master
                
                const SizedBox(height: 20),
                Text("Configuración", style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                // Usamos los nuevos nombres de listas de Master: circuitsList y championshipsList
                _buildDropdown("Seleccionar Circuito", controller.selectedCircuitId, controller.circuitsList, 'id_circuit'),
                _buildDropdown("Seleccionar Campeonato (Opcional)", controller.selectedChampionshipId, controller.championshipsList, 'id_championship'),

                const SizedBox(height: 20),
                Text("Fechas del Evento", style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // Master cambió los nombres de las variables de fecha
                _buildDatePicker("Fecha Inicio Evento", controller.eventDateIni),
                _buildDatePicker("Fecha Fin Evento", controller.eventDateFin),
                
                const SizedBox(height: 20),
                Text("Fechas de Inscripción", style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                _buildDatePicker("Inicio Inscripciones", controller.eventRegIni),
                _buildDatePicker("Fin Inscripciones", controller.eventRegFin),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    // Master ahora usa saveEvent para manejar creación/edición
                    onPressed: () => controller.saveEvent(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RCColors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Obx(() => Text(
                      controller.isEditing.value ? "GUARDAR CAMBIOS" : "CREAR EVENTO", 
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

  // --- TUS WIDGETS DE ESTILO (Mantenidos y adaptados) ---

  Widget _buildImagePicker() {
    return Obx(() => GestureDetector(
      onTap: () => controller.pickImage(),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: RCColors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: controller.selectedImage.value != null ? RCColors.orange : RCColors.divider),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: _buildImagePreviewLogic(),
        ),
      ),
    ));
  }

  // Lógica de Master para mostrar imagen (memoria o red) dentro de tu diseño
  Widget _buildImagePreviewLogic() {
    if (controller.selectedImage.value?.bytes != null) {
      return Image.memory(controller.selectedImage.value!.bytes!, fit: BoxFit.cover);
    } else if (controller.existingImageUrl.value?.isNotEmpty ?? false) {
      return Image.network(controller.existingImageUrl.value!, fit: BoxFit.cover);
    } else {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, color: RCColors.orange, size: 40),
          SizedBox(height: 10),
          Text("Toca para subir una imagen", style: TextStyle(color: RCColors.textSecondary)),
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
        style: const TextStyle(color: RCColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: RCColors.textSecondary),
          prefixIcon: Icon(icon, color: RCColors.orange),
          filled: true,
          fillColor: RCColors.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: RCColors.divider)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, RxnInt selectedValue, List<dynamic> items, String idKey) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Obx(() => DropdownButtonFormField<int>(
        value: selectedValue.value,
        dropdownColor: RCColors.card,
        style: const TextStyle(color: RCColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: RCColors.textSecondary),
          filled: true,
          fillColor: RCColors.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: RCColors.divider)),
        ),
        items: [
          const DropdownMenuItem<int>(value: null, child: Text("Ninguno / General")),
          ...items.map((item) => DropdownMenuItem<int>(
            value: item[idKey],
            child: Text(item['name'] ?? '', style: const TextStyle(color: RCColors.textPrimary)),
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
        final dateStr = dateTarget.value == null 
            ? "Seleccionar fecha" 
            : DateFormat('dd/MM/yyyy', 'es_ES').format(dateTarget.value!);
        return ListTile(
          onTap: () => controller.pickDate(Get.context!, dateTarget),
          tileColor: RCColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: RCColors.divider),
          ),
          title: Text(label, style: const TextStyle(color: RCColors.textSecondary, fontSize: 14)),
          subtitle: Text(dateStr, style: const TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.calendar_month, color: RCColors.orange),
        );
      }),
    );
  }
}