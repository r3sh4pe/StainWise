import 'package:flutter/material.dart';

/// Catppuccin color palette implementation
class CatppuccinColors {
  // Latte palette
  static const lattePalette = CatppuccinPalette(
    rosewater: Color(0xFFDC8A78),
    flamingo: Color(0xFFDD7878),
    pink: Color(0xFFEA76CB),
    mauve: Color(0xFF8839EF),
    red: Color(0xFFD20F39),
    maroon: Color(0xFFE64553),
    peach: Color(0xFFFE640B),
    yellow: Color(0xFFDF8E1D),
    green: Color(0xFF40A02B),
    teal: Color(0xFF179299),
    sky: Color(0xFF04A5E5),
    sapphire: Color(0xFF209FB5),
    blue: Color(0xFF1E66F5),
    lavender: Color(0xFF7287FD),
    text: Color(0xFF4C4F69),
    subtext1: Color(0xFF5C5F77),
    subtext0: Color(0xFF6C6F85),
    overlay2: Color(0xFF7C7F93),
    overlay1: Color(0xFF8C8FA1),
    overlay0: Color(0xFF9CA0B0),
    surface2: Color(0xFFACB0BE),
    surface1: Color(0xFFBCC0CC),
    surface0: Color(0xFFCCD0DA),
    base: Color(0xFFEFF1F5),
    mantle: Color(0xFFE6E9EF),
    crust: Color(0xFFDCE0E8),
  );

  // Frappé palette
  static const frappePalette = CatppuccinPalette(
    rosewater: Color(0xFFF2D5CF),
    flamingo: Color(0xFFEEBEBE),
    pink: Color(0xFFF4B8E4),
    mauve: Color(0xFFCA9EE6),
    red: Color(0xFFE78284),
    maroon: Color(0xFFEA999C),
    peach: Color(0xFFEF9F76),
    yellow: Color(0xFFE5C890),
    green: Color(0xFFA6D189),
    teal: Color(0xFF81C8BE),
    sky: Color(0xFF99D1DB),
    sapphire: Color(0xFF85C1DC),
    blue: Color(0xFF8CAAEE),
    lavender: Color(0xFFBABBF1),
    text: Color(0xFFC6D0F5),
    subtext1: Color(0xFFB5BFE2),
    subtext0: Color(0xFFA5ADCE),
    overlay2: Color(0xFF949CBB),
    overlay1: Color(0xFF838BA7),
    overlay0: Color(0xFF737994),
    surface2: Color(0xFF626880),
    surface1: Color(0xFF51576D),
    surface0: Color(0xFF414559),
    base: Color(0xFF303446),
    mantle: Color(0xFF292C3C),
    crust: Color(0xFF232634),
  );

  // Macchiato palette
  static const macchiatoPalette = CatppuccinPalette(
    rosewater: Color(0xFFF4DBD6),
    flamingo: Color(0xFFF0C6C6),
    pink: Color(0xFFF5BDE6),
    mauve: Color(0xFFC6A0F6),
    red: Color(0xFFED8796),
    maroon: Color(0xFFEE99A0),
    peach: Color(0xFFF5A97F),
    yellow: Color(0xFFEED49F),
    green: Color(0xFFA6DA95),
    teal: Color(0xFF8BD5CA),
    sky: Color(0xFF91D7E3),
    sapphire: Color(0xFF7DC4E4),
    blue: Color(0xFF8AADF4),
    lavender: Color(0xFFB7BDF8),
    text: Color(0xFFCAD3F5),
    subtext1: Color(0xFFB8C0E0),
    subtext0: Color(0xFFA5ADCB),
    overlay2: Color(0xFF939AB7),
    overlay1: Color(0xFF8087A2),
    overlay0: Color(0xFF6E738D),
    surface2: Color(0xFF5B6078),
    surface1: Color(0xFF494D64),
    surface0: Color(0xFF363A4F),
    base: Color(0xFF24273A),
    mantle: Color(0xFF1E2030),
    crust: Color(0xFF181926),
  );

  // Mocha palette
  static const mochaPalette = CatppuccinPalette(
    rosewater: Color(0xFFF5E0DC),
    flamingo: Color(0xFFF2CDCD),
    pink: Color(0xFFF5C2E7),
    mauve: Color(0xFFCBA6F7),
    red: Color(0xFFF38BA8),
    maroon: Color(0xFFEBA0AC),
    peach: Color(0xFFFAB387),
    yellow: Color(0xFFF9E2AF),
    green: Color(0xFFA6E3A1),
    teal: Color(0xFF94E2D5),
    sky: Color(0xFF89DCEB),
    sapphire: Color(0xFF74C7EC),
    blue: Color(0xFF89B4FA),
    lavender: Color(0xFFB4BEFE),
    text: Color(0xFFCDD6F4),
    subtext1: Color(0xFFBAC2DE),
    subtext0: Color(0xFFA6ADC8),
    overlay2: Color(0xFF9399B2),
    overlay1: Color(0xFF7F849C),
    overlay0: Color(0xFF6C7086),
    surface2: Color(0xFF585B70),
    surface1: Color(0xFF45475A),
    surface0: Color(0xFF313244),
    base: Color(0xFF1E1E2E),
    mantle: Color(0xFF181825),
    crust: Color(0xFF11111B),
  );
}

class CatppuccinPalette {
  final Color rosewater;
  final Color flamingo;
  final Color pink;
  final Color mauve;
  final Color red;
  final Color maroon;
  final Color peach;
  final Color yellow;
  final Color green;
  final Color teal;
  final Color sky;
  final Color sapphire;
  final Color blue;
  final Color lavender;
  final Color text;
  final Color subtext1;
  final Color subtext0;
  final Color overlay2;
  final Color overlay1;
  final Color overlay0;
  final Color surface2;
  final Color surface1;
  final Color surface0;
  final Color base;
  final Color mantle;
  final Color crust;

  const CatppuccinPalette({
    required this.rosewater,
    required this.flamingo,
    required this.pink,
    required this.mauve,
    required this.red,
    required this.maroon,
    required this.peach,
    required this.yellow,
    required this.green,
    required this.teal,
    required this.sky,
    required this.sapphire,
    required this.blue,
    required this.lavender,
    required this.text,
    required this.subtext1,
    required this.subtext0,
    required this.overlay2,
    required this.overlay1,
    required this.overlay0,
    required this.surface2,
    required this.surface1,
    required this.surface0,
    required this.base,
    required this.mantle,
    required this.crust,
  });
}

enum ThemeVariant {
  latte,
  frappe,
  macchiato,
  mocha,
}