import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/user_model.dart';
import 'hive_database_service.dart';
import 'session_service.dart';

/// Kimlik Doğrulama ve Kullanıcı Yönetim Servisi
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final HiveDatabaseService _db = HiveDatabaseService();
  final SessionService _session = SessionService();

  /// Uygulama ilk açıldığında test kolaylığı için varsayılan kullanıcıları yükler
  Future<void> seedDefaultUsersIfNeeded() async {
    if (_db.usersBox.isEmpty) {
      final defaultUsers = [
        const UserModel(
          id: 'usr_customer_1',
          fullName: 'Ahmet Yılmaz',
          phone: '5551112233',
          password: '1234',
          role: AppConstants.roleCustomer,
        ),
        const UserModel(
          id: 'usr_courier_1',
          fullName: 'Mehmet Demir',
          phone: '5554445566',
          password: '1234',
          role: AppConstants.roleCourier,
          vehicleType: AppConstants.vehicleMotorcycle,
          plateNumber: '34 MTO 01',
          hasThermalBag: true,
        ),
        const UserModel(
          id: 'usr_courier_2',
          fullName: 'Caner Kaya',
          phone: '5557778899',
          password: '1234',
          role: AppConstants.roleCourier,
          vehicleType: AppConstants.vehicleCar,
          plateNumber: '34 AR 99',
          hasThermalBag: false,
        ),
        const UserModel(
          id: 'usr_courier_3',
          fullName: 'Serkan Yıldız',
          phone: '5552223344',
          password: '1234',
          role: AppConstants.roleCourier,
          vehicleType: AppConstants.vehiclePanelvan,
          plateNumber: '34 PNL 45',
          hasThermalBag: false,
        ),
        const UserModel(
          id: 'usr_courier_4',
          fullName: 'Burak Koç',
          phone: '5558889900',
          password: '1234',
          role: AppConstants.roleCourier,
          vehicleType: AppConstants.vehicleTruck,
          plateNumber: '34 TR 500',
          hasThermalBag: false,
        ),
      ];

      for (final user in defaultUsers) {
        await _db.usersBox.put(user.id, user.toMap());
      }
    }
  }

  /// Telefon ve şifre ile giriş yapma
  Future<UserModel> login(String phone, String password) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    UserModel? foundUser;

    for (var key in _db.usersBox.keys) {
      final raw = _db.usersBox.get(key);
      if (raw != null) {
        final map = Map<String, dynamic>.from(raw as Map);
        if (map['phone'] == cleanPhone) {
          foundUser = UserModel.fromMap(map);
          break;
        }
      }
    }

    if (foundUser == null) {
      throw AppException.userNotFound();
    }

    if (foundUser.password != password) {
      throw AppException.wrongPassword();
    }

    // Başarılı giriş -> Oturumu kaydet
    await _session.saveSession(
      userId: foundUser.id,
      role: foundUser.role,
      vehicleType: foundUser.vehicleType,
    );

    return foundUser;
  }

  /// Yeni kullanıcı kaydı
  Future<UserModel> register({
    required String fullName,
    required String phone,
    required String password,
    required String role,
    String? vehicleType,
    String? plateNumber,
    bool hasThermalBag = false,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');

    // Telefon no benzersiz olmalı
    for (var key in _db.usersBox.keys) {
      final raw = _db.usersBox.get(key);
      if (raw != null) {
        final map = Map<String, dynamic>.from(raw as Map);
        if (map['phone'] == cleanPhone) {
          throw AppException.phoneAlreadyExists();
        }
      }
    }

    // Kurye ise araç tipi zorunlu
    if (role == AppConstants.roleCourier && (vehicleType == null || vehicleType.isEmpty)) {
      throw AppException.missingVehicleInfo();
    }

    final newId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final newUser = UserModel(
      id: newId,
      fullName: fullName,
      phone: cleanPhone,
      password: password,
      role: role,
      vehicleType: role == AppConstants.roleCourier ? vehicleType : null,
      plateNumber: plateNumber,
      hasThermalBag: hasThermalBag,
    );

    await _db.usersBox.put(newUser.id, newUser.toMap());

    // Otomatik oturum açma
    await _session.saveSession(
      userId: newUser.id,
      role: newUser.role,
      vehicleType: newUser.vehicleType,
    );

    return newUser;
  }

  /// ID üzerinden kullanıcı sorgulama
  UserModel? getUserById(String userId) {
    final raw = _db.usersBox.get(userId);
    if (raw == null) return null;
    return UserModel.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  /// Aktif oturumdaki kullanıcı
  UserModel? getCurrentUser() {
    final uid = _session.getCurrentUserId();
    if (uid == null) return null;
    return getUserById(uid);
  }

  /// Hızlı test için hazır hesapları getirir
  List<UserModel> getSeedUsers() {
    final list = <UserModel>[];
    for (var key in _db.usersBox.keys) {
      final raw = _db.usersBox.get(key);
      if (raw != null) {
        list.add(UserModel.fromMap(Map<String, dynamic>.from(raw as Map)));
      }
    }
    return list;
  }
}
