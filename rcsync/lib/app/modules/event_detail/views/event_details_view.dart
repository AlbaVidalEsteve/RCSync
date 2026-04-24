import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/core/widgets/rc_primary_button.dart';
import 'package:rcsync/app/modules/map/views/map_view.dart';
import 'package:rcsync/app/modules/event_detail/controllers/event_details_controller.dart';
import 'package:rcsync/app/routes/app_pages.dart';
import 'package:rcsync/app/data/models/race_event_model.dart';

class EventDetailsView extends GetView<EventDetailsController> {
  const EventDetailsView({super.key});

  static const String _genericHelmetUrl = "https://llprsnjobjwtcwwpsqwy.supabase.co/storage/v1/object/public/imagenes/perfilfoto/imagen%20perfil%20generica.png";

  Color _getPositionColor(int position) {
    if (position == 1) return RCColors.gold;
    if (position == 2) return RCColors.silver;
    if (position == 3) return RCColors.bronze;
    return RCColors.orange;
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      backgroundColor: RCColors.background,
      body: Obx(() {
        if (controller.isLoading.value && controller.registeredPilots.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: RCColors.orange));
        }
        final RaceEventModel event = controller.event.value;
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              backgroundColor: RCColors.background,
              leading: _buildBackBtn(),
              flexibleSpace: FlexibleSpaceBar(
                background: CachedNetworkImage(
                  imageUrl: event.imageEvent ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: RCColors.orange.withOpacity(0.2),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: RCColors.orange.withOpacity(0.2),
                    child: const Icon(Icons.image, size: 100, color: Colors.white24),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildEventInfo(event),
                      const SizedBox(height: 20),
                      if (controller.isAdminOrOrganizer.value)
                        _buildExportButton(),
                      const SizedBox(height: 20),
                      _buildRulebooksSection(),
                      const SizedBox(height: 20),
                      _buildDescriptionSection(event),
                      const SizedBox(height: 20),
                      _buildPilotList(),
                      const SizedBox(height: 20),
                      _buildLocationSection(event),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        );
      }),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildBackBtn() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: CircleAvatar(
      backgroundColor: Colors.black38,
      child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back()
      ),
    ),
  );

  Widget _buildExportButton() {
    return Container(
      width: double.infinity,
      height: 55,
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
        onPressed: () => controller.exportRegisteredPilots(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'export_pilots'.tr.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfo(RaceEventModel event) => _buildSection(
    title: event.name,
    child: Column(
      children: [
        _buildDetailRow(
            icon: Icons.calendar_today,
            iconColor: RCColors.orange,
            title: 'det_date'.tr,
            subtitle: controller.formattedDate
        ),
        _buildDetailRow(
            icon: Icons.emoji_events_outlined,
            iconColor: Colors.amber,
            title: 'det_organizer'.tr,
            subtitle: event.organizerName ?? 'Club RC'
        ),
      ],
    ),
  );

  Widget _buildRulebooksSection() {
    return Obx(() {
      if (controller.rulebooks.isEmpty) return const SizedBox.shrink();
      return _buildCollapsibleSection(
        title: 'det_tech_rules'.tr,
        icon: Icons.rule_folder_outlined,
        isExpanded: controller.isRulebooksExpanded.value,
        onToggle: () => controller.isRulebooksExpanded.value = !controller.isRulebooksExpanded.value,
        child: Column(
          children: controller.rulebooks.map((rb) {
            final catName = rb['categories']?['name'] ?? 'evt_none'.tr;
            final url = rb['rulebook_url'];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: RCColors.background.withAlpha((0.5*255).toInt()),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 28),
                title: Text(
                  '${'det_rulebook'.tr} $catName',
                  style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text('det_open_pdf'.tr, style: TextStyle(color: RCColors.textSecondary, fontSize: 12)),
                trailing: Icon(Icons.arrow_forward_ios, color: RCColors.iconSecondary, size: 16),
                onTap: () => controller.openRulebook(url),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildDescriptionSection(RaceEventModel event) {
    final String? description = event.description;
    if (description == null || description.trim().isEmpty) return const SizedBox.shrink();
    return Obx(() => _buildCollapsibleSection(
      title: 'det_description'.tr,
      icon: Icons.info_outline,
      isExpanded: controller.isDescriptionExpanded.value,
      onToggle: () => controller.isDescriptionExpanded.value = !controller.isDescriptionExpanded.value,
      child: Text(
        description,
        style: TextStyle(color: RCColors.textSecondary, fontSize: 14, height: 1.6),
      ),
    ));
  }

  Widget _buildPilotList() => Obx(() {
    if (controller.registeredPilots.isEmpty) return const SizedBox.shrink();
    return _buildCollapsibleSection(
      title: 'det_pilots'.tr,
      icon: Icons.people_outline,
      isExpanded: controller.isPilotsExpanded.value,
      onToggle: () => controller.isPilotsExpanded.value = !controller.isPilotsExpanded.value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...controller.registeredPilots.entries.map(
                (entry) => _buildCategoryGroup(entry.key, entry.value),
          ),
        ],
      ),
    );
  });

  Widget _buildCategoryGroup(String category, List<RegisteredPilot> pilots) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(color: RCColors.orange, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: RCColors.orange.withAlpha((0.12*255).toInt()),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${pilots.length} ${'det_pilots_count'.tr}',
                style: const TextStyle(
                  color: RCColors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
      ...pilots.asMap().entries.map((entry) {
        final index = entry.key;
        final pilot = entry.value;
        final position = index + 1;
        final bool isSuperstock = pilot.subCategory.toUpperCase() == 'SUPERSTOCK';
        String displayCategory = pilot.subCategory;
        if (displayCategory.contains('JUNIOR')) {
          displayCategory = displayCategory.replaceAll(RegExp(r'JUNIOR[\+]?', caseSensitive: false), '').trim();
        }
        if (displayCategory.isEmpty) displayCategory = 'STOCK';

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: RCColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: RCColors.divider.withOpacity(0.3),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            leading: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: RCColors.surface,
                    border: Border.all(
                      color: _getPositionColor(position).withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: (pilot.imageUrl != null && pilot.imageUrl!.isNotEmpty)
                          ? pilot.imageUrl!
                          : _genericHelmetUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) => Image.network(_genericHelmetUrl, fit: BoxFit.cover),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: RCColors.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: RCColors.card, width: 1),
                    ),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getPositionColor(position),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$position',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              pilot.fullName,
              style: TextStyle(
                color: RCColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Wrap(
                spacing: 4,
                runSpacing: 2,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSuperstock
                          ? Colors.purple.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: isSuperstock
                            ? Colors.purpleAccent
                            : Colors.blueAccent,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      displayCategory,
                      style: TextStyle(
                        color: isSuperstock
                            ? Colors.purpleAccent
                            : Colors.lightBlueAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  if (pilot.isJunior)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.greenAccent, width: 0.5),
                      ),
                      child: const Text(
                        "JUNIOR",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: RCColors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${pilot.totalPoints} pts',
                style: TextStyle(
                  color: RCColors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }),
    ],
  );

  Widget _buildLocationSection(RaceEventModel event) => Obx(() => _buildCollapsibleSection(
    title: 'det_location'.tr,
    icon: Icons.location_on_outlined,
    isExpanded: controller.isLocationExpanded.value,
    onToggle: () => controller.isLocationExpanded.value = !controller.isLocationExpanded.value,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: (event.circuitLat != null && event.circuitLng != null)
              ? EventLocationMap(
            lat: event.circuitLat!,
            lng: event.circuitLng!,
            title: event.circuitName ?? "Carrera RC",
          )
              : _buildNoMapPlaceholder(),
        ),
      ],
    ),
  ));

  Widget _buildBottomAction() {
    final event = controller.event.value;
    final bool isInscriptionsOpen = event.eventRegFin != null && event.eventRegFin!.isAfter(DateTime.now());
    return Container(
      padding: const EdgeInsets.all(20),
      color: RCColors.background,
      child: RCPrimaryButton(
        label: isInscriptionsOpen ? 'det_register_now'.tr : 'det_register_closed'.tr,
        onPressed: isInscriptionsOpen ? () => Get.toNamed(Routes.EVENT_REGISTRATION, arguments: event) : null,
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: RCColors.card, borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      child
    ]),
  );

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: RCColors.card, borderRadius: BorderRadius.circular(20)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: RCColors.textSecondary),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: RCColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: RCColors.textSecondary,
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 16),
          child,
        ],
      ],
    ),
  );

  Widget _buildDetailRow({required IconData icon, required Color iconColor, required String title, required String subtitle}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withAlpha((0.1*255).toInt()), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 24)
      ),
      const SizedBox(width: 15),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: RCColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: RCColors.textSecondary, fontSize: 14))
      ]))
    ]),
  );

  Widget _buildNoMapPlaceholder() => Container(
    height: 180,
    decoration: BoxDecoration(
        color: RCColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RCColors.divider)
    ),
    child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, color: RCColors.iconSecondary, size: 40),
              const SizedBox(height: 10),
              Text('det_no_map'.tr, style: TextStyle(color: RCColors.textSecondary))
            ]
        )
    ),
  );
}