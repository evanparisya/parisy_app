// lib/core/utils/category_helper.dart

/// Helper class untuk mapping kategori sayur
/// Database: 'daun', 'akar', 'bunga', 'buah'
/// AI Prediction: 'Sayur Daun', 'Sayur Akar', 'Sayur Bunga', 'Sayur Buah'
class CategoryHelper {
  // Kategori dalam format database (enum)
  static const String daun = 'daun';
  static const String akar = 'akar';
  static const String bunga = 'bunga';
  static const String buah = 'buah';

  // List kategori untuk dropdown (format database)
  static const List<String> categories = [daun, akar, bunga, buah];

  // Mapping dari AI prediction format ke database format
  static const Map<String, String> aiToDbMap = {
    'Sayur Daun': daun,
    'Sayur Akar': akar,
    'Sayur Bunga': bunga,
    'Sayur Buah': buah,
    // Fallback jika API mengembalikan format lain
    'daun': daun,
    'akar': akar,
    'bunga': bunga,
    'buah': buah,
  };

  // Mapping dari database format ke display format
  static const Map<String, String> dbToDisplayMap = {
    daun: 'Sayur Daun',
    akar: 'Sayur Akar',
    bunga: 'Sayur Bunga',
    buah: 'Sayur Buah',
  };

  /// Konversi dari format AI prediction ke format database
  /// 'Sayur Daun' -> 'daun'
  /// 'daun' -> 'daun'
  static String? normalizeCategory(String? category) {
    if (category == null || category.isEmpty) return null;

    // Coba mapping langsung
    if (aiToDbMap.containsKey(category)) {
      return aiToDbMap[category];
    }

    // Coba lowercase
    final lowerCategory = category.toLowerCase();
    if (categories.contains(lowerCategory)) {
      return lowerCategory;
    }

    // Coba hapus prefix "Sayur " dan lowercase
    if (category.startsWith('Sayur ')) {
      final withoutPrefix = category.substring(6).toLowerCase();
      if (categories.contains(withoutPrefix)) {
        return withoutPrefix;
      }
    }

    return null;
  }

  /// Konversi dari format database ke format display
  /// 'daun' -> 'Sayur Daun'
  static String toDisplayFormat(String dbCategory) {
    return dbToDisplayMap[dbCategory.toLowerCase()] ?? dbCategory;
  }

  /// Cek apakah kategori valid (dalam format database)
  static bool isValid(String? category) {
    if (category == null) return false;
    return categories.contains(category.toLowerCase());
  }

  /// Get emoji untuk kategori
  static String getEmoji(String category) {
    switch (category.toLowerCase()) {
      case daun:
        return '🥬';
      case akar:
        return '🥕';
      case bunga:
        return '🥦';
      case buah:
        return '🍅';
      default:
        return '🥗';
    }
  }

  /// Get display name dengan emoji
  static String getDisplayWithEmoji(String category) {
    final display = toDisplayFormat(category);
    final emoji = getEmoji(category);
    return '$emoji $display';
  }
}
