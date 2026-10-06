import 'package:flutter/material.dart';

class LabelModel {
  final int id;
  final int userId;
  final String namaLabel;
  final String? kodeWarna; // nullable, warna bersifat opsional

  const LabelModel({
    required this.id,
    required this.userId,
    required this.namaLabel,
    this.kodeWarna,
  });

  static const defaultColor = Color(0xFFE3DDD0);

  Color get color => kodeWarna == null
      ? defaultColor
      : Color(int.parse(kodeWarna!.replaceFirst('#', '0xFF')));

  LabelModel copyWith({String? namaLabel, String? kodeWarna}) => LabelModel(
        id: id,
        userId: userId,
        namaLabel: namaLabel ?? this.namaLabel,
        kodeWarna: kodeWarna ?? this.kodeWarna,
      );

  factory LabelModel.fromJson(Map<String, dynamic> json) => LabelModel(
        id: json['id'],
        userId: json['user_id'],
        namaLabel: json['nama_label'],
        kodeWarna: json['kode_warna'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'nama_label': namaLabel,
        'kode_warna': kodeWarna,
      };
}