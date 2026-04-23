class UserProfile {
  final String id;
  final String? username;
  final String? email;
  final String? avatarUrl;
  final int karmaPoints;
  final String role;
  final DateTime? updatedAt;
  final int tasksCompleted;
  final int tasksCreated;

  UserProfile({
    required this.id,
    this.username,
    this.email,
    this.avatarUrl,
    this.karmaPoints = 0,
    this.role = 'neighbor',
    this.updatedAt,
    this.tasksCompleted = 0,
    this.tasksCreated = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      karmaPoints: json['karma_points'] ?? 0,
      role: json['role'] ?? 'neighbor',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      tasksCompleted: json['tasks_completed'] ?? 0,
      tasksCreated: json['tasks_created'] ?? 0,
    );
  }

  String get displayName => username ?? 'Neighbor';
  
  String get karmaLevel {
    if (karmaPoints >= 500) return 'Neighborhood Legend';
    if (karmaPoints >= 200) return 'Neighborhood Hero';
    if (karmaPoints >= 50) return 'Active Neighbor';
    return 'New Neighbor';
  }
  
  String get karmaLevelIcon {
    if (karmaPoints >= 500) return '👑';
    if (karmaPoints >= 200) return '🦸';
    if (karmaPoints >= 50) return '⭐';
    return '🌱';
  }
  
  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    int? karmaPoints,
    String? role,
    DateTime? updatedAt,
    int? tasksCompleted,
    int? tasksCreated,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      karmaPoints: karmaPoints ?? this.karmaPoints,
      role: role ?? this.role,
      updatedAt: updatedAt ?? this.updatedAt,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      tasksCreated: tasksCreated ?? this.tasksCreated,
    );
  }
}
