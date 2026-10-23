# Git, GitHub ve .gitignore Yönetim Skill (gitignoreskill.md)

## 1. Amaç ve Kapsam
Bu modül; "Şehir İçi Mikro Lojistik" projesinde ekip çalışması (grup arkadaşı ile ortak GitHub kullanımı) sırasında derleme çıktılarının, cihaz bazlı yerel Hive veritabanı dosyalarının ve IDE ayarlarının GitHub'a yüklenmesini engeller, merge conflict (çakışma) riskini sıfıra indirir.

## 2. Kritik Kural: `agent/` ve `project.md` Dosyalarının Korunması
- Proje kök dizinindeki `project.md` ve `agent/skill/` klasörü altındaki tüm `.md` uzantılı mimari skill dosyaları **ASLA `.gitignore` içine eklenmemelidir.** Ekip arkadaşının da aynı Agent kurallarıyla çalışabilmesi için bu dosyalar GitHub reposunda tutulmalıdır.

## 3. GitHub'a Atılmaması Gereken Dosyalar (`.gitignore` Şablonu)
Agent'tan `.gitignore` dosyasını oluşturması veya güncellemesi istendiğinde kök dizindeki `.gitignore` dosyasına aşağıdaki kurallar eksiksiz yazılmalıdır:

```gitignore
# Flutter & Dart Derleme ve Paket Çıktıları
.dart_tool/
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies
pubspec.lock

# Hive Yerel Veritabanı Dosyaları (Cihaz/Test verileri repoya gitmemeli)
*.hive
*.lock
*.hive_lock
hive_data/

# Kod Üretimi (Kullanılırsa)
*.g.dart
*.freezed.dart

# Android & Gradle Çıktıları
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.java
**/android/key.properties
*.jks
*.keystore

# iOS & macOS Çıktıları
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/macos/**/Pods/
**/macos/**/Flutter/ephemeral/

# IDE ve Editör Ayarları (VS Code, Antigravity, Android Studio)
.idea/
.vscode/
*.iml
*.ipr
*.iws

# İşletim Sistemi ve Gizli Dosyalar
.DS_Store
Thumbs.db
.env
*.log