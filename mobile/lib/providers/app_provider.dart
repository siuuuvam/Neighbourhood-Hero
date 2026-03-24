import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();

  UserProfile? _currentUser;
  List<HelpRequest> _nearbyRequests = [];
  List<HelpRequest> _myRequests = [];
  List<HelpRequest> _acceptedTasks = [];
  LatLng? _currentLocation;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<AuthState>? _authSubscription;

  UserProfile? get currentUser => _currentUser;
  List<HelpRequest> get nearbyRequests => _nearbyRequests;
  List<HelpRequest> get myRequests => _myRequests;
  List<HelpRequest> get acceptedTasks => _acceptedTasks;
  LatLng? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.currentUser != null;

  AppProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((state) {
      if (state.event == AuthChangeEvent.signedIn) {
        loadUserProfile();
      } else if (state.event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _nearbyRequests = [];
        _myRequests = [];
        _acceptedTasks = [];
        notifyListeners();
      }
    });
  }

  Future<void> loadUserProfile() async {
    try {
      _setLoading(true);
      _currentUser = await _apiService.getUserProfile(null);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      _currentLocation = _locationService.positionToLatLng(position);
      notifyListeners();
    } catch (e) {
      _currentLocation = const LatLng(37.7749, -122.4194);
      _error = 'Could not get location: $e';
      notifyListeners();
    }
  }

  Future<void> loadNearbyRequests({double radiusKm = 5.0, String? status}) async {
    if (_currentLocation == null) await loadCurrentLocation();
    if (_currentLocation == null) return;

    try {
      _setLoading(true);
      _nearbyRequests = await _apiService.getNearbyRequests(
        currentLocation: _currentLocation!,
        radiusKm: radiusKm,
        status: status,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyRequests({String? status}) async {
    try {
      _setLoading(true);
      _myRequests = await _apiService.getMyRequests(status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAcceptedTasks({String? status}) async {
    try {
      _setLoading(true);
      _acceptedTasks = await _apiService.getTasksAccepted(status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<HelpRequest?> createRequest({
    required String title,
    required String description,
  }) async {
    if (_currentLocation == null) await loadCurrentLocation();
    if (_currentLocation == null) {
      _error = 'Location not available';
      notifyListeners();
      return null;
    }

    try {
      _setLoading(true);
      final request = await _apiService.createRequest(
        title: title,
        description: description,
        location: _currentLocation!,
      );
      _myRequests.insert(0, request);
      notifyListeners();
      return request;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<HelpRequest?> acceptRequest(String requestId) async {
    try {
      _setLoading(true);
      final request = await _apiService.acceptRequest(requestId);
      
      final index = _nearbyRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _nearbyRequests[index] = request;
      }
      
      _acceptedTasks.insert(0, request);
      notifyListeners();
      return request;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<HelpRequest?> completeRequest(String requestId) async {
    try {
      _setLoading(true);
      final request = await _apiService.completeRequest(requestId);
      
      await loadUserProfile();
      
      final acceptedIndex = _acceptedTasks.indexWhere((r) => r.id == requestId);
      if (acceptedIndex != -1) {
        _acceptedTasks[acceptedIndex] = request;
      }
      
      return request;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<HelpRequest?> cancelRequest(String requestId) async {
    try {
      _setLoading(true);
      final request = await _apiService.cancelRequest(requestId);
      
      final acceptedIndex = _acceptedTasks.indexWhere((r) => r.id == requestId);
      if (acceptedIndex != -1) {
        _acceptedTasks.removeAt(acceptedIndex);
      }
      
      notifyListeners();
      return request;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      await _authService.signIn(email: email, password: password);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      _setLoading(true);
      await _authService.signUp(
        email: email,
        password: password,
        username: username,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      _error = e.toString();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
