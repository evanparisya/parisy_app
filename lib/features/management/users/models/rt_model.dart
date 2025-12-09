// lib/features/management/users/models/rt_model.dart
import 'package:parisy_app/features/management/users/models/warga_model.dart';

class RtModel extends WargaModel {
  RtModel({
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
          subRole: 'rt',
          createdAt: createdAt,
        );

  factory RtModel.fromWargaModel(WargaModel warga) {
    return RtModel(
      id: warga.id,
      name: warga.name,
      email: warga.email,
      phone: warga.phone,
      address: warga.address,
      createdAt: warga.createdAt,
    );
  }
}