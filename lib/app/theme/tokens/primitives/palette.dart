import 'package:flutter/material.dart';

/// Raw color primitives.
///
/// Contains absolute color values used to construct semantic tokens.
/// Features must never import this file directly; use semantic tokens
/// from `context.colors` instead.
abstract final class Palette {
  // ─── Brand Red Family ──────────────────────────────────────────────
  static const brandRed = Color(0xFFDC2626); // Light theme brand red
  static const brandRedDark = Color(0xFFF04438); // Dark theme brand red
  static const brandRedLabel = Color(0xFFB01B1B); // Label on white button
  static const redTint = Color(0xFFFDECEC); // Subtle red surface tint

  // ─── Legacy Reds ───────────────────────────────────────────────────
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFE42C3A);
  static const red600 = Color(0xFFD61F26);
  static const red700 = Color(0xFFB91C1C);

  // ─── Cream Family (Used on red brand surfaces) ─────────────────────
  static const cream = Color(0xFFFFD2BE); // Wordmark "ez", accents
  static const creamBody = Color(0xFFFFD9CE); // Subtitles, body copy
  static const creamSmall = Color(0xFFFFD0BF); // Small print
  static const creamNote = Color(0xFFFFC7B4); // Security note
  static const creamPlaceholder = Color(0xFFFFC0AB); // Unfilled field placeholder
  static const creamDotError = Color(0xFFFFC2B4); // Passcode mismatch dots

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

  // ─── Design App Surface & Ink Primitives ───────────────────────────
  static const page = Color(0xFFF4F5F7);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF111111);
  static const ink2 = Color(0xFF55555C);
  static const ink3 = Color(0xFF8A8A90);
  static const line = Color(0xFFE4E4E8);

  static const pageDark = Color(0xFF0F1113);
  static const surfaceDark = Color(0xFF1A1D21);
  static const surfaceDark2 = Color(0xFF22262B);
  static const inkDark = Color(0xFFF2F2F4);
  static const ink2Dark = Color(0xFFA6A7AD);
  static const ink3Dark = Color(0xFF74767C);

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

  // Status pills
  static const okFill = Color(0xFFE7F5EC);
  static const okInk = Color(0xFF1B6B3A);
  static const waitFill = Color(0xFFFFF4E5);
  static const waitInk = Color(0xFF8A5300);
  static const noteInk = Color(0xFF7A4A00);
  static const verifiedInk = Color(0xFF7A1414);
  static const verifiedInk2 = Color(0xFFA33A3A);

  // ─── Red Surface Translucents ─────────────────────────────────────
  static const fieldFill = Color(0x21FFFFFF); // 0.13 opacity
  static const buttonOff = Color(0x38FFFFFF); // 0.22 opacity
  static const buttonOffLabel = Color(0x99FFFFFF); // 0.60 opacity
  static const keyFill = Color(0x1AFFFFFF); // 0.10 opacity
  static const cardFill = Color(0x1FFFFFFF); // 0.12 opacity
  static const dotOutline = Color(0x8CFFFFFF); // 0.55 opacity
  static const underline = Color(0x99FFFFFF); // 0.60 opacity
  static const underlineSoft = Color(0x8CFFFFFF); // 0.55 opacity
  static const codeBoxFill = Color(0x21FFFFFF); // 0.13 opacity
  static const codeBoxFocus = Color(0x2EFFFFFF); // 0.18 opacity

  // ─── Section 02 Verification Primitives ───────────────────────────
  static const stepInactiveText = Color(0x99FFFFFF);
  static const stepInactiveLabel = Color(0x9EFFFFFF);
  static const stepRing = Color(0x66FFFFFF);
  static const stepTrack = Color(0x40FFFFFF);
  static const cardTitleLocked = Color(0xBDFFFFFF);
  static const cardSubtitleLocked = Color(0x8CFFFFFF);
  static const cardFillNow = Color(0x2EFFFFFF);
  static const cardIconFill = Color(0x29FFFFFF);
  static const progressTrack = Color(0x38FFFFFF);
  static const chipFill = Color(0x21FFFFFF);
  static const outlineButton = Color(0x8CFFFFFF);
  static const divider = Color(0x29FFFFFF);
  static const shotBackdrop = Color(0x2E000000);
  static const trioRing = Color(0x73FFFFFF);

  // Camera & sensors
  static const cameraBackdrop = Color(0xFF15161A);
  static const ovalBackdrop = Color(0xFF1B1D22);
  static const ovalRing = Color(0x8CFFFFFF);
  static const ovalHalo = Color(0x1AFFFFFF);
  static const scrubTrack = Color(0x47FFFFFF);
  static const nfcRing = Color(0x99FFFFFF);
  static const nfcCore = Color(0x2EFFFFFF);

  // ─── Section 03 Main App Polish ───────────────────────────────────
  static const placeholder = Color(0xFFE8E6E1);
  static const placeholderIcon = Color(0xFFBEBBB4);
  static const soonCard = Color(0xFFFAFAFB);
  static const soonIcon = Color(0xFFB3B3B8);
  static const chipBorder = Color(0xFFE4E4E8);
  static const chevron = Color(0xFFC6C6CB);
  static const photoChip = Color(0xF0FFFFFF);
  static const buttonIdle = Color(0xFFEDEDEF);
  static const buttonIdleLabel = Color(0xFFB0B0B6);
  static const bulletDot = Color(0xFFD3D3D8);
  static const scrim = Color(0x73111111);
  static const cardBorderSoft = Color(0xFFEDEDF1);
  static const cardShadow = Color(0x08000000);

  // ─── Paper Palette (Findr) ────────────────────────────────────────
  static const paper = Color(0xFFFBF5E9);
  static const paperInk = Color(0xFF3D3223);
  static const paperInk2 = Color(0xFF8A7A61);
  static const paperLine = Color(0xFFE8DEC9);
  static const paperDark = Color(0xFF241F19);
  static const paperInkDark = Color(0xFFF2E7D4);
  static const paperInk2Dark = Color(0xFFA3927A);
  static const paperLineDark = Color(0xFF3A3128);

  // ─── Section 05 Check-in & Hotel Preview ──────────────────────────
  static const stepPanel = Color(0x1FFFFFFF);
  static const stepPanelNow = Color(0x33FFFFFF);
  static const flagPanel = Color(0x24FFFFFF);
  static const ringPanel = Color(0x29FFFFFF);
  static const guestAvatar = Color(0x33FFFFFF);
  static const consentBox = Color(0x99FFFFFF);
  static const disclosureDimIcon = Color(0x73FFFFFF);
  static const disclosureDimText = Color(0x8CFFFFFF);
  static const passRef = Color(0x2EFFFFFF);

  static const hotelScreen = Color(0xFF1B1D22);
  static const hotelLabel = Color(0xFF7B7F86);
  static const hotelMeta = Color(0xFF9BA0A8);
  static const hotelLine = Color(0xFF2A2D33);
  static const hotelOkFill = Color(0xFF14301F);
  static const hotelOkInk = Color(0xFF6FD79B);

  // ─── Feature Accents ──────────────────────────────────────────────
  static const indigo500 = Color(0xFF6366F1);
  static const purple500 = Color(0xFF8B5CF6);
  static const sky500 = Color(0xFF0EA5E9);
  static const amber400 = Color(0xFFFBBF24);
  static const emerald500 = Color(0xFF10B981);
  static const emerald400 = Color(0xFF34D399);
}
