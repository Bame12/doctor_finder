// Export GeoPoint for use in mock service
export 'package:doctor_finder_flutter/models/doctor_model.dart';

class DoctorModel {
  final String id;
  final String name;
  final String? photoUrl;
  final String? specialty;
  final String? email;
  final String phone;
  final String? address;
  final String? city;
  final GeoPoint? location;
  final bool acceptsInsurance;
  final double? rating;
  final int? reviewCount;
  final String? about;
  final String? openingHours;
  final String? languages;
  final int? experience;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DoctorModel({
    required this.id,
    required this.name,
    this.photoUrl,
    this.specialty,
    this.email,
    required this.phone,
    this.address,
    this.city,
    this.location,
    this.acceptsInsurance = false,
    this.rating,
    this.reviewCount,
    this.about,
    this.openingHours,
    this.languages,
    this.experience,
    this.createdAt,
    this.updatedAt,
  });

  factory DoctorModel.fromMap(String id, Map<String, dynamic> map) {
    return DoctorModel(
      id: id,
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      specialty: map['specialty'],
      email: map['email'],
      phone: map['phone'] ?? '',
      address: map['address'],
      city: map['city'],
      location: map['location'] is Map ?
      GeoPoint(
        latitude: map['location']['latitude']?.toDouble() ?? 0.0,
        longitude: map['location']['longitude']?.toDouble() ?? 0.0,
      ) : null,
      acceptsInsurance: map['acceptsInsurance'] ?? false,
      rating: map['rating']?.toDouble(),
      reviewCount: map['reviewCount']?.toInt(),
      about: map['about'],
      openingHours: map['openingHours'],
      languages: map['languages'],
      experience: map['experience']?.toInt(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] * 1000)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] * 1000)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'specialty': specialty,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'location': location != null ? {
        'latitude': location!.latitude,
        'longitude': location!.longitude,
      } : null,
      'acceptsInsurance': acceptsInsurance,
      'rating': rating,
      'reviewCount': reviewCount,
      'about': about,
      'openingHours': openingHours,
      'languages': languages,
      'experience': experience,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }
}

class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint({required this.latitude, required this.longitude});
}