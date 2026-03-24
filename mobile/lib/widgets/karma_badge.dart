import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../models/user.dart';

class KarmaBadge extends StatelessWidget {
  final int karmaPoints;
  final bool showLabel;
  final double size;

  const KarmaBadge({
    super.key,
    required this.karmaPoints,
    this.showLabel = true,
    this.size = 40,
  });

  String get levelIcon {
    if (karmaPoints >= 500) return '👑';
    if (karmaPoints >= 200) return '🦸';
    if (karmaPoints >= 50) return '⭐';
    return '🌱';
  }

  String get levelName {
    if (karmaPoints >= 500) return 'Legend';
    if (karmaPoints >= 200) return 'Hero';
    if (karmaPoints >= 50) return 'Active';
    return 'New';
  }

  Color get levelColor {
    if (karmaPoints >= 500) return AppColors.karmaPlatinum;
    if (karmaPoints >= 200) return AppColors.karmaGold;
    if (karmaPoints >= 50) return AppColors.karmaSilver;
    return AppColors.karmaBronze;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 12 : 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: levelColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: levelColor,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            levelIcon,
            style: TextStyle(fontSize: size * 0.4),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$karmaPoints',
                  style: TextStyle(
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  levelName,
                  style: TextStyle(
                    fontSize: size * 0.25,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final UserProfile? user;
  final double radius;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.user,
    this.radius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.accent,
        child: Text(
          (user?.username ?? 'N')[0].toUpperCase(),
          style: TextStyle(
            fontSize: radius * 0.8,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
