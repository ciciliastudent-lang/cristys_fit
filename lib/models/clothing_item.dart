import 'dart:typed_data';
import 'package:flutter/material.dart';

class ClothingItem {
  final String name;
  final Color color; // used when there is no uploaded image
  final Uint8List? png; // uploaded image, already converted to PNG
  final double scale; // size adjustment (1.0 = fits the body zone)
  final double dx; // move left/right
  final double dy; // move up/down

  const ClothingItem(
    this.name,
    this.color, {
    this.png,
    this.scale = 1,
    this.dx = 0,
    this.dy = 0,
  });
}
