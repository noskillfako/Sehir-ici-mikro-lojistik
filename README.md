# sehir_ici_mikro_lojistik

# 🚚 Şehir İçi Mikro Lojistik

Şehir içi küçük ölçekli teslimatları (paket, evrak, market vb.) gönderici, kurye ve alıcı arasında hızlı ve takip edilebilir şekilde yönetmeyi amaçlayan mobil uygulama.


---

## 📌 Proje Hakkında

Şehir içi mikro lojistik; kısa mesafeli, küçük hacimli teslimatların verimli biçimde organize edilmesini hedefler. Bu uygulama ile:

- Gönderiler kolayca oluşturulur,
- Uygun kuryelere atanır,
- Teslimat süreci uçtan uca takip edilir.

## 🛠️ Kullanılan Teknolojiler

| Katman | Teknoloji |
|---|---|
| Mobil | Flutter (Dart) |
| Veritabanı | Cloud Firestore |
| Kimlik Doğrulama | Firebase Auth |
| Sunucu Mantığı | Firebase Cloud Functions |
| Durum Yönetimi | [Provider / Riverpod / Bloc] |

## 📂 Proje Yapısı

```
lib/
├── core/          # Sabitler, tema, yardımcı sınıflar
├── models/        # Veri modelleri
├── services/      # Firebase ve konum servisleri
├── providers/     # Durum yönetimi
├── screens/       # Ekranlar
├── widgets/       # Ortak bileşenler
└── main.dart
functions/         # Firebase Cloud Functions
```

## 🚀 Kurulum

### Gereksinimler

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x veya üzeri)
- Dart SDK
- Firebase hesabı ve bir Firebase projesi
- Android Studio veya VS Code

### Adımlar

```bash
# 1. Repoyu klonla
git clone https://github.com/noskillfako/Sehir-ici-mikro-lojistik.git
cd Sehir-ici-mikro-lojistik

# 2. Bağımlılıkları yükle
flutter pub get

# 3. Firebase yapılandırmasını oluştur
dart pub global activate flutterfire_cli
flutterfire configure

# 4. Uygulamayı çalıştır
flutter run
```

### Firebase Kurulumu

1. [Firebase Console](https://console.firebase.google.com/)'da yeni bir proje oluştur.
2. **Authentication** bölümünden E-posta/Şifre girişini etkinleştir.
3. **Firestore Database**'i oluştur.
4. Android için `google-services.json` dosyasını `android/app/` altına, iOS için `GoogleService-Info.plist` dosyasını `ios/Runner/` altına ekle.
5. Cloud Functions kullanıyorsan:

```bash
cd functions
npm install
firebase deploy --only functions
```
