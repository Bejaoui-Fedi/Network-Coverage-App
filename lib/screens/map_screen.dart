import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/measurements_provider.dart';
import '../models/network_measurement.dart';
import 'package:intl/intl.dart';
import '../utils/reload.dart';
import '../theme/app_theme.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRefreshing = ref.watch(isRefreshingProvider);
    final measurements = ref.watch(filteredMeasurementsProvider);

    if (isRefreshing) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryOrange),
      );
    }

    final mapCenter = measurements.isNotEmpty 
        ? LatLng(measurements.first.latitude, measurements.first.longitude)
        : const LatLng(46.603354, 1.888334); // Center of France

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: mapCenter,
            initialZoom: 6.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.orangedrs.networkcoverage',
            ),
            MarkerLayer(
              markers: measurements.reversed.map((m) {
                return Marker(
                  point: LatLng(m.latitude, m.longitude),
                  width: 30,
                  height: 30,
                  child: GestureDetector(
                    onTap: () => _showMeasurementDetails(context, m),
                    child: Icon(
                      Icons.location_on,
                      color: _getRsrpColor(m.rsrp),
                      size: 30,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        // Legend
        Positioned(
          bottom: 16,
          left: 16,
          child: Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final bgColor = isDark
                  ? Colors.grey[900]!.withOpacity(0.92)
                  : Colors.white.withOpacity(0.95);
              final textColor = isDark ? Colors.white : Colors.black87;

              return Card(
                color: bgColor,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Légende (RSRP)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildLegendItem(Colors.green, 'Excellent (≥ -80)', textColor),
                      _buildLegendItem(Colors.yellow.shade700, 'Bon (-80 à -90)', textColor),
                      _buildLegendItem(Colors.orange, 'Moyen (-90 à -100)', textColor),
                      _buildLegendItem(Colors.red, 'Faible (< -100)', textColor),
                      _buildLegendItem(Colors.grey, 'Inconnu', textColor),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Refresh Button
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton.small(
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
            backgroundColor: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF1A1D27) 
                : Colors.white,
            foregroundColor: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black87,
            elevation: 4,
            tooltip: 'Actualiser la page',
            child: const Icon(Icons.refresh_rounded),
          ),
        )
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: textColor)),
        ],
      ),
    );
  }

  Color _getRsrpColor(int? rsrp) {
    if (rsrp == null) return Colors.grey;
    if (rsrp >= -80) return Colors.green;
    if (rsrp >= -90) return Colors.yellow;
    if (rsrp >= -100) return Colors.orange;
    return Colors.red;
  }

  void _showMeasurementDetails(BuildContext context, NetworkMeasurement m) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 700;
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    Widget content = Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D27) : Colors.white,
        borderRadius: BorderRadius.circular(isWide ? 24 : 0),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isWide)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E3247) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
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
              _chip('Device ID', m.deviceId, isDark),
              _chip('Date', fmt.format(m.dateHeure.toLocal()), isDark),
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

    if (isWide) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: content,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: content,
        ),
      );
    }
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
