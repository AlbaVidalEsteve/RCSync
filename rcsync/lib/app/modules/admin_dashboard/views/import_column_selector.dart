import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/app/modules/admin_dashboard/controllers/import_results_controller.dart';

class ImportColumnSelectorSheet extends StatelessWidget {
  final ImportResultsController controller;
  const ImportColumnSelectorSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RCColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(color: RCColors.divider, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.tune, color: RCColors.orange, size: 20),
                const SizedBox(width: 10),
                Text('import_col_title'.tr,
                    style: TextStyle(color: RCColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text('import_col_subtitle'.tr,
              style: TextStyle(color: RCColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),

          // Toggle encabezado
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('import_col_has_header'.tr,
                    style: TextStyle(color: RCColors.textSecondary, fontSize: 12)),
                Switch(
                  value: controller.hasHeader.value,
                  onChanged: (val) {
                    controller.hasHeader.value = val;
                    controller.rebuildFromRaw();
                  },
                  activeThumbColor: RCColors.orange,
                  activeTrackColor: RCColors.orange.withValues(alpha: 0.4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          )),
          const SizedBox(height: 4),

          // Tabla de preview
          _PreviewTable(controller: controller),
          const SizedBox(height: 16),

          // Selectores de columna
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildColumnPicker(
                  label: 'import_col_uuid'.tr,
                  sublabel: 'import_col_uuid_hint'.tr,
                  icon: Icons.fingerprint,
                  required: true,
                  selected: controller.colUuid,
                ),
                const SizedBox(height: 12),
                _buildColumnPicker(
                  label: 'import_col_pos'.tr,
                  sublabel: 'import_col_pos_hint'.tr,
                  icon: Icons.format_list_numbered,
                  required: false,
                  selected: controller.colPosition,
                ),
                const SizedBox(height: 12),
                _buildColumnPicker(
                  label: 'import_col_pole'.tr,
                  sublabel: 'import_col_pole_hint'.tr,
                  icon: Icons.flag_outlined,
                  required: false,
                  selected: controller.colPole,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Botones
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: RCColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('cancel'.tr, style: TextStyle(color: RCColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Obx(() {
                    final ready = controller.colUuid.value != null;
                    return ElevatedButton(
                      onPressed: ready ? controller.processWithSelectedColumns : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ready ? RCColors.orange : RCColors.divider,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: ready ? 4 : 0,
                      ),
                      child: Text('import_col_process'.tr,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnPicker({
    required String label,
    required String sublabel,
    required IconData icon,
    required bool required,
    required Rxn<int> selected,
  }) {
    return Obx(() {
      final headers = controller.fileHeaders;
      final items = <DropdownMenuItem<int?>>[
        if (!required)
          DropdownMenuItem<int?>(
            value: null,
            child: Text('import_col_none'.tr,
                style: TextStyle(color: RCColors.textSecondary, fontStyle: FontStyle.italic)),
          ),
        ...headers.asMap().entries.map((e) => DropdownMenuItem<int?>(
          value: e.key,
          child: Text('#${e.key} · ${e.value}',
              style: TextStyle(color: RCColors.textPrimary, fontSize: 13),
              overflow: TextOverflow.ellipsis),
        )),
      ];

      final isSet = selected.value != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14,
                color: required && !isSet ? Colors.redAccent : RCColors.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  color: required && !isSet ? Colors.redAccent : RCColors.textSecondary,
                  fontSize: 12, fontWeight: FontWeight.w600)),
            if (required)
              Text(' *', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
          ]),
          const SizedBox(height: 4),
          DropdownButtonFormField<int?>(
            initialValue: selected.value,
            dropdownColor: RCColors.card,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: RCColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: required && !isSet ? Colors.redAccent.withValues(alpha: 0.5) : RCColors.divider,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: RCColors.orange),
              ),
              hintText: sublabel,
              hintStyle: TextStyle(color: RCColors.textSecondary.withValues(alpha: 0.5), fontSize: 12),
            ),
            items: items,
            onChanged: (val) => selected.value = val,
          ),
        ],
      );
    });
  }
}

// StatefulWidget separado para gestionar el ScrollController del Scrollbar
class _PreviewTable extends StatefulWidget {
  final ImportResultsController controller;
  const _PreviewTable({required this.controller});

  @override
  State<_PreviewTable> createState() => _PreviewTableState();
}

class _PreviewTableState extends State<_PreviewTable> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final headers = widget.controller.fileHeaders;
      final rows    = widget.controller.filePreviewRows;
      if (headers.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: RCColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: RCColors.divider),
        ),
        child: Scrollbar(
          controller: _scroll,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(RCColors.surface),
              dataRowMinHeight: 32,
              dataRowMaxHeight: 40,
              horizontalMargin: 12,
              columnSpacing: 20,
              headingTextStyle: TextStyle(
                color: RCColors.orange,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              dataTextStyle: TextStyle(color: RCColors.textSecondary, fontSize: 11),
              columns: headers.asMap().entries.map((e) =>
                DataColumn(label: SizedBox(
                  width: 80,
                  child: Text('#${e.key} ${e.value}', overflow: TextOverflow.ellipsis, maxLines: 1),
                ))
              ).toList(),
              rows: rows.map((row) => DataRow(
                cells: headers.asMap().keys.map((i) =>
                  DataCell(SizedBox(
                    width: 80,
                    child: Text(i < row.length ? row[i] : '', overflow: TextOverflow.ellipsis, maxLines: 1),
                  ))
                ).toList(),
              )).toList(),
            ),
          ),
        ),
      );
    });
  }
}
