import 'package:flutter/material.dart';
import '../models/clothing_item.dart';

/// Flat mannequin that wears the currently picked items.
/// Items with a PNG are drawn as images inside the body zone for their slot.
class OutfitFigure extends StatelessWidget {
  final ClothingItem top;
  final ClothingItem bottom;
  final ClothingItem shoes;
  final ClothingItem bag;
  final ClothingItem extra;

  const OutfitFigure({
    super.key,
    required this.top,
    required this.bottom,
    required this.shoes,
    required this.bag,
    required this.extra,
  });

  static const _skin = Color(0xFFDDA27F);
  static const _hair = Color(0xFF7A5A4A);

  // Body zones (inside the 170 x 300 figure box) where uploaded images go.
  static final _topZone = Rect.fromLTWH(36, 72, 98, 84);
  static final _bottomZone = Rect.fromLTWH(44, 150, 82, 100);
  static final _shoesZone = Rect.fromLTWH(40, 274, 90, 26);
  static final _bagZone = Rect.fromLTWH(124, 140, 44, 54);
  static final _extraZone = Rect.fromLTWH(40, 0, 90, 70);

  Widget _box(double l, double t, double w, double h, Color c,
      {BorderRadius? r, BoxShape shape = BoxShape.rectangle}) {
    return Positioned(
      left: l,
      top: t,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: c,
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : r,
        ),
      ),
    );
  }

  Widget _image(ClothingItem item, Rect zone) {
    return Positioned(
      left: zone.left,
      top: zone.top,
      width: zone.width,
      height: zone.height,
      child: Transform.translate(
        offset: Offset(item.dx, item.dy),
        child: Transform.scale(
          scale: item.scale,
          child: Image.memory(item.png!, fit: BoxFit.contain, gaplessPlayback: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // hair + face + neck
          _box(52, 0, 62, 70, _hair, r: BorderRadius.circular(32)),
          _box(60, 14, 46, 50, _skin, r: BorderRadius.circular(24)),
          _box(76, 58, 14, 16, _skin),
          // arms
          _box(28, 80, 16, 82, _skin, r: BorderRadius.circular(8)),
          _box(126, 80, 16, 82, _skin, r: BorderRadius.circular(8)),
          // legs
          _box(60, 246, 16, 42, _skin, r: BorderRadius.circular(6)),
          _box(94, 246, 16, 42, _skin, r: BorderRadius.circular(6)),

          // shoes
          if (shoes.png == null) ...[
            _box(52, 284, 32, 12, shoes.color, r: BorderRadius.circular(6)),
            _box(88, 284, 32, 12, shoes.color, r: BorderRadius.circular(6)),
          ] else
            _image(shoes, _shoesZone),

          // bottom
          if (bottom.png == null)
            _box(44, 150, 82, 100, bottom.color,
                r: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ))
          else
            _image(bottom, _bottomZone),

          // top
          if (top.png == null)
            _box(36, 72, 98, 84, top.color, r: BorderRadius.circular(22))
          else
            _image(top, _topZone),

          // bag
          if (bag.png == null)
            Positioned(
              left: 138,
              top: 150,
              child: Container(
                width: 28,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: bag.color, width: 4),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
              ),
            )
          else
            _image(bag, _bagZone),

          // extras (earrings, or an uploaded accessory)
          if (extra.png == null) ...[
            _box(55, 38, 7, 7, extra.color, shape: BoxShape.circle),
            _box(104, 38, 7, 7, extra.color, shape: BoxShape.circle),
          ] else
            _image(extra, _extraZone),
        ],
      ),
    );
  }
}
