import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:doctor_finder_flutter/models/doctor_model.dart';
import 'package:doctor_finder_flutter/models/appointment_model.dart';
import 'package:doctor_finder_flutter/models/review_model.dart';
import 'package:doctor_finder_flutter/models/specialty_model.dart';
import 'package:doctor_finder_flutter/services/firebase_service.dart';
import 'package:doctor_finder_flutter/services/mock_firebase_service.dart';

class FirestoreService {
  // Doctor operations
  static Stream<List<DoctorModel>> getDoctorsStream() {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      return MockFirebaseService.getDoctorsStream();
    }

    return FirebaseService.doctorsCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => DoctorModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList()
    );
  }

  static Future<DoctorModel?> getDoctor(String doctorId) async {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      return MockFirebaseService.getDoctor(doctorId);
    }

    try {
      final doc = await FirebaseService.doctorsCollection.doc(doctorId).get();
      if (doc.exists) {
        return DoctorModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting doctor: $e');
      return null;
    }
  }

  static Future<void> updateDoctorRating(String doctorId, double averageRating, int reviewCount) async {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      // Mock implementation - just print
      print('Mock: Updated doctor $doctorId rating to $averageRating');
      return;
    }

    try {
      await FirebaseService.doctorsCollection.doc(doctorId).update({
        'rating': averageRating,
        'reviewCount': reviewCount,
      });
    } catch (e) {
      print('Error updating doctor rating: $e');
      rethrow;
    }
  }

  // Appointment operations
  static Future<String> addAppointment(AppointmentModel appointment) async {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      return MockFirebaseService.addAppointment(appointment);
    }

    try {
      final docRef = await FirebaseService.appointmentsCollection.add(appointment.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding appointment: $e');
      rethrow;
    }
  }

  static Stream<List<AppointmentModel>> getUserAppointmentsStream(String userId) {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      return MockFirebaseService.getUserAppointmentsStream(userId);
    }

    return FirebaseService.appointmentsCollection
        .where('patientId', isEqualTo: userId)
        .orderBy('appointmentDateTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList()
    );
  }

  static Stream<List<AppointmentModel>> getDoctorAppointmentsStream(String doctorId) {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      return MockFirebaseService.getUserAppointmentsStream(doctorId); // Reuse for mock
    }

    return FirebaseService.appointmentsCollection
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('appointmentDateTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList()
    );
  }

  static Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      print('Mock: Updated appointment $appointmentId status to $status');
      return;
    }

    try {
      await FirebaseService.appointmentsCollection.doc(appointmentId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating appointment status: $e');
      rethrow;
    }
  }

  // Review operations
  static Future<String> addReview(ReviewModel review) async {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      // Mock implementation
      print('Mock: Added review for doctor ${review.doctorId}');
      return 'mock-review-id';
    }

    try {
      final docRef = await FirebaseService.reviewsCollection.add(review.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }

  static Stream<List<ReviewModel>> getDoctorReviewsStream(String doctorId) {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      // Mock empty reviews for now
      return Stream.fromIterable([<ReviewModel>[]]);
    }

    return FirebaseService.reviewsCollection
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => ReviewModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList()
    );
  }

  // Specialty operations
  static Stream<List<SpecialtyModel>> getSpecialtiesStream() {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      return MockFirebaseService.getSpecialtiesStream();
    }

    return FirebaseService.specialtiesCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => SpecialtyModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList()
    );
  }

  static Future<SpecialtyModel?> getSpecialty(String specialtyId) async {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      // Mock implementation
      return SpecialtyModel(id: specialtyId, name: 'Mock Specialty');
    }

    try {
      final doc = await FirebaseService.specialtiesCollection.doc(specialtyId).get();
      if (doc.exists) {
        return SpecialtyModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting specialty: $e');
      return null;
    }
  }

  // Search doctors
  static Stream<List<DoctorModel>> searchDoctors({String? city, String? name}) {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      return MockFirebaseService.getDoctorsStream().map((doctors) {
        var result = doctors;
        if (city != null) {
          result = result.where((doc) => doc.city?.toLowerCase() == city.toLowerCase()).toList();
        }
        if (name != null) {
          result = result.where((doc) => doc.name.toLowerCase().contains(name.toLowerCase())).toList();
        }
        return result;
      });
    }

    Query query = FirebaseService.doctorsCollection;

    if (city != null) {
      query = query.where('city', isEqualTo: city);
    }

    return query.snapshots().map((snapshot) {
      var doctors = snapshot.docs.map((doc) => DoctorModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();

      if (name != null) {
        doctors = doctors.where((doctor) =>
            doctor.name.toLowerCase().contains(name.toLowerCase())
        ).toList();
      }

      return doctors;
    });
  }
}