import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/colors.dart';
import '../models/request.dart';
import '../providers/app_provider.dart';
import '../widgets/custom_button.dart';

class RequestDetailScreen extends StatelessWidget {
  final HelpRequest request;

  const RequestDetailScreen({
    super.key,
    required this.request,
  });

  Color _getStatusColor() {
    switch (request.status) {
      case 'open':
        return AppColors.statusOpen;
      case 'accepted':
        return AppColors.statusAccepted;
      case 'completed':
        return AppColors.statusCompleted;
      default:
        return AppColors.textLight;
    }
  }

  String _formatDate() {
    return DateFormat('MMM d, y • h:mm a').format(request.createdAt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final isOwner = request.userId == provider.currentUser?.id;
          final isHelper = request.helperId == provider.currentUser?.id;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  color: _getStatusColor().withValues(alpha: 0.1),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getStatusIcon(),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          request.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(),
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                            ),
                          ),
                          if (request.distance != null) ...[
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${request.distance!.toStringAsFixed(1)}km away',
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          request.description.isNotEmpty
                              ? request.description
                              : 'No description provided',
                          style: TextStyle(
                            fontSize: 16,
                            color: request.description.isNotEmpty
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Posted By',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.accent,
                              child: Text(
                                (request.requesterUsername ?? 'N')[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.requesterUsername ?? 'Anonymous',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  if (request.requesterKarma != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 14,
                                          color: AppColors.karmaGold,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${request.requesterKarma} Karma Points',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (request.helperUsername != null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Helper',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.success,
                                child: const Icon(
                                  Icons.volunteer_activism,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  request.helperUsername!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      if (request.status == 'open' && !isOwner) ...[
                        CustomButton(
                          text: 'Accept & Help',
                          onPressed: () => _showAcceptDialog(context, provider),
                          icon: Icons.volunteer_activism,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.karmaGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.star, color: AppColors.karmaGold),
                              SizedBox(width: 8),
                              Text(
                                'Earn 50 Karma Points!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (request.status == 'accepted' && isOwner) ...[
                        CustomButton(
                          text: 'Confirm Task Completed',
                          onPressed: () => _showCompleteDialog(context, provider),
                          icon: Icons.check_circle,
                          backgroundColor: AppColors.success,
                        ),
                        const SizedBox(height: 12),
                        OutlinedCustomButton(
                          text: 'Cancel Request',
                          onPressed: () => _showCancelDialog(context, provider),
                          icon: Icons.cancel,
                          borderColor: AppColors.error,
                          foregroundColor: AppColors.error,
                        ),
                      ],
                      if (request.status == 'accepted' && isHelper) ...[
                        CustomButton(
                          text: 'Mark as Completed',
                          onPressed: () => _showCompleteDialog(context, provider),
                          icon: Icons.check_circle,
                          backgroundColor: AppColors.success,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (request.status) {
      case 'open':
        return Icons.help;
      case 'accepted':
        return Icons.hourglass_top;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  void _showAcceptDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You want to help with: ${request.title}'),
            const SizedBox(height: 12),
            const Text(
              'By accepting, you agree to help the neighbor with their request.',
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.karmaGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: AppColors.karmaGold),
                  SizedBox(width: 8),
                  Text(
                    'Earn 50 Karma Points!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(context);
              final result = await provider.acceptRequest(request.id);
              if (result != null && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request accepted! Contact the neighbor.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Task?'),
        content: const Text(
          'Are you sure the task has been completed? This will award karma points to the helper.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              Navigator.pop(context);
              final result = await provider.completeRequest(request.id);
              if (result != null && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task completed! Karma points awarded.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Yes, Complete'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: const Text(
          'Are you sure you want to cancel this request? The helper will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Request'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await provider.cancelRequest(request.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request cancelled.'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
  }
}
