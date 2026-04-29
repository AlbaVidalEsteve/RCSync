import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/app/modules/admin_dashboard/controllers/import_results_controller.dart';

class ImportResultsPreviewView extends StatelessWidget {
  final ImportResultsController controller;
  final List results;
  final List preview;

  const ImportResultsPreviewView({
    super.key,
    required this.controller,
    required this.results,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RCColors.background,
      body: Column(
        children: [
          // header standard
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
            child: const Text(
              'Vista Previa de Resultados',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Contenido
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -60),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Resumen
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            '${preview.length}',
                            'resultados',
                            Colors.blue,
                          ),
                          _buildSummaryItem(
                            '${preview.where((p) => p['matched'] == true).length}',
                            'coincidentes',
                            Colors.green,
                          ),
                          _buildSummaryItem(
                            '${preview.where((p) => p['matched'] != true).length}',
                            'sin coincidencia',
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Lista de resultados
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.list_alt, color: RCColors.orange, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Lista de pilotos',
                                style: TextStyle(
                                  color: RCColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: preview.length,
                            itemBuilder: (context, index) {
                              var item = preview[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: item['matched'] == true
                                      ? RCColors.background.withOpacity(0.5)
                                      : RCColors.background.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: item['matched'] == true
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: item['matched'] == true ? Colors.green : Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${item['position']}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['pilot_name'] ?? '',
                                            style: TextStyle(
                                              color: RCColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Transponder: ${item['transponder']} | Vueltas: ${item['laps']} | Pts: ${item['points']}',
                                            style: TextStyle(
                                              color: RCColors.textSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      item['matched'] == true ? Icons.check_circle : Icons.warning,
                                      color: item['matched'] == true ? Colors.green : Colors.orange,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Botones de accion
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: RCColors.divider),
                              ),
                              child: ElevatedButton(
                                onPressed: () => Get.back(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                child: Text(
                                  'cancel'.tr,
                                  style: TextStyle(
                                    color: RCColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: const LinearGradient(
                                  colors: [RCColors.orange, Color(0xFFF68B28)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: RCColors.orange.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => controller.saveResults(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                child: Text(
                                  'Guardar Resultados',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: RCColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}