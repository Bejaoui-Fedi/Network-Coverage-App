import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/measurements_provider.dart';
import '../models/network_measurement.dart';
import '../theme/app_theme.dart';
import '../utils/reload.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRefreshing = ref.watch(isRefreshingProvider);
    final measurements = ref.watch(filteredMeasurementsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd/MM/yy HH:mm');

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
            Icon(Icons.table_rows_rounded,
                size: 56, color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
            const SizedBox(height: 16),
            Text('Aucune donnée',
                style: TextStyle(
                    color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isWide ? 20 : 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mesures', style: Theme.of(context).textTheme.headlineMedium),
                        Text('${measurements.length} entrées',
                            style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                      ],
                    ),
                  ),
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
            ),

            // Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: isWide ? 20 : 14),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth - (isWide ? 40 : 28)),
                  child: Container(
                    width: 1160,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : const Color(0xFFE8EBF0),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header row
                          _buildHeaderRow(isDark),
                          const Divider(height: 1),
                          // Data rows
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: measurements.length,
                              itemBuilder: (context, i) {
                                return _buildDataRow(context, measurements[i], i, isDark, dateFormat);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildHeaderRow(bool isDark) {
    final headers = ['Date & Heure', 'Device ID', 'Opérateur', 'Réseau', 'RSRP', 'RSRQ', 'RSSI', 'SNR', 'Latence', 'Download', 'Upload', 'PCI', 'Bande'];
    return Container(
      color: isDark
          ? AppTheme.primaryOrange.withOpacity(0.08)
          : AppTheme.primaryOrange.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: headers.map((h) {
          double w = 70;
          if (h == 'Date & Heure') w = 140;
          else if (h == 'Device ID' || h == 'Opérateur') w = 110;
          else if (h == 'Download' || h == 'Upload') w = 90;
          else if (h == 'PCI') w = 60;
          
          return SizedBox(
            width: w,
            child: Text(
              h,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.lightOrange : AppTheme.darkOrange,
                letterSpacing: 0.5,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, NetworkMeasurement m, int index, bool isDark, DateFormat fmt) {
    final isEven = index % 2 == 0;
    final rowBg = isEven
        ? Colors.transparent
        : (isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.015));

    return InkWell(
      onTap: () => _showDetails(context, m, isDark),
      child: Container(
        color: rowBg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(fmt.format(m.dateHeure),
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151))),
            ),
            SizedBox(
              width: 110,
              child: Text(m.deviceId,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF111827))),
            ),
            SizedBox(
              width: 110,
              child: _buildOperatorBadge(m.operateur),
            ),
            SizedBox(
              width: 70,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(m.typeReseau,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryOrange)),
              ),
            ),
            SizedBox(width: 70, child: _buildSignalValue(m.rsrp?.toString() ?? '-', m.rsrp, isDark)),
            SizedBox(width: 70, child: Text(m.rsrq?.toString() ?? '-', style: _dataStyle(isDark))),
            SizedBox(width: 70, child: Text(m.rssi?.toString() ?? '-', style: _dataStyle(isDark))),
            SizedBox(width: 70, child: Text(m.snr?.toStringAsFixed(1) ?? '-', style: _dataStyle(isDark))),
            SizedBox(width: 70, child: Text(m.latence != null ? '${m.latence} ms' : '-', style: _dataStyle(isDark))),
            SizedBox(width: 90, child: Text(m.downloadSpeed != null ? '${m.downloadSpeed!.toStringAsFixed(1)} Mbps' : '-', style: _dataStyle(isDark))),
            SizedBox(width: 90, child: Text(m.uploadSpeed != null ? '${m.uploadSpeed!.toStringAsFixed(1)} Mbps' : '-', style: _dataStyle(isDark))),
            SizedBox(width: 60, child: Text(m.pci?.toString() ?? '-', style: _dataStyle(isDark))),
            SizedBox(width: 70, child: Text(m.band?.toString() ?? '-', style: _dataStyle(isDark))),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorBadge(String op) {
    Color color;
    switch (op.toLowerCase()) {
      case 'orange': color = AppTheme.primaryOrange; break;
      case 'sfr': color = const Color(0xFFEF4444); break;
      case 'bouygues': color = const Color(0xFF3B82F6); break;
      default: color = const Color(0xFF6B7280);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(op, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
      ],
    );
  }

  Widget _buildSignalValue(String text, int? rsrp, bool isDark) {
    Color color;
    if (rsrp == null) {
      color = const Color(0xFF9CA3AF);
    } else if (rsrp >= -80) {
      color = Colors.green;
    } else if (rsrp >= -90) {
      color = const Color(0xFFF59E0B);
    } else if (rsrp >= -100) {
      color = Colors.orange;
    } else {
      color = const Color(0xFFEF4444);
    }
    return Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color));
  }

  TextStyle _dataStyle(bool isDark) {
    return TextStyle(
      fontSize: 12,
      color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
    );
  }

  void _showDetails(BuildContext context, NetworkMeasurement m, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailsSheet(measurement: m, isDark: isDark),
    );
  }
}

class _DetailsSheet extends StatelessWidget {
  final NetworkMeasurement measurement;
  final bool isDark;
  const _DetailsSheet({required this.measurement, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final m = measurement;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text('Détails de la mesure',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827))),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _chip('Device', m.deviceId, isDark),
              _chip('Opérateur', m.operateur, isDark),
              _chip('Réseau', m.typeReseau, isDark),
              _chip('RSRP', '${m.rsrp ?? "N/A"} dBm', isDark),
              _chip('RSRQ', '${m.rsrq ?? "N/A"} dB', isDark),
              _chip('RSSI', '${m.rssi ?? "N/A"} dBm', isDark),
              _chip('SNR', '${m.snr?.toStringAsFixed(1) ?? "N/A"} dB', isDark),
              if (m.latence != null) _chip('Latence', '${m.latence} ms', isDark),
              if (m.downloadSpeed != null)
                _chip('Download', '${m.downloadSpeed!.toStringAsFixed(2)} Mbps', isDark),
              if (m.uploadSpeed != null)
                _chip('Upload', '${m.uploadSpeed!.toStringAsFixed(2)} Mbps', isDark),
              if (m.pci != null) _chip('PCI', '${m.pci}', isDark),
              if (m.band != null) _chip('Bande', '${m.band}', isDark),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2D3D).withOpacity(0.5) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF3F445E) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827))),
        ],
      ),
    );
  }
}
