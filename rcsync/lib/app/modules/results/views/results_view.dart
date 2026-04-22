import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import '../controllers/results_controller.dart';

class ResultsView extends GetView<ResultsController> {
  const ResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios de tema
    Theme.of(context);

    return Scaffold(
      backgroundColor: RCColors.background,
      body: Column(
        children: [
          // --- HEADER CON GRADIENTE Y TARJETA SOLAPADA ---
          Stack(
            children: [
              // FONDO GRADIENTE
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
                  "res_title".tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // TARJETA DE FILTROS FLOTANTE
              Container(
                margin: const EdgeInsets.only(top: 110), 
                child: _buildFiltersCard(),
              ),
            ],
          ),

          _buildStatusBanner(),

          // LISTA DE RESULTADOS
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  // --- TARJETA DE FILTROS ---
  Widget _buildFiltersCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RCColors.card, 
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Obx(() => _buildProfileStyleDropdown(
                  label: "res_championship".tr,
                  icon: Icons.emoji_events_outlined,
                  value: controller.selectedChampionshipName.value.isEmpty ? null : controller.selectedChampionshipName.value,
                  items: controller.availableChampionships,
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedChampionshipName.value = val;
                      controller.fetchAvailableYears();
                    }
                  },
                )),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 3,
                child: Obx(() => _buildProfileStyleDropdown(
                  label: "res_year".tr,
                  icon: Icons.calendar_today_outlined,
                  value: controller.selectedYear.value.isEmpty ? null : controller.selectedYear.value,
                  items: controller.availableYears,
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedYear.value = val;
                      controller.fetchCategoriesForChampionship();
                    }
                  },
                )),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Obx(() => _buildProfileStyleDropdown(
                  label: "res_category".tr,
                  icon: Icons.directions_car_outlined,
                  value: controller.selectedCategory.value.isEmpty ? null : controller.selectedCategory.value,
                  items: controller.availableCategories,
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedCategory.value = val;
                      if (val != "Tamiya GT") {
                        controller.selectedSubFilter.value = "General";
                      }
                      controller.fetchRanking();
                    }
                  },
                )),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 1,
                child: Obx(() {
                  if (controller.selectedCategory.value == "Tamiya GT") {
                    return _buildProfileStyleDropdown(
                      label: "res_level".tr,
                      icon: Icons.speed_outlined,
                      value: controller.selectedSubFilter.value,
                      items: ["General", "Stock", "Superstock", "Junior"],
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedSubFilter.value = val;
                          controller.applyFilters();
                        }
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStyleDropdown({
    required String label,
    required IconData icon,
    String? value,
    required List<String> items,
    required Function(String?) onChanged
  }) {
    final safeValue = (value != null && items.contains(value)) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: RCColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: RCColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: safeValue,
          dropdownColor: RCColors.card, 
          icon: Icon(Icons.arrow_drop_down, color: RCColors.textSecondary),
          style: TextStyle(color: RCColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
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
          ),
          items: items.isEmpty
              ? null
              : items.map((e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e, style: TextStyle(color: RCColors.textPrimary))
          )).toList(),
          onChanged: items.isEmpty ? null : onChanged,
          hint: items.isEmpty ? Text("res_loading".tr, style: TextStyle(color: RCColors.textSecondary.withOpacity(0.3), fontSize: 13)) : null,
        ),
      ],
    );
  }

  Widget _buildStatusBanner() {
    return Obx(() {
      final isActive = controller.isChampionshipActive.value;
      final statusColor = isActive ? RCColors.orange : Colors.green;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Text(
          isActive ? "res_active".tr : "res_finished".tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: statusColor,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      );
    });
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.filteredEntries.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("res_select_filters".tr, style: TextStyle(color: RCColors.textSecondary.withOpacity(0.5))),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 100),
        itemCount: controller.filteredEntries.length,
        itemBuilder: (context, index) {
          final entry = controller.filteredEntries[index];
          final pts = controller.isChampionshipActive.value ? entry.totalGross : entry.totalNet;

          Color badgeColor;
          Color badgeTextColor = Colors.black87;

          if (index == 0) {
            badgeColor = RCColors.gold;
          } else if (index == 1) {
            badgeColor = RCColors.silver;
          } else if (index == 2) {
            badgeColor = RCColors.bronze;
          } else {
            badgeColor = RCColors.surface; 
            badgeTextColor = RCColors.textPrimary;
          }

          const String genericHelmetUrl = "https://llprsnjobjwtcwwpsqwy.supabase.co/storage/v1/object/public/imagenes/perfilfoto/imagen%20perfil%20generica.png";

          return Card(
            color: RCColors.card,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: index == 0 ? const BorderSide(color: RCColors.gold, width: 1) : BorderSide.none,
            ),
            elevation: index < 3 ? 4 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: RCColors.surface,
                        border: Border.all(
                          color: index < 3 ? badgeColor : RCColors.divider,
                          width: index < 3 ? 2 : 1,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          (entry.imageProfile != null && entry.imageProfile!.isNotEmpty)
                              ? entry.imageProfile!
                              : genericHelmetUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              genericHelmetUrl,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: RCColors.card, width: 2),
                        ),
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            color: badgeTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  entry.fullName,
                  style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: entry.calculatedLevel == 'SUPERSTOCK'
                                ? Colors.purple.withOpacity(0.2)
                                : Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: entry.calculatedLevel == 'SUPERSTOCK' ? Colors.purpleAccent : Colors.blueAccent,
                              width: 0.5,
                            )
                        ),
                        child: Text(
                          entry.calculatedLevel,
                          style: TextStyle(
                            color: entry.calculatedLevel == 'SUPERSTOCK' ? Colors.purpleAccent : Colors.lightBlueAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (entry.isJunior) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.greenAccent, width: 0.5)
                          ),
                          child: const Text(
                            "JUNIOR",
                            style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$pts",
                      style: const TextStyle(color: RCColors.orange, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      "pts",
                      style: TextStyle(color: RCColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
