// lib/features/management/users/models/rw_model.dart
import 'package:parisy_app/features/management/users/models/warga_model.dart';

class RwModel extends WargaModel {
  RwModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    required super.createdAt,
  }) : super(
          subRole: 'rw',
        );

  factory RwModel.fromWargaModel(WargaModel warga) {
    return RwModel(
      id: warga.id,
      name: warga.name,
      email: warga.email,
      phone: warga.phone,
      address: warga.address,
      createdAt: warga.createdAt,
    );
  }
}