import 'package:flutter_test/flutter_test.dart';
import 'package:parisy_app/core/utils/category_helper.dart';

void main() {
  group('CategoryHelper Tests', () {
    test('normalizeCategory converts AI format to DB format', () {
      expect(CategoryHelper.normalizeCategory('Sayur Daun'), equals('daun'));
      expect(CategoryHelper.normalizeCategory('Sayur Akar'), equals('akar'));
      expect(CategoryHelper.normalizeCategory('Sayur Bunga'), equals('bunga'));
      expect(CategoryHelper.normalizeCategory('Sayur Buah'), equals('buah'));
    });

    test('normalizeCategory handles already normalized values', () {
      expect(CategoryHelper.normalizeCategory('daun'), equals('daun'));
      expect(CategoryHelper.normalizeCategory('akar'), equals('akar'));
      expect(CategoryHelper.normalizeCategory('bunga'), equals('bunga'));
      expect(CategoryHelper.normalizeCategory('buah'), equals('buah'));
    });

    test('normalizeCategory handles uppercase', () {
      expect(CategoryHelper.normalizeCategory('DAUN'), equals('daun'));
      expect(CategoryHelper.normalizeCategory('Akar'), equals('akar'));
    });

    test('normalizeCategory returns null for invalid categories', () {
      // Note: API Prediction tidak pernah return invalid category,
      // tapi kita tetap test untuk safety validation
      expect(CategoryHelper.normalizeCategory('Invalid'), isNull);
      expect(CategoryHelper.normalizeCategory('Sayur Invalid'), isNull);
      expect(CategoryHelper.normalizeCategory(''), isNull);
      expect(CategoryHelper.normalizeCategory(null), isNull);
    });

    test('toDisplayFormat converts DB format to display format', () {
      expect(CategoryHelper.toDisplayFormat('daun'), equals('Sayur Daun'));
      expect(CategoryHelper.toDisplayFormat('akar'), equals('Sayur Akar'));
      expect(CategoryHelper.toDisplayFormat('bunga'), equals('Sayur Bunga'));
      expect(CategoryHelper.toDisplayFormat('buah'), equals('Sayur Buah'));
    });

    test('isValid checks category validity', () {
      expect(CategoryHelper.isValid('daun'), isTrue);
      expect(CategoryHelper.isValid('akar'), isTrue);
      expect(CategoryHelper.isValid('bunga'), isTrue);
      expect(CategoryHelper.isValid('buah'), isTrue);
      expect(CategoryHelper.isValid('invalid'), isFalse);
      expect(CategoryHelper.isValid(null), isFalse);
    });

    test('getEmoji returns correct emoji for each category', () {
      expect(CategoryHelper.getEmoji('daun'), equals('🥬'));
      expect(CategoryHelper.getEmoji('akar'), equals('🥕'));
      expect(CategoryHelper.getEmoji('bunga'), equals('🥦'));
      expect(CategoryHelper.getEmoji('buah'), equals('🍅'));
      expect(CategoryHelper.getEmoji('unknown'), equals('🥗'));
    });

    test('getDisplayWithEmoji combines emoji and display name', () {
      expect(
        CategoryHelper.getDisplayWithEmoji('daun'),
        equals('🥬 Sayur Daun'),
      );
      expect(
        CategoryHelper.getDisplayWithEmoji('akar'),
        equals('🥕 Sayur Akar'),
      );
      expect(
        CategoryHelper.getDisplayWithEmoji('bunga'),
        equals('🥦 Sayur Bunga'),
      );
      expect(
        CategoryHelper.getDisplayWithEmoji('buah'),
        equals('🍅 Sayur Buah'),
      );
    });
  });
}
