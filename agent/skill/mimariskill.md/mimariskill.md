# Proje Mimarisi ve Ortak Geliştirme Standartları (mimariskill.md)

## 1. Amaç ve Çalışma Modeli
Bu modül; "Şehir İçi Mikro Lojistik" uygulamasının `lib/` klasör yapısını, katmanlar arası iletişim kurallarını ve ekip içi ortak kod geliştirme standartlarını belirler. 
- **Kolektif Kod Sahipliği:** Ekip üyelerinin tamamı günün farklı saatlerinde hem iş mantığı (`services/`, `models/`) hem de arayüz (`views/`, `widgets/`) kodlarını inceleyebilir ve güncelleyebilir.
- **UI Tasarım Özerkliği:** Görsel tasarım kararları, renk paleti, tipografi ve bileşen stilleri bu dosyada değil, ekip arkadaşı tarafından hazırlanacak olan `uitasarimskill.md` dosyasında tanımlanır.

## 2. Zorunlu `lib/` Klasör Ağacı (Directory Structure)
Agent yeni bir dosya oluştururken veya mevcut dosyaları güncellerken yalnızca aşağıdaki dizin yapısını kullanmalıdır:

```text
lib/
├── main.dart                                # Uygulama başlangıcı, Hive init ve yönlendirme
├── core/                                    # Çekirdek altyapı, sabitler ve hata yönetimi
│   ├── constants/
│   │   ├── app_constants.dart               # Sabit fiyatlar, kutu adları, kargo katalogları
│   │   └── predefined_locations.dart        # Sabit ilçe/nokta koordinatları
│   ├── errors/
│   │   ├── app_exception.dart               # Özel hata sınıfı (errorskill.md)
│   │   └── error_handler.dart               # Merkezi hata ve bildirim gösterici
│   └── theme/
│       └── app_theme.dart                   # uitasarimskill.md kurallarına göre oluşturulacak tema
├── models/                                  # Veri Modelleri (toMap / fromMap içeren sınıflar)
│   ├── user_model.dart
│   ├── order_model.dart
│   └── location_preset_model.dart
├── services/                                # İş Mantığı ve Hive Servisleri
│   ├── hive_database_service.dart           # hivedbskill.md
│   ├── auth_service.dart                    # authskill.md
│   ├── session_service.dart                 # sessionskill.md
│   ├── map_service.dart                     # haritaskill.md
│   ├── pricing_service.dart                 # fiyatlandirmaskill.md
│   ├── order_creation_service.dart          # siparisolusturmaskill.md
│   ├── courier_matching_service.dart        # kuryeeslesmeskill.md
│   ├── order_status_service.dart            # siparisdurumskill.md
│   ├── delivery_confirmation_service.dart   # teslimatonayskill.md
│   └── order_tracking_service.dart          # siparistakipskill.md
├── views/                                   # Uygulama Ekranları (Sayfalar)
│   ├── auth/
│   │   ├── login_view.dart
│   │   └── register_view.dart
│   ├── customer/
│   │   ├── customer_home_view.dart
│   │   ├── create_order_view.dart
│   │   └── customer_order_detail_view.dart
│   └── courier/
│       ├── courier_pool_view.dart
│       └── courier_active_task_view.dart
└── widgets/                                 # Tekrar kullanılabilir ortak UI bileşenleri
    ├── role_switcher_button.dart            # Müşteri <-> Kurye hızlı geçiş butonu
    ├── order_card_widget.dart
    ├── cargo_size_selector.dart
    └── otp_verification_dialog.dart