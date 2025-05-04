import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  // Firebase instances
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static bool _initialized = false;

  // Initialize Firebase services
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase not initialized. Call Firebase.initializeApp() first.');
      }

      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;

      // Don't enable persistence on desktop platforms
      if (!kIsWeb && !_isDesktop()) {
        try {
          await _firestore!.enablePersistence();
        } catch (e) {
          print('Persistence failed: $e');
        }
      }

      _initialized = true;
      print('Firebase services initialized successfully');
    } catch (e) {
      print('Error initializing Firebase services: $e');
      // Don't rethrow on desktop platforms
      if (!_isDesktop()) {
        rethrow;
      }
    }
  }

  // Check if running on desktop platform
  static bool _isDesktop() {
    return defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  // Auth
  static FirebaseAuth get auth {
    _checkInitialization();
    return _auth!;
  }

  static User? get currentUser => auth.currentUser;

  // Firestore
  static FirebaseFirestore get firestore {
    _checkInitialization();
    return _firestore!;
  }

  // Collections
  static CollectionReference get doctorsCollection => firestore.collection('doctors');
  static CollectionReference get appointmentsCollection => firestore.collection('appointments');
  static CollectionReference get reviewsCollection => firestore.collection('reviews');
  static CollectionReference get specialtiesCollection => firestore.collection('specialties');
  static CollectionReference get usersCollection => firestore.collection('users');

  // Storage
  static FirebaseStorage get storage {
    _checkInitialization();
    return _storage!;
  }

  static void _checkInitialization() {
    if (!_initialized || _auth == null || _firestore == null || _storage == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
  }

  // Helper method to check if Firebase is ready
  static bool get isInitialized => _initialized;
}