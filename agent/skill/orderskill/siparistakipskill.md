# Sipariş Takip ve Canlı İzleme Skill (siparistakipskill.md)

## 1. Amaç ve Kapsam
Bu modül; müşteri ve kuryenin aktif siparişlerini anlık olarak takip etmesini (`ValueListenableBuilder` ile Hive kutusunu dinleyerek), aşama çubuğunu (Stepper) ve geçmiş siparişlerin listelenmesini yönetir.

## 2. Müşteri Takip Ekranı Kuralları
1. **Canlı Durum Adımları (Stepper UI):**
   - Adım 1: Kurye Aranıyor (`WAITING_FOR_COURIER`)
   - Adım 2: Kurye Yola Çıktı (`COURIER_ASSIGNED` - Kuryenin adı ve araç tipi gösterilir)
   - Adım 3: Paket Dağıtımda (`IN_TRANSIT`)
   - Adım 4: Teslim Edildi (`DELIVERED`)
2. **Teslimat Kodu Gösterimi:** Sipariş `COURIER_ASSIGNED` veya `IN_TRANSIT` durumundayken, müşteri ekranında büyük puntolarla **"Kuryeye Söyleyeceğiniz Teslimat Kodu: [4829]"** kutusu gösterilir.

## 3. Kurye Aktif Görev Ekranı Kuralları
- Kurye bir siparişi kabul ettiğinde, havuz ekranı yerine **"Aktif Görevim"** kartı öne çıkar.
- Bu ekranda müşterinin yazdığı `customDescription` (Paket içeriği), açık adresler, harita rotası ve sıradaki durum butonu ("Paketi Teslim Aldım" veya "OTP Girerek Teslim Et") yer alır.

## 4. Beklenen Servis Metotları (`OrderTrackingService`)
- `ValueListenable<Box> listenToOrdersBox()` // Arayüzün anlık güncellenmesi için
- `List<OrderModel> getCustomerActiveOrders(String customerId)`
- `List<OrderModel> getCustomerPastOrders(String customerId)`
- `OrderModel? getCourierCurrentTask(String courierId)`
- `List<OrderModel> getCourierCompletedOrders(String courierId)`