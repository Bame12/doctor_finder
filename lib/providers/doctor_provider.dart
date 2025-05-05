import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:doctor_finder_flutter/models/doctor_model.dart';
import 'package:doctor_finder_flutter/models/specialty_model.dart';
import 'package:doctor_finder_flutter/services/firestore_service.dart';
import 'package:doctor_finder_flutter/services/location_service.dart';
import 'package:doctor_finder_flutter/core/utils/distance_calculator.dart';

class DoctorProvider extends ChangeNotifier {
  List<DoctorModel> _doctors = [];
  List<DoctorModel> _filteredDoctors = [];
  List<SpecialtyModel> _specialties = [];
  SpecialtyModel? _selectedSpecialty;
  String _searchQuery = '';
  bool _isLoading = false;
  Position? _userLocation;
  bool _isLocationMode = true; // true for nearby, false for country-wide

  List<DoctorModel> get doctors => _filteredDoctors;
  List<SpecialtyModel> get specialties => _specialties;
  SpecialtyModel? get selectedSpecialty => _selectedSpecialty;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLocationMode => _isLocationMode;

  DoctorProvider() {
    _initialize();
  }

  void _initialize() {
    _setLoading(true);
    _fetchSpecialties();
    _checkLocationPermission();
    _subscribeToUpdates();
  }

  void _subscribeToUpdates() {
    FirestoreService.getDoctorsStream().listen((doctors) {
      _doctors = doctors;
      _filterDoctors();
      _setLoading(false);
    });
  }

  Future<void> _checkLocationPermission() async {
    final hasPermission = await LocationService.requestLocationPermission();
    if (hasPermission) {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    _userLocation = await LocationService.getCurrentLocation();
    _filterDoctors();
  }

  void _fetchSpecialties() {
    FirestoreService.getSpecialtiesStream().listen((specialties) {
      _specialties = specialties;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterDoctors();
  }

  void setSpecialtyFilter(SpecialtyModel? specialty) {
    _selectedSpecialty = specialty;
    _filterDoctors();
  }

  void toggleLocationMode() {
    _isLocationMode = !_isLocationMode;
    _filterDoctors();
  }

  void _filterDoctors() {
    List<DoctorModel> results = List.from(_doctors);

    // Apply location filter
    if (_isLocationMode && _userLocation != null) {
      results = results.where((doctor) {
        if (doctor.location == null) return false;

        final distance = DistanceCalculator.haversineDistance(
          _userLocation!.latitude,
          _userLocation!.longitude,
          doctor.location!.latitude,
          doctor.location!.longitude,
        );
        return distance <= 200; // 200 km radius
      }).toList();

      // Sort by distance
      results.sort((a, b) {
        if (a.location == null || b.location == null) return 0;

        final distanceA = DistanceCalculator.haversineDistance(
          _userLocation!.latitude,
          _userLocation!.longitude,
          a.location!.latitude,
          a.location!.longitude,
        );
        final distanceB = DistanceCalculator.haversineDistance(
          _userLocation!.latitude,
          _userLocation!.longitude,
          b.location!.latitude,
          b.location!.longitude,
        );
        return distanceA.compareTo(distanceB);
      });
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      results = results.where((doctor) =>
      doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doctor.city?.toLowerCase().contains(_searchQuery.toLowerCase()) == true
      ).toList();
    }

    // Apply specialty filter
    if (_selectedSpecialty != null) {
      results = results.where((doctor) =>
      doctor.specialty == _selectedSpecialty!.name
      ).toList();
    }

    _filteredDoctors = results;
    notifyListeners();
  }

  Future<DoctorModel?> getDoctor(String doctorId) async {
    try {
      return await FirestoreService.getDoctor(doctorId);
    } catch (e) {
      debugPrint('Error getting doctor: $e');
      return null;
    }
  }

  double? getDoctorDistance(DoctorModel doctor) {
    if (_userLocation == null || doctor.location == null) return null;

    return DistanceCalculator.haversineDistance(
      _userLocation!.latitude,
      _userLocation!.longitude,
      doctor.location!.latitude,
      doctor.location!.longitude,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}