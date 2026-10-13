import 'package:flutter/material.dart';

/// App icon constants mapped to the subsetted TablerIcons webfont.
///
/// Use [AppIcons] across all features rather than mixing in standard Material icons.
abstract final class AppIcons {
  static const _fontFamily = 'TablerIcons';
  static const _filledFontFamily = 'TablerIconsFilled';

  // ─── Filled Icons ──────────────────────────────────────────────────
  /// Solid red location pin used in the home hub header.
  static const mapPinFilled = IconData(0xf680, fontFamily: _filledFontFamily);

  // ─── Authentication (Section 01) ───────────────────────────────────
  static const eye = IconData(0xea9a, fontFamily: _fontFamily);
  static const eyeOff = IconData(0xecf0, fontFamily: _fontFamily);
  static const backspace = IconData(0xea2d, fontFamily: _fontFamily);
  static const numbers = IconData(0xf015, fontFamily: _fontFamily);
  static const shieldLock = IconData(0xed58, fontFamily: _fontFamily);
  static const repeat = IconData(0xeb72, fontFamily: _fontFamily);
  static const rotate = IconData(0xeb16, fontFamily: _fontFamily);
  static const bulb = IconData(0xea51, fontFamily: _fontFamily);
  static const refresh = IconData(0xeb13, fontFamily: _fontFamily);
  static const arrowLeft = IconData(0xea19, fontFamily: _fontFamily);
  static const arrowRight = IconData(0xea1f, fontFamily: _fontFamily);
  static const lock = IconData(0xeae2, fontFamily: _fontFamily);
  static const check = IconData(0xea5e, fontFamily: _fontFamily);

  // ─── Verification (Section 02) ─────────────────────────────────────
  static const paperclip = IconData(0xeb02, fontFamily: _fontFamily);
  static const deviceMobile = IconData(0xea8a, fontFamily: _fontFamily);
  static const fileCheck = IconData(0xea9c, fontFamily: _fontFamily);
  static const shield = IconData(0xeb24, fontFamily: _fontFamily);
  static const circleCheck = IconData(0xea67, fontFamily: _fontFamily);
  static const alertCircle = IconData(0xea05, fontFamily: _fontFamily);
  static const playerPlay = IconData(0xed46, fontFamily: _fontFamily);
  static const reload = IconData(0xf3ae, fontFamily: _fontFamily);
  static const maximize = IconData(0xeaea, fontFamily: _fontFamily);
  static const zoomIn = IconData(0xeb56, fontFamily: _fontFamily);
  static const wifi = IconData(0xeb52, fontFamily: _fontFamily);
  static const hourglass = IconData(0xef93, fontFamily: _fontFamily);
  static const crop = IconData(0xea85, fontFamily: _fontFamily);
  static const handStop = IconData(0xec2e, fontFamily: _fontFamily);
  static const faceId = IconData(0xea9b, fontFamily: _fontFamily);
  static const video = IconData(0xed22, fontFamily: _fontFamily);
  static const circleX = IconData(0xea6a, fontFamily: _fontFamily);
  static const clock = IconData(0xea70, fontFamily: _fontFamily);
  static const sun = IconData(0xf236, fontFamily: _fontFamily);
  static const moodSmile = IconData(0xeaf7, fontFamily: _fontFamily);
  static const userCircle = IconData(0xef68, fontFamily: _fontFamily);
  static const eyeglassOff = IconData(0xf126, fontFamily: _fontFamily);
  static const waveSquare = IconData(0xecd5, fontFamily: _fontFamily);
  static const certificate = IconData(0xed76, fontFamily: _fontFamily);
  static const fingerprint = IconData(0xebd1, fontFamily: _fontFamily);
  static const idBadge2 = IconData(0xf076, fontFamily: _fontFamily);

  // ─── Shared & Reserved ─────────────────────────────────────────────
  static const chevronRight = IconData(0xea61, fontFamily: _fontFamily);
  static const chevronDown = IconData(0xea5f, fontFamily: _fontFamily);
  static const user = IconData(0xeb4d, fontFamily: _fontFamily);
  static const mail = IconData(0xeae5, fontFamily: _fontFamily);
  static const users = IconData(0xebf2, fontFamily: _fontFamily);
  static const adjustments = IconData(0xea03, fontFamily: _fontFamily);
  static const creditCard = IconData(0xea84, fontFamily: _fontFamily);
  static const receipt = IconData(0xedfd, fontFamily: _fontFamily);
  static const key = IconData(0xeac7, fontFamily: _fontFamily);
  static const shieldCheck = IconData(0xeb22, fontFamily: _fontFamily);
  static const home = IconData(0xeac1, fontFamily: _fontFamily);
  static const calendar = IconData(0xea53, fontFamily: _fontFamily);
  static const heart = IconData(0xeabe, fontFamily: _fontFamily);
  static const rosetteDiscountCheck = IconData(0xf1f8, fontFamily: _fontFamily);
  static const playerPause = IconData(0xed45, fontFamily: _fontFamily);
  static const trash = IconData(0xeb41, fontFamily: _fontFamily);
  static const infoCircle = IconData(0xeac5, fontFamily: _fontFamily);
  static const camera = IconData(0xea54, fontFamily: _fontFamily);
  static const nfc = IconData(0xeeb7, fontFamily: _fontFamily);
  static const id = IconData(0xeac3, fontFamily: _fontFamily);
  static const alertTriangle = IconData(0xea06, fontFamily: _fontFamily);
  static const close = IconData(0xeb55, fontFamily: _fontFamily);
  static const dots = IconData(0xea95, fontFamily: _fontFamily);
  static const scan = IconData(0xebc8, fontFamily: _fontFamily);
  static const photo = IconData(0xeb0a, fontFamily: _fontFamily);

  // ─── Main Signed-In App (Section 03) ───────────────────────────────
  static const mapPin = IconData(0xeae8, fontFamily: _fontFamily);
  static const building = IconData(0xea4f, fontFamily: _fontFamily);
  static const buildingArch = IconData(0xea49, fontFamily: _fontFamily);
  static const wallet = IconData(0xeb75, fontFamily: _fontFamily);
  static const shoppingBag = IconData(0xf5f8, fontFamily: _fontFamily);
  static const messageCircle = IconData(0xeaed, fontFamily: _fontFamily);
  static const mapSearch = IconData(0xef82, fontFamily: _fontFamily);
  static const search = IconData(0xeb1c, fontFamily: _fontFamily);
  static const coin = IconData(0xeb82, fontFamily: _fontFamily);
  static const language = IconData(0xebbe, fontFamily: _fontFamily);
  static const bell = IconData(0xea35, fontFamily: _fontFamily);
  static const help = IconData(0xeabf, fontFamily: _fontFamily);
  static const fileText = IconData(0xeaa2, fontFamily: _fontFamily);
  static const download = IconData(0xea96, fontFamily: _fontFamily);
  static const starFilled = Icons.star_rounded;
  static const star = Icons.star_outline_rounded;

  // ─── Check-in (Section 05) ─────────────────────────────────────────
  static const doorEnter = IconData(0xef4c, fontFamily: _fontFamily);
  static const ticket = IconData(0xeb3d, fontFamily: _fontFamily);
  static const buildingStore = IconData(0xea4e, fontFamily: _fontFamily);
  static const qrcode = IconData(0xeb11, fontFamily: _fontFamily);
  static const send = IconData(0xeb1e, fontFamily: _fontFamily);
  static const fileSearch = IconData(0xed5d, fontFamily: _fontFamily);
  static const scale = IconData(0xebc2, fontFamily: _fontFamily);

  // ─── Semantic Aliases ──────────────────────────────────────────────
  static const x = close;
  static const plus = Icons.add_rounded;
  static const globe = building;
  static const info = infoCircle;
  static const checkCircle = circleCheck;
  static const shieldAlert = alertTriangle;
}
