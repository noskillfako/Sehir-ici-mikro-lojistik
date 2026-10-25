import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import 'auth_service.dart';

/// Hive Yerel Veritabanı ve Kutu Yönetim Servisi
class HiveDatabaseService {
  static final HiveDatabaseService _instance = HiveDatabaseService._internal();
  factory HiveDatabaseService() => _instance;
  HiveDatabaseService._internal();

  Box? _usersBox;
  Box? _sessionBox;
  Box? _ordersBox;

  Box get usersBox {
    if (_usersBox == null || !_usersBox!.isOpen) {
      throw AppException.boxNotOpen(AppConstants.usersBox);
    }
    return _usersBox!;
  }

  Box get sessionBox {
    if (_sessionBox == null || !_sessionBox!.isOpen) {
      throw AppException.boxNotOpen(AppConstants.sessionBox);
    }
    return _sessionBox!;
  }

  Box get ordersBox {
    if (_ordersBox == null || !_ordersBox!.isOpen) {
      throw AppException.boxNotOpen(AppConstants.ordersBox);
    }
    return _ordersBox!;
  }

  /// Hive'ı ve 3 ana kutuyu başlatır
  Future<void> initDatabase() async {
    await Hive.initFlutter();

    _usersBox = await Hive.openBox(AppConstants.usersBox);
    _sessionBox = await Hive.openBox(AppConstants.sessionBox);
    _ordersBox = await Hive.openBox(AppConstants.ordersBox);

    // İlk kurulumda varsayılan test kullanıcılarını yükle
    await AuthService().seedDefaultUsersIfNeeded();
  }

  /// Sipariş kutusunu reaktif dinleme için ValueListenable döndürür
  ValueListenable<Box> listenOrdersBox() {
    return ordersBox.listenable();
  }

  /// Sadece sipariş geçmişini temizler (kullanıcılar ve oturum kalır)
  Future<void> clearAllOrders() async {
    await ordersBox.clear();
  }

  /// Tüm veritabanını fabrika ayarlarına sıfırlar ve test hesaplarını yeniden yükler
  Future<void> fullResetAndSeed() async {
    await ordersBox.clear();
    await usersBox.clear();
    await sessionBox.clear();

    await AuthService().seedDefaultUsersIfNeeded();
  }
}
