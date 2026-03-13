import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/results_controller.dart';

class ResultsView extends GetView<ResultsController> {
  const ResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Para que herede el fondo oscuro de tu app
      body: Column(
        children: [
          _buildFilters(),
          _buildStatusBanner(),
          const Divider(height: 1),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              // --- COMBOBOX AÑO ---
              Expanded(
                flex: 1,
                child: Obx(() {
                  // 1. Escudo protector: si el año seleccionado no está en la lista aún, pasamos null temporalmente
                  final safeValue = controller.availableYears.contains(controller.selectedYear.value)
                      ? controller.selectedYear.value
                      : null;

                  return DropdownButtonFormField<String>(
                    value: safeValue,
                    decoration: const InputDecoration(labelText: "Año"),
                    // 2. Usamos la lista de años de la base de datos en lugar de ["2024", "2025"]
                    items: controller.availableYears
                        .map((y) => DropdownMenuItem<String>(value: y, child: Text(y)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedYear.value = val;
                        // Recargamos las categorías de ese campeonato
                        controller.fetchCategoriesAndRanking();
                      }
                    },
                  );
                }),
              ),
              const SizedBox(width: 12),

              // --- COMBOBOX CATEGORÍAS (DINÁMICO DESDE DB) ---
              Expanded(
                flex: 2,
                child: Obx(() {
                  if (controller.availableCategories.isEmpty) {
                    return DropdownButtonFormField<String>(
                      value: null,
                      decoration: const InputDecoration(labelText: "Categoría"),
                      items: const [],
                      onChanged: null,
                      hint: const Text("Sin categorías"),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: controller.availableCategories.contains(controller.selectedMainCategory.value)
                        ? controller.selectedMainCategory.value
                        : controller.availableCategories.first, // Valor seguro por defecto
                    decoration: const InputDecoration(labelText: "Categoría"),
                    items: controller.availableCategories
                        .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedMainCategory.value = val;
                        // Al cambiar categoría, refrescamos la tabla de puntos
                        controller.fetchRanking();
                      }
                    },
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- COMBOBOX SUB-FILTROS (OCULTO SI NO ES TAMIYA GT) ---
          Obx(() {
            if (controller.selectedMainCategory.value != 'Tamiya GT') {
              // Si es Truck u otra, forzamos la vista General y no pintamos el ComboBox
              Future.microtask(() => controller.selectedSubFilter.value = 'General');
              return const SizedBox.shrink();
            }

            return DropdownButtonFormField<String>(
              value: controller.selectedSubFilter.value,
              decoration: const InputDecoration(labelText: "Sub-Filtro (Niveles)"),
              items: ["General", "Stock", "Superstock", "Junior"]
                  .map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) {
                  controller.selectedSubFilter.value = val;
                  // Aquí solo aplicamos filtro en memoria, sin llamar a la BD
                  controller.applyFilters();
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Obx(() {
      final isActive = controller.isChampionshipActive.value;
      return Container(
        width: double.infinity,
        color: isActive ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          // Texto ajustado a tu nueva regla de "4 Mejores"
          isActive ? "🏎️ CAMPEONATO EN CURSO (Suma total)" : "🏆 FINALIZADO (Suma de los 4 Mejores)",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.orange[900] : Colors.green[900]),
        ),
      );
    });
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.filteredEntries.isEmpty) {
        return const Center(child: Text("No hay resultados para esta selección"));
      }
      return ListView.builder(
        itemCount: controller.filteredEntries.length,
        itemBuilder: (context, index) {
          final entry = controller.filteredEntries[index];
          // Dependiendo si está en curso o no, el modelo usa totalGross (todo) o totalNet (4 mejores)
          final pts = controller.isChampionshipActive.value ? entry.totalGross : entry.totalNet;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: index < 3 ? Colors.orange : Colors.grey[300],
              child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
            ),
            title: Text(entry.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${entry.calculatedLevel} ${entry.isJunior ? '• JUNIOR' : ''}"),
            trailing: Text("$pts pts", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          );
        },
      );
    });
  }
}