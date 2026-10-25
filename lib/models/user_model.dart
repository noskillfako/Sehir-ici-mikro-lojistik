/// Kullanıcı Veri Modeli (Müşteri ve Kurye)
class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String password;
  final String role; // 'CUSTOMER' veya 'COURIER'
  final String? vehicleType; // 'BICYCLE', 'MOTORCYCLE', 'CAR', 'MINIVAN', 'PANELVAN', 'MAXIVAN'
  final String? plateNumber;
  final bool hasThermalBag;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.password,
    required this.role,
    this.vehicleType,
    this.plateNumber,
    this.hasThermalBag = false,
  });

  bool get isCourier => role == 'COURIER';
  bool get isCustomer => role == 'CUSTOMER';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'password': password,
      'role': role,
      'vehicleType': vehicleType,
      'plateNumber': plateNumber,
      'hasThermalBag': hasThermalBag,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      phone: map['phone'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      vehicleType: map['vehicleType'] as String?,
      plateNumber: map['plateNumber'] as String?,
      hasThermalBag: map['hasThermalBag'] as bool? ?? false,
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? password,
    String? role,
    String? vehicleType,
    String? plateNumber,
    bool? hasThermalBag,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role ?? this.role,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      hasThermalBag: hasThermalBag ?? this.hasThermalBag,
    );
  }
}
