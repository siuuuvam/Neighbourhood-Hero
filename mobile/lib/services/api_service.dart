import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request.dart';
import '../models/user.dart';
import '../config/constants.dart';

class ApiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<HelpRequest>> getNearbyRequests({
    required LatLng currentLocation,
    double radiusKm = 5.0,
    String? status,
  }) async {
    String query = '''
      help_requests (
        id,
        user_id,
        title,
        description,
        status,
        location,
        created_at,
        helper_id,
        profiles:user_id (
          username,
          karma_points
        ),
        helper:helper_id (
          username
        )
      )
    ''';

    var request = _supabase.from('help_requests').select(query);

    if (status != null) {
      request = request.eq('status', status);
    }

    final response = await request;
    
    if (response is List) {
      return response.map((json) => HelpRequest.fromJson({
        ...json as Map<String, dynamic>,
        'distance': _calculateDistance(
          currentLocation,
          HelpRequest.fromJson(json as Map<String, dynamic>).location,
        ),
      })).toList()
        ..sort((a, b) => (a.distance ?? 999).compareTo(b.distance ?? 999));
    }
    
    return [];
  }

  double _calculateDistance(LatLng from, LatLng to) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, from, to);
  }

  Future<HelpRequest> createRequest({
    required String title,
    required String description,
    required LatLng location,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final point = 'SRID=4326;POINT(${location.longitude} ${location.latitude})';

    final response = await _supabase.from('help_requests').insert({
      'user_id': user.id,
      'title': title,
      'description': description,
      'location': point,
      'status': 'open',
    }).select().single();

    return HelpRequest.fromJson(response);
  }

  Future<HelpRequest> acceptRequest(String requestId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _supabase.from('help_requests').update({
      'status': 'accepted',
      'helper_id': user.id,
    }).eq('id', requestId).select().single();

    return HelpRequest.fromJson(response);
  }

  Future<HelpRequest> completeRequest(String requestId, {int rating = 5}) async {
    final response = await http.post(
      Uri.parse('${AppConstants.backendBaseUrl}/complete-task'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requestId': requestId,
        'helperId': _supabase.auth.currentUser?.id,
      }),
    );

    if (response.statusCode == 200) {
      await _supabase.from('help_requests').update({
        'status': 'completed',
      }).eq('id', requestId);

      final result = await _supabase.from('help_requests').select().eq('id', requestId).single();
      return HelpRequest.fromJson(result);
    }

    throw Exception('Failed to complete request');
  }

  Future<HelpRequest> cancelRequest(String requestId) async {
    final response = await _supabase.from('help_requests').update({
      'status': 'open',
      'helper_id': null,
    }).eq('id', requestId).select().single();

    return HelpRequest.fromJson(response);
  }

  Future<List<HelpRequest>> getMyRequests({String? status}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    var request = _supabase.from('help_requests').select('''
      *,
      profiles:user_id (username, karma_points),
      helper:helper_id (username)
    ''').eq('user_id', user.id);

    if (status != null) {
      request = request.eq('status', status);
    }

    final response = await request.order('created_at', ascending: false);
    
    if (response is List) {
      return response.map((json) => HelpRequest.fromJson(json as Map<String, dynamic>)).toList();
    }
    
    return [];
  }

  Future<List<HelpRequest>> getTasksAccepted({String? status}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    var request = _supabase.from('help_requests').select('''
      *,
      profiles:user_id (username, karma_points),
      helper:helper_id (username)
    ''').eq('helper_id', user.id);

    if (status != null) {
      request = request.eq('status', status);
    }

    final response = await request.order('created_at', ascending: false);
    
    if (response is List) {
      return response.map((json) => HelpRequest.fromJson(json as Map<String, dynamic>)).toList();
    }
    
    return [];
  }

  Future<UserProfile> getUserProfile(String? userId) async {
    final id = userId ?? _supabase.auth.currentUser?.id;
    if (id == null) throw Exception('Not authenticated');

    final response = await _supabase.from('profiles').select().eq('id', id).single();
    
    final completedResponse = await _supabase
        .from('help_requests')
        .select('id')
        .eq('helper_id', id)
        .eq('status', 'completed');
    
    final createdResponse = await _supabase
        .from('help_requests')
        .select('id')
        .eq('user_id', id);

    return UserProfile.fromJson({
      ...response,
      'tasks_completed': (completedResponse as List).length,
      'tasks_created': (createdResponse as List).length,
    });
  }

  Future<UserProfile> updateProfile({
    String? username,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    updates['updated_at'] = DateTime.now().toIso8601String();

    await _supabase.from('profiles').update(updates).eq('id', user.id);
    
    return getUserProfile(user.id);
  }
}
