import 'dart:core';

class WebFont {
  final String family;
  final String? src;
  final String? display;
  final String? style;
  final String? unicodeRange;
  final String? weight;
  final String? cssSrc;

  WebFont({
    required this.family,
    this.src,
    this.display,
    this.style,
    this.unicodeRange,
    this.weight,
    this.cssSrc,
  });
}
