import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../models/clothing_item.dart';
import '../widgets/outfit_figure.dart';

const categories = ['Tops', 'Bottoms', 'Footwear', 'Bags', 'Extras'];
const categorySingular = ['top', 'bottom', 'pair of shoes', 'bag', 'extra'];
const categoryIcons = [
  Icons.crop_square_rounded,
  Icons.shield_outlined,
  Icons.hexagon_outlined,
  Icons.square_outlined,
  Icons.circle_outlined,
];

const wardrobe = <List<ClothingItem>>[
  // Tops
  [
    ClothingItem('Sage', Color(0xFF9DB58A)),
    ClothingItem('Salmon', Color(0xFFDDA08E)),
    ClothingItem('Sand', Color(0xFFE3D9C8)),
    ClothingItem('Sky', Color(0xFF9DB4D4)),
  ],
  // Bottoms
  [
    ClothingItem('Olive', Color(0xFF9A9C7A)),
    ClothingItem('Navy', Color(0xFF3F4A6B)),
    ClothingItem('Cream', Color(0xFFEFE8DA)),
    ClothingItem('Clay', Color(0xFFB67A62)),
  ],
  // Footwear
  [
    ClothingItem('Off-white', Color(0xFFE8E2D6)),
    ClothingItem('Black', Color(0xFF2B2B2B)),
    ClothingItem('Tan', Color(0xFFC49A6C)),
  ],
  // Bags
  [
    ClothingItem('Camel', Color(0xFFC49A6C)),
    ClothingItem('Black', Color(0xFF2B2B2B)),
    ClothingItem('Lilac', Color(0xFFA9A5C4)),
  ],
  // Extras
  [
    ClothingItem('Gold', Color(0xFFC9A94E)),
    ClothingItem('Silver', Color(0xFFB8BCC4)),
    ClothingItem('Pearl', Color(0xFFF4EFE6)),
  ],
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0; // bottom nav
  int _category = 0; // Tops, Bottoms, ...
  final List<int> _picked = [1, 0, 0, 0, 0]; // chosen index per category
  bool _liked = false;

  final ImagePicker _picker = ImagePicker();

  // Copy of the wardrobe so we can add new items while the app runs.
  late final List<List<ClothingItem>> _wardrobe =
      wardrobe.map((l) => List<ClothingItem>.from(l)).toList();

  static const _days = [
    'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'
  ];
  static const _months = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY',
    'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
  ];

  String get _dateText {
    final n = DateTime.now();
    return '${_days[n.weekday - 1]}, ${_months[n.month - 1]} ${n.day}';
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 18) return 'Good afternoon,';
    return 'Good evening,';
  }

  ClothingItem _item(int cat) => _wardrobe[cat][_picked[cat]];

  void _shift(int delta) {
    final n = _wardrobe[_category].length;
    setState(() {
      _picked[_category] = (_picked[_category] + delta + n) % n;
    });
  }

  // ---------- upload from computer ----------

  /// Decodes any image the app can read (jpg, png, webp, gif...) and
  /// re-encodes it as PNG. Big images are shrunk to keep the app fast.
  Future<Uint8List?> _toPng(Uint8List bytes) async {
    try {
      var codec = await ui.instantiateImageCodec(bytes);
      var frame = await codec.getNextFrame();
      if (frame.image.width > 800) {
        codec = await ui.instantiateImageCodec(bytes, targetWidth: 800);
        frame = await codec.getNextFrame();
      }
      final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _addFromFile() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return; // cancelled
      final raw = await file.readAsBytes();
      final png = await _toPng(raw);
      if (!mounted) return;
      if (png == null) {
        _snack('Could not read that image. Try a PNG or JPG.');
        return;
      }
      final n = file.name;
      final name = n.contains('.') ? n.substring(0, n.lastIndexOf('.')) : n;
      _showAdjustSheet(png, name);
    } catch (e) {
      if (mounted) _snack('Could not open the file picker: $e');
    }
  }

  void _showAdjustSheet(Uint8List png, String name) {
    double scale = 1, dx = 0, dy = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final draft = ClothingItem(name, Colors.white,
              png: png, scale: scale, dx: dx, dy: dy);
          ClothingItem pick(int c) => c == _category ? draft : _item(c);

          Widget slider(String label, double v, double min, double max,
              ValueChanged<double> onChanged) {
            return Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(label,
                      style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ),
                Expanded(
                  child: Slider(
                    value: v,
                    min: min,
                    max: max,
                    activeColor: AppColors.ink,
                    inactiveColor: AppColors.chip,
                    onChanged: (x) => setSheet(() => onChanged(x)),
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fit your ${categorySingular[_category]}',
                    style: const TextStyle(
                        fontFamily: 'Georgia', fontSize: 24, color: AppColors.ink)),
                const SizedBox(height: 4),
                const Text('Use the sliders to match it to the body.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 14),
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.lavender,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: OutfitFigure(
                      top: pick(0),
                      bottom: pick(1),
                      shoes: pick(2),
                      bag: pick(3),
                      extra: pick(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                slider('Size', scale, 0.3, 2.5, (v) => scale = v),
                slider('Left / right', dx, -60, 60, (v) => dx = v),
                slider('Up / down', dy, -60, 60, (v) => dy = v),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setSheet(() {
                        scale = 1;
                        dx = 0;
                        dy = 0;
                      }),
                      child: const Text('Reset'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _wardrobe[_category].add(draft);
                            _picked[_category] = _wardrobe[_category].length - 1;
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Add to wardrobe'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const Divider(height: 1, color: Color(0xFFE9E5DD)),
            Expanded(
              child: _tab == 0
                  ? _homeTab()
                  : Center(
                      child: Text(
                        _tab == 1 ? 'Saved outfits (coming soon)' : 'Profile (coming soon)',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        backgroundColor: AppColors.cream,
        elevation: 0,
        selectedItemColor: AppColors.ink,
        unselectedItemColor: AppColors.muted,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.circle_outlined), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: "christy's",
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                TextSpan(
                  text: ' fit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.ink,
            child: Text('CM',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _homeTab() {
    final items = _wardrobe[_category];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_dateText,
                  style: const TextStyle(
                      fontSize: 11, letterSpacing: 1.4, color: AppColors.muted, fontWeight: FontWeight.w600)),
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(color: AppColors.chip, shape: BoxShape.circle),
                child: const Icon(Icons.more_horiz, size: 18, color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontFamily: 'Georgia', fontSize: 40, height: 1.1, color: AppColors.ink),
              children: [
                TextSpan(text: '$_greeting\n'),
                const TextSpan(
                  text: 'Christy.',
                  style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.accent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Build your look, one piece at a time.',
              style: TextStyle(fontSize: 14, color: Color(0xFF555555))),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('YOUR CANVAS',
                  style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: AppColors.muted)),
              Text('${categories[_category]} · ${_picked[_category] + 1} of ${items.length}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          _canvas(),
          const SizedBox(height: 16),
          _categoryTabs(),
          const SizedBox(height: 24),
          const Text('YOUR WARDROBE',
              style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: AppColors.muted)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Choose a ${categorySingular[_category]}.',
                  style: const TextStyle(fontFamily: 'Georgia', fontSize: 24, color: AppColors.ink)),
              GestureDetector(
                onTap: _addFromFile,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text('+ Add',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 92,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, i) {
                final selected = i == _picked[_category];
                final item = items[i];
                return GestureDetector(
                  onTap: () => setState(() => _picked[_category] = i),
                  child: Container(
                    width: 84,
                    margin: const EdgeInsets.only(right: 12),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: item.png == null ? item.color : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? AppColors.ink : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: item.png == null
                        ? null
                        : Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.memory(item.png!, fit: BoxFit.contain),
                          ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _canvas() {
    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v < -100) _shift(1);
        if (v > 100) _shift(-1);
      },
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          color: AppColors.lavender,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            OutfitFigure(
              top: _item(0),
              bottom: _item(1),
              shoes: _item(2),
              bag: _item(3),
              extra: _item(4),
            ),
            Positioned(left: 14, child: _roundButton(Icons.chevron_left, () => _shift(-1))),
            Positioned(right: 14, child: _roundButton(Icons.chevron_right, () => _shift(1))),
            Positioned(
              top: 0,
              right: 0,
              child: _roundButton(
                _liked ? Icons.favorite : Icons.favorite_border,
                () => setState(() => _liked = !_liked),
              ),
            ),
            Positioned(
              bottom: 14,
              child: Text('Swipe to change ${categories[_category].toLowerCase()}',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: AppColors.ink),
      ),
    );
  }

  Widget _categoryTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(categories.length, (i) {
        final selected = i == _category;
        return GestureDetector(
          onTap: () => setState(() => _category = i),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: selected ? AppColors.chipSelected : AppColors.chip,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(categoryIcons[i], size: 20, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              Text(categories[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected ? AppColors.ink : AppColors.muted,
                  )),
            ],
          ),
        );
      }),
    );
  }
}
