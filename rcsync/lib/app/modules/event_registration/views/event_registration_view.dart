import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/app/modules/event_registration/controllers/event_registration_controller.dart';
import 'package:rcsync/app/data/models/transponder_model.dart';
import 'package:rcsync/app/modules/profile/controllers/profile_controller.dart';
import 'package:rcsync/app/modules/event_detail/controllers/event_details_controller.dart';

class EventRegistrationView extends GetView<EventRegistrationController> {
  const EventRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios de tema
    Theme.of(context);

    final profileController = Get.find<ProfileController>();
    final eventDetailsController = Get.find<EventDetailsController>();

    final profileData = profileController.profileData;
    final String fullName = profileData.isNotEmpty ? (profileData['full_name'] ?? 'Piloto') : 'Piloto';
    final userTransponders = profileController.transponders.map((t) => Transponder.fromJson(Map<String, dynamic>.from(t))).toList();
    final eventName = eventDetailsController.event.value.name;

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
          Stack(
            children: [
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
                child: Column(
                  children: [
                    Text("reg_event_title".tr, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 5),
                    Text(eventName, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 140),
                child: _buildRegistrationCard(fullName, userTransponders),
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Obx(() => ElevatedButton(
                  onPressed: controller.isRegistering.value ? null : () => controller.registerPilot(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RCColors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: controller.isRegistering.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("reg_btn_confirm".tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                )),
                const SizedBox(height: 12),
                // BOTÓN CANCELAR
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text("reg_cancel".tr, style: TextStyle(color: RCColors.textSecondary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRegistrationCard(String fullName, List<Transponder> userTransponders) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RCColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: RCColors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(label: "reg_pilot_name".tr, icon: Icons.person_outline, controller: TextEditingController(text: fullName), enabled: false),
          const SizedBox(height: 20),
          Obx(() => _buildProfileStyleDropdown<String>(
            label: "reg_transponder".tr,
            icon: Icons.track_changes_outlined,
            value: controller.selectedTransponderId.value.isEmpty ? null : controller.selectedTransponderId.value,
            items: userTransponders.map((t) => DropdownMenuItem<String>(value: t.id, child: Text("${t.number} - ${t.label}", style: TextStyle(color: RCColors.textPrimary)))).toList(),
            onChanged: (val) => controller.setSelectedTransponder(val),
          )),
          const SizedBox(height: 20),
          Obx(() => _buildProfileStyleDropdown<String>(
            label: "reg_category".tr,
            icon: Icons.directions_car_outlined,
            value: controller.selectedCategory.value.isEmpty ? null : controller.selectedCategory.value,
            items: controller.availableCategories.map((c) => DropdownMenuItem<String>(value: c, child: Text(c, style: TextStyle(color: RCColors.textPrimary)))).toList(),
            onChanged: (val) => controller.setSelectedCategory(val),
          )),
        ],
      ),
    );
  }

  Widget _buildInputField({required String label, required IconData icon, required TextEditingController controller, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 14, color: enabled ? RCColors.textSecondary : RCColors.textSecondary.withValues(alpha: 0.5)), const SizedBox(width: 6), Text(label, style: TextStyle(color: enabled ? RCColors.textSecondary : RCColors.textSecondary.withValues(alpha: 0.5), fontSize: 13))]),
        const SizedBox(height: 8),
        TextField(controller: controller, enabled: enabled, style: TextStyle(color: RCColors.textPrimary, fontSize: 14), decoration: InputDecoration(filled: true, fillColor: RCColors.background.withValues(alpha: 0.5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
      ],
    );
  }

  Widget _buildProfileStyleDropdown<T>({required String label, required IconData icon, T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    final safeValue = items.any((item) => item.value == value) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 14, color: RCColors.textSecondary), const SizedBox(width: 6), Text(label, style: TextStyle(color: RCColors.textSecondary, fontSize: 13))]),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: safeValue,
          dropdownColor: RCColors.card,
          style: TextStyle(color: RCColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(filled: true, fillColor: RCColors.background.withValues(alpha: 0.5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          items: items,
          onChanged: onChanged,
          hint: Text("reg_select".tr, style: TextStyle(color: RCColors.textSecondary.withValues(alpha: 0.5), fontSize: 13)),
        ),
      ],
    );
  }
}
