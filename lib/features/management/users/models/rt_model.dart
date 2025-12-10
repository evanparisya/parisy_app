// lib/features/management/users/models/rt_model.dart
import 'package:parisy_app/features/management/users/models/warga_model.dart';

class RtModel extends WargaModel {
  RtModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    required super.createdAt,
  }) : super(
          subRole: 'rt',
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