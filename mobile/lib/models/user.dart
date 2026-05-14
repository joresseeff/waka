class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String country;
  final String city;
  final String role;
  final double rating;
  final int totalMissions;
  final bool isCertified;
  final bool isOnline;
  final String? vehicleType;
  final String? vehicleBrand;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? vehiclePlate;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.country,
    required this.city,
    required this.role,
    required this.rating,
    required this.totalMissions,
    required this.isCertified,
    required this.isOnline,
    this.vehicleType,
    this.vehicleBrand,
    this.vehicleModel,
    this.vehicleColor,
    this.vehiclePlate,
  });

  String get fullName => '$firstName $lastName';
  bool get isDriver => role == 'driver';
  bool get isClient => role == 'client';

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    firstName: json['first_name'],
    lastName: json['last_name'],
    email: json['email'],
    phone: json['phone'],
    country: json['country'] ?? 'Gabon',
    city: json['city'] ?? 'Libreville',
    role: json['role'],
    rating: (json['rating'] ?? 0.0).toDouble(),
    totalMissions: json['total_missions'] ?? 0,
    isCertified: json['is_certified'] ?? false,
    isOnline: json['is_online'] ?? false,
    vehicleType: json['vehicle_type'],
    vehicleBrand: json['vehicle_brand'],
    vehicleModel: json['vehicle_model'],
    vehicleColor: json['vehicle_color'],
    vehiclePlate: json['vehicle_plate'],
  );
}
