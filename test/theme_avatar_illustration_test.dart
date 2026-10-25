import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehir_ici_mikro_lojistik/core/constants/app_constants.dart';
import 'package:sehir_ici_mikro_lojistik/models/user_model.dart';
import 'package:sehir_ici_mikro_lojistik/widgets/theme_avatar_illustration.dart';

void main() {
  group('ThemeAvatarIllustration Testleri', () {
    testWidgets('Müşteri illüstrasyonu sorunsuz çizilmeli', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeAvatarIllustration.customer(size: 60),
          ),
        ),
      );

      expect(find.byType(ThemeAvatarIllustration), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Kurye araç sınıfları (Motosiklet, Otomobil, Panelvan, Tır vb.) sorunsuz çizilmeli', (tester) async {
      for (final v in AppConstants.courierVehicles) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ThemeAvatarIllustration.forVehicle(v, size: 50),
            ),
          ),
        );

        expect(find.byType(ThemeAvatarIllustration), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      }
    });

    testWidgets('UserModel ile oluşturulduğunda doğru çizim tetiklenmeli', (tester) async {
      const courier = UserModel(
        id: 'courier_1',
        fullName: 'Mehmet Demir',
        phone: '05551112233',
        password: '123',
        role: AppConstants.roleCourier,
        vehicleType: AppConstants.vehicleMotorcycle,
        hasThermalBag: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeAvatarIllustration.fromUser(courier, size: 48),
          ),
        ),
      );

      expect(find.byType(ThemeAvatarIllustration), findsOneWidget);
    });
  });
}
