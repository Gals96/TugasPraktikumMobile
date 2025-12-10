import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatRupiah(num number) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(number);
}

Widget carImageWidget(String? img, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (img == null || img.isEmpty) {
    return SizedBox(width: width, height: height, child: const Icon(Icons.car_rental, size: 40));
  }
  final f = File(img);
  if (f.existsSync()) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        f,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      img,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => const Icon(Icons.car_rental, size: 40),
    ),
  );
}