import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/network_measurement.dart';

class MeasurementRepository {
  final SupabaseClient _client;

  MeasurementRepository(this._client);

  Stream<List<NetworkMeasurement>> getMeasurementsStream() async* {
    // Contournement : Au lieu d'utiliser .stream() qui requiert le Realtime activé côté serveur,
    // on va interroger la base de données de manière classique (HTTP) toutes les 10 secondes.
    // Cela garantit que l'application fonctionne même si le Realtime n'est pas configuré.
    while (true) {
      try {
        final data = await _client
            .from('mesures_reseau')
            .select()
            .order('date_heure', ascending: false);

        yield (data as List<dynamic>)
            .map((json) => NetworkMeasurement.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Erreur lors de la récupération des données : $e');
      }
      // On attend 10 secondes avant de re-vérifier s'il y a de nouvelles données
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  Future<List<NetworkMeasurement>> getMeasurements() async {
    final response = await _client
        .from('mesures_reseau')
        .select()
        .order('date_heure', ascending: false);
    
    return response.map((json) => NetworkMeasurement.fromJson(json)).toList();
  }
}
