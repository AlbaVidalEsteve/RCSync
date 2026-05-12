import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/app/modules/pilot_detail/controllers/pilot_detail_controller.dart';
import 'package:intl/intl.dart';

class PilotDetailView extends GetView<PilotDetailController> {
  const PilotDetailView({super.key});

  static const String _genericHelmetUrl =
      "https://llprsnjobjwtcwwpsqwy.supabase.co/storage/v1/object/public/imagenes/perfilfoto/imagen%20perfil%20generica.png";

  // La card de ranking sobresale 56px por debajo del header
  static const double _cardOverlap = 56.0;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      backgroundColor: RCColors.background,
      body: Column(
        children: [
          // Header + ranking card solapada en un Stack
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildHeader(),
              Positioned(
                bottom: -_cardOverlap,
                left: 16,
                right: 16,
                child: _buildRankingCard(),
              ),
            ],
          ),

          // Contenido scrollable con padding superior para la card solapada
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.only(top: _cardOverlap),
                  child: Center(child: CircularProgressIndicator(color: RCColors.orange)),
                );
              }
              return SingleChildScrollView(
                padding: EdgeInsets.only(top: _cardOverlap + 8, bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCard(),
                    const SizedBox(height: 16),
                    if (controller.chronologicalResults.length >= 2)
                      _buildChartCard(),
                    if (controller.results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'pilot_no_results'.tr,
                            style: TextStyle(color: RCColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...controller.champKeys.map((key) => _buildChampSection(key)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ───────── HEADER (misma altura que Resultats: 180px / top: 60) ─────────
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
              'pilot_detail_title'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ───────── CARD RANKING (estilo Results) ─────────
  Widget _buildRankingCard() {
    final pilot = controller.pilot;
    final pos = controller.rankPosition;
    final pts = pilot.totalGross;

    Color badgeColor;
    Color badgeTextColor = Colors.black87;

    if (pos == 1) {
      badgeColor = RCColors.gold;
    } else if (pos == 2) {
      badgeColor = RCColors.silver;
    } else if (pos == 3) {
      badgeColor = RCColors.bronze;
    } else {
      badgeColor = RCColors.surface;
      badgeTextColor = RCColors.textPrimary;
    }

    return Card(
      color: RCColors.card,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: pos == 1
            ? const BorderSide(color: RCColors.gold, width: 1.5)
            : BorderSide(color: RCColors.divider, width: 0.5),
      ),
      elevation: pos <= 3 ? 6 : 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: Stack(
            alignment: Alignment.bottomRight,
            clipBehavior: Clip.none,
            children: [
              CachedNetworkImage(
                imageUrl: (pilot.imageProfile != null && pilot.imageProfile!.isNotEmpty)
                    ? pilot.imageProfile!
                    : _genericHelmetUrl,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 26,
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) => const CircleAvatar(
                  radius: 26,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => const CircleAvatar(
                  radius: 26,
                  child: Icon(Icons.person, size: 22),
                ),
              ),
              if (pos > 0)
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: RCColors.card, width: 2),
                    ),
                    child: Text(
                      '$pos',
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
            pilot.fullName,
            style: TextStyle(
              color: RCColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                _buildResultBadge(
                  label: pilot.calculatedLevel,
                  color: pilot.calculatedLevel == 'SUPERSTOCK' ? Colors.purpleAccent : Colors.lightBlueAccent,
                  bg: pilot.calculatedLevel == 'SUPERSTOCK'
                      ? Colors.purple.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.2),
                  border: pilot.calculatedLevel == 'SUPERSTOCK' ? Colors.purpleAccent : Colors.blueAccent,
                ),
                if (pilot.isJunior) ...[
                  const SizedBox(width: 6),
                  _buildResultBadge(
                    label: 'JUNIOR',
                    color: Colors.greenAccent,
                    bg: Colors.green.withValues(alpha: 0.2),
                    border: Colors.greenAccent,
                  ),
                ],
              ],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pts',
                style: const TextStyle(
                  color: RCColors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                'pts',
                style: TextStyle(color: RCColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultBadge({required String label, required Color color, required Color bg, required Color border}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  // ───────── STATS ─────────
  Widget _buildStatsCard() {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: RCColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat('pilot_stat_races'.tr, '${controller.totalRaces}', Icons.flag_outlined, RCColors.orange),
          _buildStatDivider(),
          _buildStat('pilot_stat_wins'.tr, '${controller.totalWins}', Icons.emoji_events_outlined, RCColors.gold),
          _buildStatDivider(),
          _buildStat('pilot_stat_podiums'.tr, '${controller.totalPodiums}', Icons.workspace_premium_outlined, RCColors.bronze),
          _buildStatDivider(),
          _buildStat(
            'pilot_stat_best'.tr,
            controller.bestPosition != null ? '${controller.bestPosition}°' : '—',
            Icons.stars_outlined,
            Colors.purpleAccent,
          ),
        ],
      ),
    ));
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: RCColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: RCColors.divider);
  }

  // ───────── GRÁFICO DE PROGRESIÓN (percentil relativo + pronóstico) ─────────
  Widget _buildChartCard() {
    final spots         = controller.chartSpots;
    final forecastSpots = controller.forecastChartSpots;
    final slope         = controller.trendSlopePerRace;
    final avg           = controller.avgRelativeScore;
    final forecast      = controller.forecastNextScore;
    final total         = controller.chronologicalResults.length;
    final improving     = slope != null && slope > 0.3;
    final declining     = slope != null && slope < -0.3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: RCColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabecera ──────────────────────────────────────────────────────
          Row(children: [
            const Icon(Icons.insights, color: RCColors.orange, size: 18),
            const SizedBox(width: 8),
            Text('pilot_chart_title'.tr,
                style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            if (slope != null)
              _buildTrendBadge(slope, improving, declining),
          ]),
          const SizedBox(height: 4),
          Text('pilot_chart_subtitle'.tr, style: TextStyle(color: RCColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 14),

          // ── Gráfico ───────────────────────────────────────────────────────
          SizedBox(
            height: 170,
            child: LineChart(
              duration: Duration.zero,
              LineChartData(
                minY: 0,
                maxY: 100,
                minX: 0,
                maxX: spots.isEmpty ? 1 : (spots.length - 1 + (forecastSpots.isNotEmpty ? 2 : 0)).toDouble(),
                lineBarsData: [
                  // Línea real
                  LineChartBarData(
                    spots: spots,
                    isCurved: spots.length > 3,
                    color: RCColors.orange,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(radius: 4, color: RCColors.orange, strokeWidth: 2, strokeColor: RCColors.card),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [RCColors.orange.withValues(alpha: 0.22), RCColors.orange.withValues(alpha: 0.0)],
                      ),
                    ),
                  ),
                  // Línea de pronóstico (discontinua)
                  if (forecastSpots.isNotEmpty)
                    LineChartBarData(
                      spots: forecastSpots,
                      isCurved: false,
                      color: RCColors.orange.withValues(alpha: 0.45),
                      barWidth: 2,
                      dashArray: [6, 5],
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(radius: 3, color: RCColors.orange.withValues(alpha: 0.6), strokeWidth: 0, strokeColor: Colors.transparent),
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                ],
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 25,
                    getTitlesWidget: (value, meta) {
                      if (value != 0 && value != 25 && value != 50 && value != 75 && value != 100) {
                        return const SizedBox.shrink();
                      }
                      return Text('${value.round()}%', style: TextStyle(color: RCColors.textSecondary, fontSize: 9));
                    },
                  )),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    interval: total <= 6 ? 1 : (total / 5).roundToDouble(),
                    getTitlesWidget: (value, meta) {
                      final idx = value.round();
                      if (idx < 0 || idx >= total) return const SizedBox.shrink();
                      return Text('${idx + 1}', style: TextStyle(color: RCColors.textSecondary, fontSize: 9));
                    },
                  )),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: v == 50 ? RCColors.divider.withValues(alpha: 0.8) : RCColors.divider.withValues(alpha: 0.4),
                    strokeWidth: v == 50 ? 1 : 0.5,
                    dashArray: v == 50 ? null : [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => Colors.black87,
                    getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                      final isForecast = s.barIndex == 1;
                      return LineTooltipItem(
                        isForecast
                            ? '~${s.y.toStringAsFixed(0)}% ${'pilot_chart_forecast_label'.tr}'
                            : '${s.y.toStringAsFixed(0)}%',
                        TextStyle(
                          color: isForecast ? Colors.orange.shade200 : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // ── Métricas debajo del gráfico ───────────────────────────────────
          const SizedBox(height: 12),
          Divider(color: RCColors.divider, height: 1),
          const SizedBox(height: 10),
          Row(children: [
            _buildMiniStat('pilot_chart_avg'.tr, '${avg.toStringAsFixed(1)}%',
                Icons.bar_chart, RCColors.orange),
            _buildMiniStatDivider(),
            _buildMiniStat(
              'pilot_chart_trend'.tr,
              slope != null ? '${slope > 0 ? '+' : ''}${slope.toStringAsFixed(2)}%' : '—',
              improving ? Icons.trending_up : (declining ? Icons.trending_down : Icons.trending_flat),
              improving ? Colors.green : (declining ? Colors.red : RCColors.textSecondary),
            ),
            _buildMiniStatDivider(),
            _buildMiniStat(
              'pilot_chart_forecast'.tr,
              forecast != null ? '~${forecast.toStringAsFixed(0)}%' : '—',
              Icons.auto_graph,
              Colors.purpleAccent,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildTrendBadge(double slope, bool improving, bool declining) {
    final color = improving ? Colors.green : (declining ? Colors.red : RCColors.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(improving ? Icons.trending_up : (declining ? Icons.trending_down : Icons.trending_flat),
            size: 12, color: color),
        const SizedBox(width: 4),
        Text('${slope > 0 ? '+' : ''}${slope.toStringAsFixed(2)}%${'trend_per_race'.tr}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Expanded(child: Column(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: RCColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: RCColors.textSecondary, fontSize: 10), textAlign: TextAlign.center),
    ]));
  }

  Widget _buildMiniStatDivider() => Container(width: 1, height: 36, color: RCColors.divider);

  // ───────── SECCIONES POR CAMPEONATO ─────────
  Widget _buildChampSection(String champKey) {
    final items = controller.groupedResults[champKey] ?? [];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: RCColors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    champKey,
                    style: TextStyle(
                      color: RCColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Text(
                  '${items.length} ${'pilot_races_count'.tr}',
                  style: TextStyle(color: RCColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: RCColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final r = entry.value;
                final isLast = i == items.length - 1;
                return _buildResultRow(r, isLast: isLast);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(PilotResult r, {required bool isLast}) {
    final pos = r.positionFinal;
    Color posColor;
    Color posBg;

    if (pos == 1) {
      posColor = Colors.black87;
      posBg = RCColors.gold;
    } else if (pos == 2) {
      posColor = Colors.black87;
      posBg = RCColors.silver;
    } else if (pos == 3) {
      posColor = Colors.black87;
      posBg = RCColors.bronze;
    } else {
      posColor = RCColors.textSecondary;
      posBg = RCColors.surface;
    }

    final dateStr = r.eventDate != null
        ? DateFormat('dd MMM yyyy', 'es_ES').format(r.eventDate!)
        : '—';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: posBg, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  pos != null ? '$pos°' : '—',
                  style: TextStyle(color: posColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.eventName,
                      style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(r.categoryName, style: TextStyle(color: RCColors.textSecondary, fontSize: 11)),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(color: RCColors.divider, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(dateStr, style: TextStyle(color: RCColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              if (r.qualyPosition == 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: RCColors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: RCColors.orange.withValues(alpha: 0.5)),
                  ),
                  child: const Text(
                    'POLE',
                    style: TextStyle(color: RCColors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: RCColors.divider, indent: 16, endIndent: 16),
      ],
    );
  }
}
