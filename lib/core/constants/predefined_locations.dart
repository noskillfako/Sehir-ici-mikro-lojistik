import '../../models/location_preset_model.dart';

/// Harita ve sipariş oluşturma için sabit ilçe ve nokta koordinatları
class PredefinedLocations {
  static const List<LocationPresetModel> list = [
    LocationPresetModel(
      id: 'loc_kadikoy',
      name: 'Kadıköy (Boğa Heykeli)',
      district: 'Kadıköy',
      lat: 40.9904,
      lng: 29.0292,
      description: 'Söğütlüçeşme Cd. & Altıyol Kavşağı',
    ),
    LocationPresetModel(
      id: 'loc_besiktas',
      name: 'Beşiktaş (Meydan / İskele)',
      district: 'Beşiktaş',
      lat: 41.0422,
      lng: 29.0067,
      description: 'Barbaros Bulvarı & Vapur İskelesi Önü',
    ),
    LocationPresetModel(
      id: 'loc_sisli',
      name: 'Şişli (Cevahir AVM Önü)',
      district: 'Şişli',
      lat: 41.0621,
      lng: 28.9926,
      description: 'Büyükdere Cad. Mecidiyeköy Çıkışı',
    ),
    LocationPresetModel(
      id: 'loc_uskudar',
      name: 'Üsküdar (Marmaray Çıkışı)',
      district: 'Üsküdar',
      lat: 41.0264,
      lng: 29.0151,
      description: 'Marmaray & Sahil Meydanı',
    ),
    LocationPresetModel(
      id: 'loc_levent',
      name: 'Levent (Plazalar / Büyükdere)',
      district: 'Levent',
      lat: 41.0772,
      lng: 29.0108,
      description: 'Kanyon / MetroCity Hattı',
    ),
    LocationPresetModel(
      id: 'loc_atasehir',
      name: 'Ataşehir (Finans Merkezi / Bulvar)',
      district: 'Ataşehir',
      lat: 40.9932,
      lng: 29.1130,
      description: 'Barbaros Mah. Finans Caddesi',
    ),
    LocationPresetModel(
      id: 'loc_bakirkoy',
      name: 'Bakırköy (Özgürlük Meydanı)',
      district: 'Bakırköy',
      lat: 40.9801,
      lng: 28.8722,
      description: 'İncirli Caddesi & Meydan',
    ),
    LocationPresetModel(
      id: 'loc_taksim',
      name: 'Taksim (AKM Önü)',
      district: 'Beyoğlu',
      lat: 41.0369,
      lng: 28.9850,
      description: 'Taksim Meydanı & Gezi Parkı Girişi',
    ),
  ];

  static LocationPresetModel get kadikoy => list[0];
  static LocationPresetModel get besiktas => list[1];
}
