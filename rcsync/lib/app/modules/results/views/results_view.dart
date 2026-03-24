import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import '../controllers/results_controller.dart';

class ResultsView extends GetView<ResultsController> {
  const ResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RCColors.background,
      appBar: AppBar(
        title: const Text(
          "RESULTADOS",
          style: TextStyle(color: RCColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: RCColors.orange,
        iconTheme: const IconThemeData(color: RCColors.white),
        centerTitle: true,
        elevation: 0,
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
        color: RCColors.orange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Obx(() => _customDropdownOnOrange(
                  label: "Campeonato",
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
              const SizedBox(width: RCSpacing.sm),
              Expanded(
                flex: 1,
                child: Obx(() => _customDropdownOnOrange(
                  label: "Año",
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
          const SizedBox(height: RCSpacing.md),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Obx(() => _customDropdownOnOrange(
                  label: "Categoría",
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
              const SizedBox(width: RCSpacing.sm),
              Expanded(
                flex: 1,
                child: Obx(() {
                  if (controller.selectedCategory.value == "Tamiya GT") {
                    return _customDropdownOnOrange(
                      label: "Nivel",
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

  Widget _customDropdownOnOrange({
    required String label,
    String? value,
    required List<String> items,
    required Function(String?) onChanged
  }) {
    final safeValue = (value != null && items.contains(value)) ? value : null;

    return DropdownButtonFormField<String>(
      value: safeValue,
      dropdownColor: RCColors.cardDark,
      iconEnabledColor: RCColors.backgroundShine,
      style: const TextStyle(color: RCColors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: RCColors.background, fontSize: 12, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: RCColors.white.withOpacity(0.2),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: RCColors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: RCColors.background, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      items: items.isEmpty
          ? null
          : items.map((e) => DropdownMenuItem<String>(
          value: e,
          child: Text(e, style: const TextStyle(color: RCColors.white))
      )).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      hint: items.isEmpty ? const Text("Cargando...", style: TextStyle(color: Colors.white54)) : null,
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
          isActive ? "🏎️ CAMPEONATO EN CURSO (Suma total)" : "🏆 FINALIZADO (Suma 4 mejores)",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? RCColors.orange : Colors.greenAccent,
            fontSize: 11,
          ),
        ),
      );
    });
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.filteredEntries.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Selecciona los filtros superiores", style: TextStyle(color: Colors.white54)),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(top: RCSpacing.sm, left: RCSpacing.md, right: RCSpacing.md, bottom: 80),
        itemCount: controller.filteredEntries.length,
        itemBuilder: (context, index) {
          final entry = controller.filteredEntries[index];
          final pts = controller.isChampionshipActive.value ? entry.totalGross : entry.totalNet;

          Color badgeColor;
          Color badgeTextColor = Colors.black87;

          if (index == 0) {
            badgeColor = const Color(0xFFFFD700); // Oro
          } else if (index == 1) {
            badgeColor = const Color(0xFFC0C0C0); // Plata
          } else if (index == 2) {
            badgeColor = const Color(0xFFCD7F32); // Bronce
          } else {
            badgeColor = RCColors.backgroundShine; // Gris oscuro
            badgeTextColor = RCColors.white;
          }

          const String genericHelmetUrl = "https://llprsnjobjwtcwwpsqwy.supabase.co/storage/v1/object/public/imagenes/perfilfoto/imagen%20perfil%20generica.png";

          return Card(
            color: RCColors.cardDark,
            margin: const EdgeInsets.only(bottom: RCSpacing.sm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: index == 0 ? const BorderSide(color: Color(0xFFFFD700), width: 1) : BorderSide.none,
            ),
            elevation: index < 3 ? 4 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // A. Contenedor circular recortado con ClipOval (Soluciona el error)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: RCColors.backgroundShine,
                        border: Border.all(
                          color: index < 3 ? badgeColor : Colors.white10,
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
                    // B. Medallita superpuesta con el número de ranking
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: RCColors.cardDark, width: 2),
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
                  style: const TextStyle(color: RCColors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
                    const Text(
                      "pts",
                      style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600),
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