import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/measurements_provider.dart';
import '../theme/app_theme.dart';
import '../utils/reload.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRefreshing = ref.watch(isRefreshingProvider);
    final measurements = ref.watch(filteredMeasurementsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isRefreshing) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryOrange),
      );
    }

    if (measurements.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.signal_wifi_off_rounded,
                size: 64, color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
            const SizedBox(height: 16),
            Text('Aucune donnée disponible',
                style: TextStyle(
                    color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    final totalMeasurements = measurements.length;
    final uniqueDevices = measurements.map((m) => m.deviceId).toSet().length;
    final latestMeasurement = measurements.first.dateHeure;

    final operateurCounts = <String, int>{};
    for (var m in measurements) {
      operateurCounts[m.operateur] = (operateurCounts[m.operateur] ?? 0) + 1;
    }

    double sumRsrp = 0;
    int countRsrp = 0;
    for (var m in measurements) {
      if (m.rsrp != null) {
        sumRsrp += m.rsrp!;
        countRsrp++;
      }
    }
    final avgRsrp = countRsrp > 0 ? (sumRsrp / countRsrp).toStringAsFixed(1) : 'N/A';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final chartHeight = isWide
            ? (constraints.maxHeight - 260).clamp(200.0, 380.0)
            : 220.0;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(isWide ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Vue d'ensemble",
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 2),
                        Text(
                          '${measurements.length} mesures enregistrées',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Refresh indicator & Button
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('Live',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          ref.read(isRefreshingProvider.notifier).state = true;
                          ref.invalidate(measurementsStreamProvider);
                          await Future.delayed(const Duration(milliseconds: 600));
                          ref.read(isRefreshingProvider.notifier).state = false;
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Données actualisées avec succès'), duration: Duration(seconds: 2)),
                            );
                          }
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        tooltip: 'Actualiser la page',
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // KPI Grid
              isWide
                  ? Row(
                      children: [
                        Expanded(child: _buildKpiCard(context, isDark, 'Mesures Totales', totalMeasurements.toString(), Icons.analytics_rounded, AppTheme.primaryOrange)),
                        const SizedBox(width: 14),
                        Expanded(child: _buildKpiCard(context, isDark, 'Véhicules', uniqueDevices.toString(), Icons.directions_car_rounded, const Color(0xFF6366F1))),
                        const SizedBox(width: 14),
                        Expanded(child: _buildKpiCard(context, isDark, 'Dernière Mesure',
                          '${latestMeasurement.day.toString().padLeft(2, '0')}/${latestMeasurement.month.toString().padLeft(2, '0')} ${latestMeasurement.hour.toString().padLeft(2, '0')}:${latestMeasurement.minute.toString().padLeft(2, '0')}',
                          Icons.access_time_rounded, const Color(0xFF10B981))),
                        const SizedBox(width: 14),
                        Expanded(child: _buildKpiCard(context, isDark, 'Moy. RSRP', '$avgRsrp dBm', Icons.signal_cellular_alt_rounded, const Color(0xFFF59E0B))),
                      ],
                    )
                  : Column(
                      children: [
                        Row(children: [
                          Expanded(child: _buildKpiCard(context, isDark, 'Mesures', totalMeasurements.toString(), Icons.analytics_rounded, AppTheme.primaryOrange)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildKpiCard(context, isDark, 'Véhicules', uniqueDevices.toString(), Icons.directions_car_rounded, const Color(0xFF6366F1))),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _buildKpiCard(context, isDark, 'Dernière Mesure',
                            '${latestMeasurement.day.toString().padLeft(2, '0')}/${latestMeasurement.month} ${latestMeasurement.hour.toString().padLeft(2, '0')}:${latestMeasurement.minute.toString().padLeft(2, '0')}',
                            Icons.access_time_rounded, const Color(0xFF10B981))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildKpiCard(context, isDark, 'Moy. RSRP', '$avgRsrp dBm', Icons.signal_cellular_alt_rounded, const Color(0xFFF59E0B))),
                        ]),
                      ],
                    ),

              const SizedBox(height: 24),

              // Chart section
              _buildSectionHeader(context, 'Répartition par Opérateur', isDark),
              const SizedBox(height: 14),

              Container(
                height: chartHeight,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : const Color(0xFFE8EBF0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isWide
                      ? Row(
                          children: [
                            Expanded(flex: 2, child: _buildPieChart(operateurCounts, chartHeight)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildLegend(operateurCounts, isDark, context)),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(child: _buildPieChart(operateurCounts, chartHeight)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard(BuildContext context, bool isDark, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE8EBF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _buildPieChart(Map<String, int> counts, double height) {
    return PieChart(
      PieChartData(
        sections: counts.entries.map((e) {
          final color = _getColorForOperator(e.key);
          return PieChartSectionData(
            color: color,
            value: e.value.toDouble(),
            title: e.value.toString(),
            radius: (height * 0.30).clamp(40.0, 100.0),
            titleStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 3,
        centerSpaceRadius: (height * 0.12).clamp(20.0, 50.0),
        pieTouchData: PieTouchData(enabled: true),
      ),
    );
  }

  Widget _buildLegend(Map<String, int> counts, bool isDark, BuildContext context) {
    final total = counts.values.fold(0, (a, b) => a + b);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: counts.entries.map((e) {
        final color = _getColorForOperator(e.key);
        final pct = total > 0 ? (e.value / total * 100).toStringAsFixed(0) : '0';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  e.key,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForOperator(String operateur) {
    switch (operateur.toLowerCase()) {
      case 'orange': return AppTheme.primaryOrange;
      case 'sfr': return const Color(0xFFEF4444);
      case 'bouygues': return const Color(0xFF3B82F6);
      case 'free': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF9CA3AF);
    }
  }
}
