import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehir_ici_mikro_lojistik/core/constants/app_constants.dart';
import 'package:sehir_ici_mikro_lojistik/core/theme/app_theme.dart';
import 'package:sehir_ici_mikro_lojistik/widgets/cargo_size_selector.dart';

void main() {
  testWidgets('Bir üründen 3 adet seçilip başka bir ürün eklendiğinde adetler bağımsız kalmalı', (tester) async {
    Map<String, int> quantities = {
      AppConstants.sizeDocument: 1,
    };

    await tester.pumpWidget(
      MaterialApp(
        theme: RouteDuckTheme.lightTheme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: CargoSizeSelector(
                  itemQuantities: quantities,
                  onQuantitiesChanged: (newQuantities) {
                    setState(() => quantities = newQuantities);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    // Başlangıçta Zarf: 1 Adet
    expect(find.text('1 Adet'), findsWidgets);
    expect(quantities[AppConstants.sizeDocument], 1);

    // Zarf için 2 kez '+' butonuna basarak 3 adet yapalım
    final addIcon = find.byIcon(Icons.add_rounded);
    await tester.tap(addIcon.first);
    await tester.pumpAndSettle();
    await tester.tap(addIcon.first);
    await tester.pumpAndSettle();

    expect(quantities[AppConstants.sizeDocument], 3);
    // Zarf kartında 3 Adet yazmalı
    expect(find.text('3 Adet'), findsWidgets);

    // Kullanıcının belirttiği sorun: "Farklı bir ürün eklemek istediğimde yine 3 adet olarak gösteriyor..."
    // Şimdi "Orta Koli" kartına tıklayıp sepete ekleyelim:
    await tester.tap(find.text('Orta Koli'));
    await tester.pumpAndSettle();

    // Orta Koli 1 adet olarak eklenmeli (Zarf'ın 3 adeti Orta Koli'ye kopyalanmamalı!)
    expect(quantities[AppConstants.sizeMedium], 1);
    expect(quantities[AppConstants.sizeDocument], 3);

    // Ekranda Zarf için 3 Adet, Orta Koli için 1 Adet açıkça görünmeli
    expect(find.text('3 Adet'), findsWidgets);
    expect(find.text('1 Adet'), findsWidgets);

    // Toplam özet: 4 Adet | 11.5 kg (0.5x3 + 10x1 = 11.5 kg) | 56 Litre (2x3 + 50x1 = 56 L)
    expect(find.textContaining('Toplam: 4 Adet | 11.5 kg | 56 Litre'), findsOneWidget);

    // Orta Koli adedini artıralım
    // Orta Koli'nin stepper'ındaki '+' butonu
    final ortaKoliAddBtn = find.byKey(const ValueKey('stepper_add_${AppConstants.sizeMedium}'));
    await tester.tap(ortaKoliAddBtn);
    await tester.pumpAndSettle();

    expect(quantities[AppConstants.sizeMedium], 2);
    expect(quantities[AppConstants.sizeDocument], 3);
    expect(find.text('2 Adet'), findsWidgets);
    expect(find.text('3 Adet'), findsWidgets);
    expect(find.textContaining('Toplam: 5 Adet | 21.5 kg | 106 Litre'), findsOneWidget);
  });

  testWidgets('Geriye dönük uyumluluk (Legacy Props): single selectedSize & itemCount ile de çalışmalı', (tester) async {
    String selectedSize = AppConstants.sizeDocument;
    int itemCount = 1;

    await tester.pumpWidget(
      MaterialApp(
        theme: RouteDuckTheme.lightTheme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: CargoSizeSelector(
                  selectedSize: selectedSize,
                  itemCount: itemCount,
                  onSizeSelected: (size) {
                    setState(() => selectedSize = size);
                  },
                  onItemCountChanged: (count) {
                    setState(() => itemCount = count);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('1. Ürün Boyutu ve Gönderi Adedi'), findsOneWidget);
    expect(find.text('Zarf / Evrak'), findsOneWidget);
    expect(find.textContaining('Toplam: 1 Adet | 0.5 kg | 2 Litre'), findsOneWidget);

    final addBtn = find.byIcon(Icons.add_rounded).first;
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    expect(itemCount, 2);
    expect(find.textContaining('Toplam: 2 Adet | 1 kg | 4 Litre'), findsOneWidget);
  });
}
