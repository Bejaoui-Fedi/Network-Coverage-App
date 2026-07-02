import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/network_measurement.dart';
import '../repositories/measurement_repository.dart';
import 'supabase_provider.dart';

final measurementRepositoryProvider = Provider<MeasurementRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client != null) {
    return MeasurementRepository(client);
  }
  return null;
});

final measurementsStreamProvider = StreamProvider<List<NetworkMeasurement>>((ref) {
  final repository = ref.watch(measurementRepositoryProvider);
  if (repository != null) {
    return repository.getMeasurementsStream();
  }
  return Stream.value([]);
});

class IsRefreshingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
}

final isRefreshingProvider = NotifierProvider<IsRefreshingNotifier, bool>(() {
  return IsRefreshingNotifier();
});

class MeasurementFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? operateur;
  final String? typeReseau;
  final String? deviceId;

  MeasurementFilters({
    this.startDate,
    this.endDate,
    this.operateur,
    this.typeReseau,
    this.deviceId,
  });

  MeasurementFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? operateur,
    String? typeReseau,
    String? deviceId,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearOperateur = false,
    bool clearTypeReseau = false,
    bool clearDeviceId = false,
  }) {
    return MeasurementFilters(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      operateur: clearOperateur ? null : (operateur ?? this.operateur),
      typeReseau: clearTypeReseau ? null : (typeReseau ?? this.typeReseau),
      deviceId: clearDeviceId ? null : (deviceId ?? this.deviceId),
    );
  }
}

class MeasurementFiltersNotifier extends Notifier<MeasurementFilters> {
  @override
  MeasurementFilters build() {
    return MeasurementFilters();
  }

  void updateFilters(MeasurementFilters newFilters) {
    state = newFilters;
  }
}

final measurementFiltersProvider = NotifierProvider<MeasurementFiltersNotifier, MeasurementFilters>(() {
  return MeasurementFiltersNotifier();
});

final filteredMeasurementsProvider = Provider<List<NetworkMeasurement>>((ref) {
  final asyncMeasurements = ref.watch(measurementsStreamProvider);
  final filters = ref.watch(measurementFiltersProvider);

  return asyncMeasurements.when(
    data: (measurements) {
      return measurements.where((m) {
        if (filters.startDate != null && m.dateHeure.isBefore(filters.startDate!)) return false;
        if (filters.endDate != null && m.dateHeure.isAfter(filters.endDate!)) return false;
        if (filters.operateur != null && m.operateur != filters.operateur) return false;
        if (filters.typeReseau != null && m.typeReseau != filters.typeReseau) return false;
        if (filters.deviceId != null && m.deviceId != filters.deviceId) return false;
        return true;
      }).toList();
    },
    loading: () => [],
    error: (error, stackTrace) {
      print('Erreur Supabase: $error');
      print(stackTrace);
      return [];
    },
  );
});

