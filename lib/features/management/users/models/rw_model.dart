// lib/features/management/users/models/rw_model.dart
import 'package:parisy_app/features/management/users/models/warga_model.dart';

class RwModel extends WargaModel {
  RwModel({
    required int id,
    required String name,
    required String email,
    required String phone,
    required String address,
    required DateTime createdAt,
  }) : super(
          id: id,
          name: name,
          email: email,
          phone: phone,
          address: address,
          subRole: 'rw',
          createdAt: createdAt,
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