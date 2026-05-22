import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../supabase/supabase_manager.dart';
import 'models/city_model.dart';

class CityApi {
  final SupabaseClient _client = SupabaseManager.client;

  Future<List<CityModel>> getCities() async {
    final data = await _client
        .from('vn_cities')
        .select()
        .order('name', ascending: true);

    return (data as List)
        .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
