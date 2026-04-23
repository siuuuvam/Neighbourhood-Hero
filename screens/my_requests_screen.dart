import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/app_provider.dart';
import '../widgets/request_card.dart';
import '../widgets/karma_badge.dart';
import 'request_detail_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<AppProvider>();
    await provider.loadMyRequests();
    await provider.loadAcceptedTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'My Requests'),
            Tab(text: 'Accepted'),
          ],
        ),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: KarmaBadge(
                    karmaPoints: provider.currentUser?.karmaPoints ?? 0,
                    showLabel: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyRequestsList(),
          _buildAcceptedTasksList(),
        ],
      ),
    );
  }

  Widget _buildMyRequestsList() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.myRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.myRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 80,
                  color: AppColors.textLight.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No requests yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create a request to get help from neighbors',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          );
        }

        final openRequests = provider.myRequests
            .where((r) => r.status == 'open')
            .toList();
        final acceptedRequests = provider.myRequests
            .where((r) => r.status == 'accepted')
            .toList();
        final completedRequests = provider.myRequests
            .where((r) => r.status == 'completed')
            .toList();

        return RefreshIndicator(
          onRefresh: () => provider.loadMyRequests(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (openRequests.isNotEmpty) ...[
                _buildSectionHeader('Open', openRequests.length, AppColors.statusOpen),
                ...openRequests.map((r) => RequestCard(
                      request: r,
                      isOwner: true,
                      showActions: true,
                      onTap: () => _navigateToDetail(r),
                      onCancel: () => _cancelRequest(r),
                    )),
                const SizedBox(height: 16),
              ],
              if (acceptedRequests.isNotEmpty) ...[
                _buildSectionHeader('In Progress', acceptedRequests.length, AppColors.statusAccepted),
                ...acceptedRequests.map((r) => RequestCard(
                      request: r,
                      isOwner: true,
                      showActions: true,
                      onTap: () => _navigateToDetail(r),
                      onComplete: () => _completeRequest(r),
                      onCancel: () => _cancelRequest(r),
                    )),
                const SizedBox(height: 16),
              ],
              if (completedRequests.isNotEmpty) ...[
                _buildSectionHeader('Completed', completedRequests.length, AppColors.statusCompleted),
                ...completedRequests.map((r) => RequestCard(
                      request: r,
                      isOwner: true,
                      showActions: false,
                      onTap: () => _navigateToDetail(r),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAcceptedTasksList() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.acceptedTasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.acceptedTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.volunteer_activism,
                  size: 80,
                  color: AppColors.textLight.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No tasks accepted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Accept requests from neighbors to earn karma!',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          );
        }

        final inProgressTasks = provider.acceptedTasks
            .where((r) => r.status == 'accepted')
            .toList();
        final completedTasks = provider.acceptedTasks
            .where((r) => r.status == 'completed')
            .toList();

        return RefreshIndicator(
          onRefresh: () => provider.loadAcceptedTasks(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (inProgressTasks.isNotEmpty) ...[
                _buildSectionHeader('In Progress', inProgressTasks.length, AppColors.statusAccepted),
                ...inProgressTasks.map((r) => RequestCard(
                      request: r,
                      isOwner: false,
                      showActions: true,
                      onTap: () => _navigateToDetail(r),
                      onComplete: () => _completeRequest(r),
                    )),
                const SizedBox(height: 16),
              ],
              if (completedTasks.isNotEmpty) ...[
                _buildSectionHeader('Completed', completedTasks.length, AppColors.statusCompleted),
                ...completedTasks.map((r) => RequestCard(
                      request: r,
                      isOwner: false,
                      showActions: false,
                      onTap: () => _navigateToDetail(r),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailScreen(request: request),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _completeRequest(request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Task?'),
        content: const Text('Confirm that the task has been completed successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AppProvider>().completeRequest(request.id);
      await context.read<AppProvider>().loadUserProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task completed! Karma points awarded.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _cancelRequest(request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: const Text('Are you sure you want to cancel this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AppProvider>().cancelRequest(request.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request cancelled.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }
}
