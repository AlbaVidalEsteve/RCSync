import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart'; // Ajusta esta ruta si es necesario
import '../controllers/results_controller.dart';

class ResultsView extends GetView<ResultsController> {
  const ResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RCColors.background,
      appBar: AppBar(
        title: const Text(
          "RESULTADOS TAMIYA GT",
          style: TextStyle(color: RCColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: RCColors.darkBlue,
        iconTheme: const IconThemeData(color: RCColors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildStatusBanner(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(RCSpacing.md),
      decoration: const BoxDecoration(
        color: RCColors.darkBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Dropdown Año
              Expanded(
                child: Obx(() {
                  final safeValue = controller.availableYears.contains(controller.selectedYear.value)
                      ? controller.selectedYear.value
                      : null;
                  return _customDropdown(
                    label: "Año",
                    value: safeValue,
                    items: controller.availableYears,
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedYear.value = val;
                        controller.fetchCategoriesAndRanking();
                      }
                    },
                  );
                }),
              ),
              const SizedBox(width: RCSpacing.md),
              // Dropdown Categoría Principal
              Expanded(
                child: Obx(() {
                  final safeCat = controller.availableCategories.contains(controller.selectedMainCategory.value)
                      ? controller.selectedMainCategory.value
                      : null;
                  return _customDropdown(
                    label: "Categoría",
                    value: safeCat,
                    items: controller.availableCategories,
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedMainCategory.value = val;
                        controller.fetchRanking();
                      }
                    },
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: RCSpacing.md),
          // Sub-Filtro (General, Stock, etc)
          Obx(() => _customDropdown(
            label: "Filtrar Nivel",
            value: controller.selectedSubFilter.value,
            items: ["General", "Stock", "Superstock", "Junior"],
            onChanged: (val) {
              if (val != null) {
                controller.selectedSubFilter.value = val;
                controller.applyFilters();
              }
            },
          )),
        ],
      ),
    );
  }

  Widget _customDropdown({required String label, String? value, required List<String> items, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: RCColors.cardDark,
      style: const TextStyle(color: RCColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: RCColors.background.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildStatusBanner() {
    return Obx(() {
      final isActive = controller.isChampionshipActive.value;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: isActive ? RCColors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        child: Text(
          isActive ? "🏎️ CAMPEONATO EN CURSO" : "🏆 FINALIZADO (Suma 4 mejores)",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? RCColors.orange : Colors.greenAccent,
            fontSize: 12,
          ),
        ),
      );
    });
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.filteredEntries.isEmpty) {
        return const Center(child: Text("Sin resultados", style: TextStyle(color: Colors.white54)));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(RCSpacing.md),
        itemCount: controller.filteredEntries.length,
        itemBuilder: (context, index) {
          final entry = controller.filteredEntries[index];
          final pts = controller.isChampionshipActive.value ? entry.totalGross : entry.totalNet;

          return Card(
            color: RCColors.cardDark,
            margin: const EdgeInsets.only(bottom: RCSpacing.sm),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: index < 3 ? RCColors.orange : RCColors.backgroundShine,
                child: Text("${index + 1}", style: const TextStyle(color: RCColors.white, fontWeight: FontWeight.bold)),
              ),
              title: Text(entry.fullName, style: const TextStyle(color: RCColors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(
                "${entry.calculatedLevel} ${entry.isJunior ? '• JUNIOR' : ''}",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              trailing: Text(
                "$pts pts",
                style: const TextStyle(color: RCColors.orange, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          );
        },
      );
    });
  }
}