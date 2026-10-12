import 'package:flutter/material.dart';

/// Standard border radius constants and shapes.
abstract final class AppRadius {
  static const double xxs = 2;
  static const double xs = 4;
  static const double xs6 = 6;
  static const double sm = 8;
  static const double sm10 = 10;
  static const double md = 12;
  static const double md14 = 14;
  static const double lg = 16;
  static const double lg20 = 20;
  static const double xl22 = 22;
  static const double xl = 24;
  static const double pill = 999;

  static BorderRadius get xxsRadius => BorderRadius.circular(xxs);
  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get xs6Radius => BorderRadius.circular(xs6);
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get sm10Radius => BorderRadius.circular(sm10);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get md14Radius => BorderRadius.circular(md14);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get lg20Radius => BorderRadius.circular(lg20);
  static BorderRadius get xl22Radius => BorderRadius.circular(xl22);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);

  // Semantic aliases
  static BorderRadius get card => BorderRadius.circular(xl);
  static BorderRadius get cardRadius => BorderRadius.circular(lg);
  static BorderRadius get cardSm => BorderRadius.circular(md);
  static BorderRadius get button => BorderRadius.circular(md);
  static BorderRadius get input => BorderRadius.circular(md);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
  static BorderRadius get fullRadius => BorderRadius.circular(pill);
}
