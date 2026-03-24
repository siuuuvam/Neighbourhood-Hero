import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/app_provider.dart';
import '../widgets/request_card.dart';
import '../widgets/karma_badge.dart';
import 'create_request_screen.dart';
import 'profile_screen.dart';
import 'request_detail_screen.dart';
import 'my_requests_screen.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  int _selectedTab = 0;
  bool _showListView = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<AppProvider>();
    await provider.loadCurrentLocation();
    await provider.loadNearbyRequests();
    await provider.loadUserProfile();
  }

  void _showRequestDetails(request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailScreen(request: request),
      ),
    );
  }

  void _showAcceptDialog(request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Help Request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You want to help with: ${request.title}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: AppColors.karmaGold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Earn 50 Karma Points!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final result = await context.read<AppProvider>().acceptRequest(request.id);
              if (result != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request accepted! Contact the neighbor to help.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildMapView(),
          _buildListView(),
          const MyRequestsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() => _selectedTab = index);
          if (index == 1 || index == 2) {
            context.read<AppProvider>().loadNearbyRequests();
          }
          if (index == 2) {
            context.read<AppProvider>().loadMyRequests();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'My Tasks',
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final markers = provider.nearbyRequests.map((request) {
          return Marker(
            point: request.location,
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () => _showRequestDetails(request),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getMarkerColor(request.status),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getMarkerIcon(request.status),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getMarkerColor(request.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();

        if (provider.currentLocation != null) {
          markers.add(
            Marker(
              point: provider.currentLocation!,
              width: 30,
              height: 30,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: provider.currentLocation ?? const LatLng(37.7749, -122.4194),
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.neighborhood_hero',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${provider.nearbyRequests.length} nearby',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                      child: KarmaBadge(
                        karmaPoints: provider.currentUser?.karmaPoints ?? 0,
                        showLabel: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'location',
                    onPressed: () {
                      if (provider.currentLocation != null) {
                        _mapController.move(provider.currentLocation!, 14);
                      }
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'add',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
                      );
                    },
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListView() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.nearbyRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.nearbyRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: AppColors.textLight.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No requests nearby',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Be the first to ask for help!',
                  style: TextStyle(color: AppColors.textLight),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadNearbyRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 100),
            itemCount: provider.nearbyRequests.length,
            itemBuilder: (context, index) {
              final request = provider.nearbyRequests[index];
              final isOwner = request.userId == provider.currentUser?.id;
              
              return RequestCard(
                request: request,
                isOwner: isOwner,
                showActions: true,
                onTap: () => _showRequestDetails(request),
                onAccept: () => _showAcceptDialog(request),
              );
            },
          ),
        );
      },
    );
  }

  Color _getMarkerColor(String status) {
    switch (status) {
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

  IconData _getMarkerIcon(String status) {
    switch (status) {
      case 'open':
        return Icons.help;
      case 'accepted':
        return Icons.hourglass_top;
      case 'completed':
        return Icons.check;
      default:
        return Icons.help;
    }
  }
}
