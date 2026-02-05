
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRepository {
  static final SupabaseRepository _instance = SupabaseRepository._internal();
  final SupabaseClient _client = Supabase.instance.client;

  factory SupabaseRepository() => _instance;

  SupabaseRepository._internal();

  // User-related methods

  // Insert a new user
  Future<void> insertUser({
    required String uuid,
    String? fullname,
    String? age,
    String? email,
    String? phone,
    String? address,
    String? bloodtype,
  }) async {
    await _client.from('user').insert({
      'uuid': uuid,
      'fullname': fullname,
      'age': age,
      'email': email,
      'phone': phone,
      'address': address,
      'bloodtype': bloodtype,
    });
  }

  // Fetch user by UUID
  Future<Map<String, dynamic>?> getUser(String uuid) async {
    final response = await _client.from('user').select().eq('uuid', uuid);
    return response.isNotEmpty ? response[0] : null;
  }

  // Update user by UUID
  Future<void> updateUser({
    required String uuid,
    String? fullname,
    String? age,
    String? email,
    String? phone,
    String? address,
    String? bloodtype,
  }) async {
    final updates = <String, dynamic>{};
    if (fullname != null) updates['fullname'] = fullname;
    if (age != null) updates['age'] = age;
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;
    if (address != null) updates['address'] = address;
    if (bloodtype != null) updates['bloodtype'] = bloodtype;

    await _client.from('user').update(updates).eq('uuid', uuid);
  }

  // Delete user by UUID
  Future<void> deleteUser(String uuid) async {
    await _client.from('user').delete().eq('uuid', uuid);
  }

  // Insert a new vital record
  Future<void> insertVital({
    required String name,
    required int age,
    required String bloodPressure,
    required String bloodSugar,
    required String date,
    required String time,
  }) async {
    await _client.from('vitals').insert({
      'name': name,
      'age': age,
      'blood_pressure': bloodPressure,
      'blood_sugar': bloodSugar,
      'date': date,
      'time': time,
    });
  }

  // Fetch all vital records
  Future<List<Map<String, dynamic>>> getVitals() async {
    final response = await _client.from('vitals').select();
    return response;
  }

  // Update a vital record by id
  Future<void> updateVital({
    required int id,
    String? name,
    int? age,
    String? bloodPressure,
    String? bloodSugar,
    String? date,
    String? time,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (age != null) updates['age'] = age;
    if (bloodPressure != null) updates['blood_pressure'] = bloodPressure;
    if (bloodSugar != null) updates['blood_sugar'] = bloodSugar;
    if (date != null) updates['date'] = date;
    if (time != null) updates['time'] = time;

    await _client.from('vitals').update(updates).eq('id', id);
  }

  // Delete a vital record by id
  Future<void> deleteVital(int id) async {
    await _client.from('vitals').delete().eq('id', id);
  }

  // Insert a new pressure record
  Future<void> insertPressure({
    required int userId,
    String? time,
    String? comment,
    double? value,
  }) async {
    await _client.from('pressure').insert({
      'user': userId,
      'time': time,
      'comment': comment,
      'value': value,
    });
  }

  // Insert a new sugar record
  Future<void> insertSugar({
    required int userId,
    String? time,
    String? comment,
    double? value,
  }) async {
    await _client.from('sugar').insert({
      'user': userId,
      'time': time,
      'comment': comment,
      'value': value,
    });
  }

  // Fetch pressure records for a user
  Future<List<Map<String, dynamic>>> getPressureRecords(int userId) async {
    final response = await _client
        .from('pressure')
        .select()
        .eq('user', userId)
        .order('time', ascending: false);
    return response;
  }

  // Fetch sugar records for a user
  Future<List<Map<String, dynamic>>> getSugarRecords(int userId) async {
    final response = await _client
        .from('sugar')
        .select()
        .eq('user', userId)
        .order('time', ascending: false);
    return response;
  }

  // Update pressure record
  Future<void> updatePressure({
    required int id,
    String? time,
    String? comment,
    double? value,
  }) async {
    final updates = <String, dynamic>{};
    if (time != null) updates['time'] = time;
    if (comment != null) updates['comment'] = comment;
    if (value != null) updates['value'] = value;

    await _client.from('pressure').update(updates).eq('id', id);
  }

  // Update sugar record
  Future<void> updateSugar({
    required int id,
    String? time,
    String? comment,
    double? value,
  }) async {
    final updates = <String, dynamic>{};
    if (time != null) updates['time'] = time;
    if (comment != null) updates['comment'] = comment;
    if (value != null) updates['value'] = value;

    await _client.from('sugar').update(updates).eq('id', id);
  }

  // Delete pressure record
  Future<void> deletePressure(int id) async {
    await _client.from('pressure').delete().eq('id', id);
  }

  // Delete sugar record
  Future<void> deleteSugar(int id) async {
    await _client.from('sugar').delete().eq('id', id);
  }
}