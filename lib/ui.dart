import 'package:flutter/material.dart';

const deepRed = Color(0xFF9E2A2B);
const mustard = Color(0xFFE09F3E);
const cream = Color(0xFFFFF8ED);
const coffee = Color(0xFF2B2118);
const olive = Color(0xFF6A994E);

const dishCategories = <String>[
  'Burger',
  'Pizza',
  'Pasta',
  'Chicken',
  'Seafood',
  'Dessert',
  'Drinks',
  'Breakfast',
  'Other',
];

ThemeData dishlyTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: deepRed,
      brightness: brightness,
      primary: deepRed,
      secondary: mustard,
    ),
    scaffoldBackgroundColor: dark ? const Color(0xFF17120F) : cream,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: dark ? const Color(0xFF241B16) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: dark ? const Color(0xFF3A2D26) : const Color(0xFFF0E2D1),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF241B16) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: dark ? Colors.white : coffee,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class DishlyMark extends StatelessWidget {
  final double size;

  const DishlyMark({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: deepRed,
        borderRadius: BorderRadius.circular(size * .28),
      ),
      child: Icon(
        Icons.restaurant_menu_rounded,
        color: const Color(0xFFFFF3DC),
        size: size * .48,
      ),
    );
  }
}

String dateLabel(DateTime date) {
  const months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
