import 'package:doctor_finder_flutter/models/doctor_model.dart';
import 'package:doctor_finder_flutter/models/appointment_model.dart';
import 'package:doctor_finder_flutter/models/review_model.dart';
import 'package:doctor_finder_flutter/models/specialty_model.dart';

class MockFirebaseService {
  static bool _initialized = false;
  static final List<DoctorModel> _mockDoctors = [];
  static final List<SpecialtyModel> _mockSpecialties = [];
  static final List<ReviewModel> _mockReviews = [];
  static final List<AppointmentModel> _mockAppointments = [];

  static Future<void> initialize() async {
    if (_initialized) return;

    print('Initializing Mock Firebase Service for Linux...');

    // Create mock data
    _generateMockData();

    _initialized = true;
    print('Mock Firebase Service initialized');
  }

  static void _generateMockData() {
    // Mock specialties
    _mockSpecialties.addAll([
      SpecialtyModel(id: '1', name: 'General Practitioner'),
      SpecialtyModel(id: '2', name: 'Pediatrician'),
      SpecialtyModel(id: '3', name: 'Cardiologist'),
      SpecialtyModel(id: '4', name: 'Dermatologist'),
      SpecialtyModel(id: '5', name: 'Neurologist'),
    ]);

    // Mock doctors
    _mockDoctors.addAll([
      DoctorModel(
        id: '1',
        name: 'Dr. John Smith',
        specialty: 'General Practitioner',
        phone: '+267 72 000 001',
        address: '123 Main Street',
        city: 'Gaborone',
        acceptsInsurance: true,
        rating: 4.5,
        reviewCount: 24,
        experience: 10,
        languages: 'English, Setswana',
        openingHours: 'Mon-Fri: 8:00 AM - 5:00 PM',
        location: GeoPoint(latitude: -24.6282, longitude: 25.9231),
      ),
      DoctorModel(
        id: '2',
        name: 'Dr. Sarah Johnson',
        specialty: 'Pediatrician',
        phone: '+267 72 000 002',
        address: '456 Hospital Road',
        city: 'Gaborone',
        acceptsInsurance: true,
        rating: 4.8,
        reviewCount: 42,
        experience: 15,
        languages: 'English, Setswana',
        openingHours: 'Mon-Sat: 9:00 AM - 6:00 PM',
        location: GeoPoint(latitude: -24.6555, longitude: 25.9064),
      ),
    ]);
  }

  // Mock Firestore methods
  static Stream<List<DoctorModel>> getDoctorsStream() {
    return Stream.fromIterable([_mockDoctors]);
  }

  static Future<DoctorModel?> getDoctor(String doctorId) async {
    return _mockDoctors.firstWhere((doc) => doc.id == doctorId);
  }

  static Stream<List<SpecialtyModel>> getSpecialtiesStream() {
    return Stream.fromIterable([_mockSpecialties]);
  }

  static Stream<List<AppointmentModel>> getUserAppointmentsStream(String userId) {
    return Stream.fromIterable([_mockAppointments]);
  }

  static Future<String> addAppointment(AppointmentModel appointment) async {
    final newAppointment = AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      doctorId: appointment.doctorId,
      doctorName: appointment.doctorName,
      doctorSpecialty: appointment.doctorSpecialty,
      patientId: appointment.patientId,
      patientName: appointment.patientName,
      appointmentDateTime: appointment.appointmentDateTime,
      reason: appointment.reason,
      notes: appointment.notes,
      status: appointment.status,
      useInsurance: appointment.useInsurance,
      insuranceProvider: appointment.insuranceProvider,
      insuranceNumber: appointment.insuranceNumber,
      createdAt: DateTime.now(),
    );
    _mockAppointments.add(newAppointment);
    return newAppointment.id;
  }
}