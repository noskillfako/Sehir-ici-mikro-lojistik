import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import 'hive_database_service.dart';

/// Oturum ve Rol Yönetim Servisi
class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final HiveDatabaseService _db = HiveDatabaseService();

  ValueListenable<Box> listenSession() {
    return _db.sessionBox.listenable();
  }

  bool get isLoggedIn {
    return _db.sessionBox.get(AppConstants.keyIsLoggedIn, defaultValue: false) as bool;
  }

  String? getCurrentUserId() {
    return _db.sessionBox.get(AppConstants.keyCurrentUserId) as String?;
  }

  String getActiveRole() {
    return _db.sessionBox.get(AppConstants.keyActiveRole, defaultValue: AppConstants.roleCustomer) as String;
  }

  String? getActiveVehicleType() {
    return _db.sessionBox.get(AppConstants.keyActiveVehicleType) as String?;
  }

  Future<void> saveSession({
    required String userId,
    required String role,
    String? vehicleType,
  }) async {
    await _db.sessionBox.putAll({
      AppConstants.keyCurrentUserId: userId,
      AppConstants.keyActiveRole: role,
      AppConstants.keyIsLoggedIn: true,
      AppConstants.keyActiveVehicleType: vehicleType,
    });
  }

  Future<void> updateActiveRole(String role) async {
    await _db.sessionBox.put(AppConstants.keyActiveRole, role);
  }

  /// Müşteri <-> Kurye arasında anlık geçiş yapar
  Future<void> switchRole() async {
    final currentRole = getActiveRole();
    final newRole = currentRole == AppConstants.roleCustomer
        ? AppConstants.roleCourier
        : AppConstants.roleCustomer;
    await _db.sessionBox.put(AppConstants.keyActiveRole, newRole);
  }

  /// Çıkış yapma (siparişler ve kullanıcılar SİLİNMEZ, sadece oturum temizlenir)
  Future<void> clearSession() async {
    await _db.sessionBox.putAll({
      AppConstants.keyCurrentUserId: null,
      AppConstants.keyIsLoggedIn: false,
      AppConstants.keyActiveRole: AppConstants.roleCustomer,
      AppConstants.keyActiveVehicleType: null,
    });
  }
}
