import 'package:latlong2/latlong.dart';

class HelpRequest {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String status;
  final LatLng location;
  final DateTime createdAt;
  final String? requesterUsername;
  final int? requesterKarma;
  final String? helperId;
  final String? helperUsername;
  final double? distance;

  HelpRequest({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.location,
    required this.createdAt,
    this.requesterUsername,
    this.requesterKarma,
    this.helperId,
    this.helperUsername,
    this.distance,
  });

  factory HelpRequest.fromJson(Map<String, dynamic> json) {
    LatLng location = const LatLng(0, 0);
    
    if (json['location'] != null) {
      location = _parseLocation(json['location']);
    } else if (json['latitude'] != null && json['longitude'] != null) {
      location = LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      );
    }
    
    final profiles = json['profiles'] as Map<String, dynamic>?;
    final helper = json['helper'] as Map<String, dynamic>?;

    return HelpRequest(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      location: location,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      requesterUsername: profiles?['username'],
      requesterKarma: profiles?['karma_points'],
      helperId: json['helper_id'],
      helperUsername: helper?['username'],
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
    );
  }

  static LatLng _parseLocation(dynamic locationData) {
    try {
      if (locationData is String) {
        final pointMatch = RegExp(r'POINT\s*\(\s*([-\d.]+)\s+([-\d.]+)\s*\)', 
            caseSensitive: false).firstMatch(locationData);
        if (pointMatch != null) {
          return LatLng(
            double.parse(pointMatch.group(2)!),
            double.parse(pointMatch.group(1)!),
          );
        }
      } else if (locationData is Map) {
        final coords = locationData['coordinates'];
        if (coords is List && coords.length >= 2) {
          return LatLng((coords[1] as num).toDouble(), (coords[0] as num).toDouble());
        }
      }
    } catch (e) {
      // Return default location on parse error
    }
    return const LatLng(37.7749, -122.4194);
  }

  HelpRequest copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? status,
    LatLng? location,
    DateTime? createdAt,
    String? requesterUsername,
    int? requesterKarma,
    String? helperId,
    String? helperUsername,
    double? distance,
  }) {
    return HelpRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      requesterUsername: requesterUsername ?? this.requesterUsername,
      requesterKarma: requesterKarma ?? this.requesterKarma,
      helperId: helperId ?? this.helperId,
      helperUsername: helperUsername ?? this.helperUsername,
      distance: distance ?? this.distance,
    );
  }
}

enum RequestStatus {
  open,
  accepted,
  completed;
  
  String get displayName {
    switch (this) {
      case RequestStatus.open:
        return 'Open';
      case RequestStatus.accepted:
        return 'In Progress';
      case RequestStatus.completed:
        return 'Completed';
    }
  }
}
