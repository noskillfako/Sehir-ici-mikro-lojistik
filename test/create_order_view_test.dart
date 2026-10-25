import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehir_ici_mikro_lojistik/core/theme/app_theme.dart';
import 'package:sehir_ici_mikro_lojistik/views/customer/create_order_view.dart';

void main() {
  testWidgets('CreateOrderView 3 adımlı sayfalı akışla render edilmeli ve paket içerik kategorisi bulunmamalıdır', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: RouteDuckTheme.lightTheme,
        home: const CreateOrderView(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Üst İlerleme Çubuğu Adımları
    expect(find.text('1. Ürün & Adet'), findsOneWidget);
    expect(find.text('2. Araç & Doluluk'), findsOneWidget);
    expect(find.text('3. Adres & Onay'), findsOneWidget);

    // Kullanıcının isteği: Paket içerik kategorisi kaldırılmış olmalı
    expect(find.text('Paket İçerik Kategorisi'), findsNothing);

    // 1. Sayfa Elemanları: Kargo boyutu, Açıklama, Özel İhtiyaçlar ve Devam Butonu
    expect(find.text('1. Ürün Boyutu ve Gönderi Adedi'), findsOneWidget);
    expect(find.text('Paket İçeriği Açıklaması'), findsOneWidget);
    expect(find.text('Devam Et: Araç Seçimi'), findsOneWidget);

    // Açıklama alanına geçerli metin girelim
    final descField = find.widgetWithText(TextField, 'Paket İçeriği Açıklaması *');
    expect(descField, findsOneWidget);
    await tester.enterText(descField, 'Mühürlü şirket evrakları ve faturalar');
    await tester.pumpAndSettle();

    // 1. Adımdan 2. Adıma Geçelim
    await tester.tap(find.text('Devam Et: Araç Seçimi'));
    await tester.pumpAndSettle();

    // 2. Sayfa: Araç Kapasite ve Doluluk Durumu görünmeli
    expect(find.text('2. Araç Kapasite ve Doluluk Durumu'), findsOneWidget);
    expect(find.text('Devam Et: Adres & Harita'), findsOneWidget);
    expect(find.text('Geri'), findsOneWidget);

    // 2. Adımdan 3. Adıma Geçelim
    await tester.tap(find.text('Devam Et: Adres & Harita'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // 3. Sayfa: Alış ve Teslimat Noktaları, Fiyat Dökümü ve Onay Butonu görünmeli
    expect(find.text('3. Alış ve Teslimat Noktaları'), findsOneWidget);
    expect(find.text('Alış Noktası (Nereden Alınacak)'), findsOneWidget);
    expect(find.text('Teslimat Noktası (Nereye Gidecek)'), findsOneWidget);
    expect(find.text('Ödenecek Toplam Tutar:'), findsOneWidget);
    expect(find.text('Siparişi Onayla ve Kurye Çağır'), findsOneWidget);

    // Geri butonuna basarak 2. Sayfaya dönelim
    await tester.tap(find.text('Geri').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('2. Araç Kapasite ve Doluluk Durumu'), findsOneWidget);
  });
}
