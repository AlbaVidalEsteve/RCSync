import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:intl/intl.dart';
import '../controllers/create_event_controller.dart';

class CreateEventView extends GetView<CreateEventController> {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    // El controlador ahora se obtiene automáticamente desde el Binding
    // Se ha eliminado la línea: final controller = Get.put(CreateEventController());

    return Scaffold(
      backgroundColor: RCColors.background,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Obx(() => Text(
          controller.isEditing.value ? 'Modificar Evento' : 'Crear Evento',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft, 
                end: Alignment.bottomRight, 
                colors: [RCColors.orange, Color(0xFFF68B28)]
            ),
          ),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Obx(() => GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                height: 200, 
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A222D), 
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: controller.selectedImage.value == null && controller.existingImageUrl.value == null 
                        ? Colors.white30 
                        : RCColors.orange, 
                    width: 2
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13), 
                  child: _buildImagePreview()
                ),
              ),
            )),
            const SizedBox(height: 30),
            TextFormField(
              controller: controller.nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nombre del Evento', 
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: RCColors.orange)),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 20),
            Obx(() => DropdownButtonFormField<int>(
              initialValue: controller.selectedChampionshipId.value,
              dropdownColor: const Color(0xFF1A222D),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Campeonato (Opcional)', 
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
              ),
              items: [
                const DropdownMenuItem<int>(value: null, child: Text('Ninguno (Evento Independiente)')),
                ...controller.championshipsList.map((champ) => DropdownMenuItem<int>(
                  value: champ['id_championship'], 
                  child: Text(champ['name'])
                )),
              ],
              onChanged: (val) => controller.selectedChampionshipId.value = val,
            )),
            const SizedBox(height: 20),
            Obx(() => DropdownButtonFormField<int>(
              initialValue: controller.selectedCircuitId.value,
              dropdownColor: const Color(0xFF1A222D),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Circuito', 
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
              ),
              items: controller.circuitsList.map((circ) => DropdownMenuItem<int>(
                value: circ['id_circuit'], 
                child: Text(circ['name'])
              )).toList(),
              onChanged: (val) => controller.selectedCircuitId.value = val,
              validator: (val) => val == null ? 'Selecciona un circuito' : null,
            )),
            const SizedBox(height: 30),
            const Text('Fechas del Evento', style: TextStyle(color: RCColors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
            _buildDateSelector(context, 'Fecha Inicio Evento', controller.eventDateIni),
            _buildDateSelector(context, 'Fecha Fin Evento', controller.eventDateFin),
            const SizedBox(height: 20),
            const Text('Fechas de Inscripción', style: TextStyle(color: RCColors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
            _buildDateSelector(context, 'Apertura Inscripciones', controller.eventRegIni),
            _buildDateSelector(context, 'Cierre Inscripciones', controller.eventRegFin),
            const SizedBox(height: 20),
            TextFormField(
              controller: controller.prizeController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Precio de Inscripción (€)', 
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: controller.descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descripción / Notas', 
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
              ),
            ),
            const SizedBox(height: 40),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.saveEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: RCColors.orange, 
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                disabledBackgroundColor: RCColors.orange.withOpacity(0.5),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      controller.isEditing.value ? 'Guardar Cambios' : 'Crear Evento', 
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
                    ),
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (controller.selectedImage.value != null && controller.selectedImage.value!.bytes != null) {
      return Stack(fit: StackFit.expand, children: [
        Image.memory(controller.selectedImage.value!.bytes!, fit: BoxFit.cover), 
        Container(color: Colors.black.withOpacity(0.3)), 
        const Center(child: Icon(Icons.change_circle, color: Colors.white, size: 50))
      ]);
    } else if (controller.existingImageUrl.value != null && controller.existingImageUrl.value!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            controller.existingImageUrl.value!, 
            fit: BoxFit.cover, 
            errorBuilder: (context, error, stackTrace) => const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [Icon(Icons.broken_image, color: Colors.white54, size: 50), Text('Enlace roto (Tap para cambiar)', style: TextStyle(color: Colors.white54))]
            ))
          ),
          Container(color: Colors.black.withOpacity(0.3)), 
          const Center(child: Icon(Icons.change_circle, color: Colors.white, size: 50)),
        ],
      );
    } else {
      return const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [Icon(Icons.add_a_photo, color: RCColors.orange, size: 50), SizedBox(height: 10), Text('Añadir cartel del evento', style: TextStyle(color: Colors.white70))]
      ));
    }
  }

  Widget _buildDateSelector(BuildContext context, String label, Rxn<DateTime> dateObj) {
    return Obx(() {
      final dateStr = dateObj.value != null ? DateFormat('dd MMM yyyy', 'es_ES').format(dateObj.value!) : 'Seleccionar fecha';
      return ListTile(
        contentPadding: EdgeInsets.zero, 
        title: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        subtitle: Text(dateStr, style: const TextStyle(color: Colors.white, fontSize: 16)), 
        trailing: const Icon(Icons.calendar_today, color: RCColors.orange),
        onTap: () => controller.pickDate(context, dateObj),
      );
    });
  }
}
