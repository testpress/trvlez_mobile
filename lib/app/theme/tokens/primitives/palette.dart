import 'package:flutter/material.dart';

/// Raw color primitives.
///
/// Contains absolute color values used to construct semantic tokens.
/// Features must never import this file directly; use semantic tokens
/// from `context.colors` instead.
abstract final class Palette {
  // ─── Reds (Primary brand) ──────────────────────────────────────────
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFE42C3A);
  static const red600 = Color(0xFFD61F26);
  static const red700 = Color(0xFFB91C1C);

  // ─── Neutrals & Slates ─────────────────────────────────────────────
  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral100 = Color(0xFFF6F6F6);
  static const neutral150 = Color(0xFFF2F2F2);
  static const neutral200 = Color(0xFFE2E8F0);
  static const neutral300 = Color(0xFFCBD5E1);
  static const neutral400 = Color(0xFF94A3B8);
  static const neutral500 = Color(0xFF64748B);
  static const neutral600 = Color(0xFF475569);
  static const neutral700 = Color(0xFF334155);
  static const neutral800 = Color(0xFF1E293B);
  static const neutral900 = Color(0xFF0F172A);
  static const neutral950 = Color(0xFF020617);

  // ─── Blues ────────────────────────────────────────────────────────
  static const blue400 = Color(0xFF38BDF8);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF0277BD);

  // ─── Status & Feedback ────────────────────────────────────────────
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);
  static const amber500 = Color(0xFFF59E0B);
  static const orange500 = Color(0xFFE65100);

  // ─── Feature Accents ──────────────────────────────────────────────
  static const indigo500 = Color(0xFF6366F1);
  static const purple500 = Color(0xFF8B5CF6);
  static const sky500 = Color(0xFF0EA5E9);
  static const amber400 = Color(0xFFFBBF24);
  static const emerald500 = Color(0xFF10B981);
  static const emerald400 = Color(0xFF34D399);
}
