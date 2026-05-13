import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/app/data/models/profiles_model.dart';
import 'package:rcsync/app/modules/user_stats/controllers/user_stats_controller.dart';

class UserStatsView extends GetView<UserStatsController> {
  const UserStatsView({super.key});

  static const String _genericAvatarUrl =
      'https://llprsnjobjwtcwwpsqwy.supabase.co/storage/v1/object/public/imagenes/perfilfoto/imagen%20perfil%20generica.png';

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      backgroundColor: RCColors.background,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildHeader(),
              Positioned(
                top: 110,
                left: 16,
                right: 16,
                child: _buildSummaryCard(),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: RCColors.orange));
              }
              return RefreshIndicator(
                onRefresh: controller.loadData,
                color: RCColors.orange,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildLastRegisteredSection(),
                      const SizedBox(height: 16),
                      _buildOnlineSection(),
                      const SizedBox(height: 16),
                      _buildRecentOfflineSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.only(top: 60, left: 4, right: 16),
      alignment: Alignment.topCenter,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RCColors.orange, Color(0xFFF68B28)],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
          ),
          Expanded(
            child: Text(
              'stats_title'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RCColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem(
            icon: Icons.group_outlined,
            iconColor: RCColors.orange,
            value: '${controller.totalUsers.value}',
            label: 'stats_total'.tr,
          )),
          Container(width: 1, height: 50, color: RCColors.divider),
          Expanded(child: _buildStatItem(
            icon: Icons.circle,
            iconColor: Colors.greenAccent,
            value: '${controller.onlineUsers.length}',
            label: 'stats_online'.tr,
          )),
        ],
      ),
    ));
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: RCColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: RCColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildLastRegisteredSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.person_add_outlined, 'stats_recent'.tr),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: RCColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: controller.lastRegistered.asMap().entries.map((entry) {
                final isLast = entry.key == controller.lastRegistered.length - 1;
                return _buildUserRow(entry.value, isLast: isLast);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(ProfileModel profile, {required bool isLast}) {
    final dateStr = profile.createdAt != null
        ? DateFormat('dd MMM yyyy', Get.locale?.languageCode ?? 'es').format(profile.createdAt!)
        : '—';

    Color rolColor;
    Color rolBg;
    switch (profile.rol.toLowerCase()) {
      case 'admin':
        rolColor = Colors.redAccent;
        rolBg = Colors.red.withValues(alpha: 0.12);
        break;
      case 'organizador':
        rolColor = Colors.orangeAccent;
        rolBg = Colors.orange.withValues(alpha: 0.12);
        break;
      default:
        rolColor = Colors.blueAccent;
        rolBg = Colors.blue.withValues(alpha: 0.12);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildAvatar(profile.imageProfile),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: rolBg, borderRadius: BorderRadius.circular(6)),
                          child: Text(profile.rol, style: TextStyle(color: rolColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text(dateStr, style: TextStyle(color: RCColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: RCColors.divider, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildOnlineSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Row(
            children: [
              const Icon(Icons.wifi_tethering, color: RCColors.orange, size: 16),
              const SizedBox(width: 8),
              Text('stats_online'.tr, style: TextStyle(color: RCColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '${controller.onlineUsers.length}',
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.onlineUsers.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: RCColors.card, borderRadius: BorderRadius.circular(16)),
                child: Text('stats_no_online'.tr, textAlign: TextAlign.center, style: TextStyle(color: RCColors.textSecondary, fontSize: 13)),
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: RCColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: controller.onlineUsers.asMap().entries.map((entry) {
                  final isLast = entry.key == controller.onlineUsers.length - 1;
                  return _buildOnlineUserRow(entry.value, isLast: isLast);
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOnlineUserRow(Map<String, dynamic> user, {required bool isLast}) {
    final name = user['full_name']?.toString() ?? 'Usuario';
    final imageUrl = user['image_url']?.toString();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Stack(
                children: [
                  _buildAvatar((imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : null),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: RCColors.card, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name, style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
              ),
              const Icon(Icons.circle, color: Colors.greenAccent, size: 8),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: RCColors.divider, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildAvatar(String? imageUrl) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: RCColors.surface,
      child: CachedNetworkImage(
        imageUrl: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : _genericAvatarUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(radius: 20, backgroundImage: imageProvider),
        placeholder: (context, url) => const CircleAvatar(radius: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, url, error) => const CircleAvatar(radius: 20, child: Icon(Icons.person, size: 18)),
      ),
    );
  }

  Widget _buildRecentOfflineSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.history_outlined, 'stats_recent_offline'.tr),
          const SizedBox(height: 10),
          Obx(() {
            final users = controller.recentlyOfflineUsers;
            if (users.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: RCColors.card, borderRadius: BorderRadius.circular(16)),
                child: Text('stats_no_offline'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: RCColors.textSecondary, fontSize: 13)),
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: RCColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: users.asMap().entries.map((entry) {
                  final isLast = entry.key == users.length - 1;
                  return _buildOfflineUserRow(entry.value, isLast: isLast);
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOfflineUserRow(Map<String, dynamic> user, {required bool isLast}) {
    final name     = user['full_name']?.toString() ?? 'Usuario';
    final imageUrl = user['image_url']?.toString();
    final offlineAt = user['offline_at'] != null
        ? DateTime.tryParse(user['offline_at'].toString())
        : null;
    final timeStr = offlineAt != null
        ? DateFormat('HH:mm', Get.locale?.languageCode ?? 'es').format(offlineAt.toLocal())
        : '—';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Stack(
                children: [
                  _buildAvatar((imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : null),
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 11, height: 11,
                      decoration: BoxDecoration(
                        color: RCColors.divider,
                        shape: BoxShape.circle,
                        border: Border.all(color: RCColors.card, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name,
                    style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Row(
                children: [
                  Icon(Icons.logout_outlined, size: 12, color: RCColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(timeStr, style: TextStyle(color: RCColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: RCColors.divider, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: RCColors.orange, size: 16),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: RCColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
