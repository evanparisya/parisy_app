// lib/core/utils/image_helper.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:parisy_app/core/constants/app_constants.dart';

/// Helper class untuk handling image dengan error handling
class ImageHelper {
  /// Validasi dan decode base64 image
  /// Mengembalikan image bytes atau null jika invalid
  static Uint8List? decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.trim().isEmpty) {
      return null;
    }

    try {
      return base64Decode(base64String.trim());
    } catch (e) {
      print('⚠️ Error decoding base64 image: $e');
      return null;
    }
  }

  /// Membuat widget Image.memory dengan error handling
  /// Jika image invalid, akan menampilkan placeholder
  static Widget buildImage({
    required String? base64Image,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    final imageBytes = decodeBase64Image(base64Image);

    if (imageBytes != null) {
      return Image.memory(
        imageBytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(width: width, height: height);
        },
      );
    }

    return _buildPlaceholder(width: width, height: height);
  }

  /// Build placeholder widget ketika image tidak tersedia
  static Widget _buildPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.neutralGray,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: height != null ? height * 0.3 : 48,
              color: AppColors.neutralDarkGray,
            ),
            SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(color: AppColors.neutralDarkGray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Build image dengan custom placeholder widget
  static Widget buildImageWithCustomPlaceholder({
    required String? base64Image,
    required Widget placeholder,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    final imageBytes = decodeBase64Image(base64Image);

    if (imageBytes != null) {
      return Image.memory(
        imageBytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }

    return placeholder;
  }

  /// Validasi apakah string adalah base64 image yang valid
  static bool isValidBase64Image(String? base64String) {
    return decodeBase64Image(base64String) != null;
  }

  /// Mendapatkan dummy image sebagai fallback
  static String getDummyImage() {
    return AppConstants.dummyImageBase64;
  }

  /// Normalize image string - mengembalikan valid base64 atau dummy
  static String normalizeImageString(String? imageString) {
    if (imageString == null || imageString.trim().isEmpty) {
      return AppConstants.dummyImageBase64;
    }

    // Validasi apakah base64 valid
    if (isValidBase64Image(imageString)) {
      return imageString.trim();
    }

    // Jika tidak valid, return dummy
    return AppConstants.dummyImageBase64;
  }
}
