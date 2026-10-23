# Sipariş Durum Yönetimi ve Kurye Eşleşme Skill (siparisdurumskill.md)

## 1. Amaç ve Kapsam
Bu modül; `ordersBox` içindeki mevcut siparişlerin kurye araç tipine göre filtrelenmesini, kuryenin siparişi kabul etmesini, durum geçişlerini (State Machine) ve teslimat anında 4 haneli OTP kodunun doğrulanmasını yönetir.

## 3. İzin Verilen Durum Geçişleri (State Machine)
Sipariş durumları sırasıyla yalnızca aşağıdaki yönde ilerleyebilir:
1. `WAITING_FOR_COURIER` -> `COURIER_ASSIGNED`: Kurye siparişi kabul ettiğinde (`courierId` ve `courierName` siparişe yazılır).
2. `COURIER_ASSIGNED` -> `IN_TRANSIT`: Kurye müşteriden paketi teslim aldığında ("Paketi Aldım" butonu).
3. `IN_TRANSIT` -> `DELIVERED`: Kurye alıcıya ulaşıp 4 haneli `deliveryOtpCode` kodunu doğru girdiğinde.
4. `WAITING_FOR_COURIER` -> `CANCELLED`: Müşteri henüz kurye atanmadan siparişi iptal ettiğinde.

## 4. Kısıtlamalar ve Güvenlik Kuralları
- **Tek Aktif Sipariş Kuralı:** Bir kuryenin üzerinde `COURIER_ASSIGNED` veya `IN_TRANSIT` durumunda aktif bir sipariş varsa, onu tamamlamadan havuzdan ikinci bir sipariş alamaz.
- **OTP Doğrulama Kuralı:** `completeDelivery()` metodu çağrıldığında kuryenin girdiği 4 haneli kod ile siparişin `deliveryOtpCode` alanı eşleşmiyorsa durum güncellenmez ve hata döner.

## 5. Beklenen Servis Metotları (`OrderStatusService`)
- `List<OrderModel> getAvailablePoolForCourier({required String vehicleType, required bool hasThermalBag})`
- `Future<void> assignCourierToOrder({required String orderId, required String courierId, required String courierName})`
- `Future<void> markAsPickedUp(String orderId)`
- `Future<bool> verifyOtpAndDeliver({required String orderId, required String enteredOtp})`
- `Future<void> cancelOrder(String orderId)`