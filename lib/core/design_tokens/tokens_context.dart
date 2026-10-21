import 'package:flutter/material.dart';
import 'shape_tokens.dart';
import 'size_tokens.dart';
import 'space_tokens.dart';

/// BuildContext extension providing convenient semantic access to layout tokens.
extension TokensContext on BuildContext {
  /// Semantic spacing tokens for insets and gaps.
  AppSpace get space =>
      Theme.of(this).extension<AppSpace>() ?? AppSpace.comfortable;

  /// Semantic sizing tokens for controls, icons, avatars, and containers.
  ///
  /// Flutter's [BuildContext] already declares a built-in `Size? get size` instance getter.
  /// Therefore, `context.sizes` is provided for direct access without collision,
  /// while `TokensContext(context).size` is also available.
  AppSize get sizes => Theme.of(this).extension<AppSize>() ?? AppSize.regular;

  /// Semantic sizing tokens (accessible via `TokensContext(context).size`).
  AppSize get size => Theme.of(this).extension<AppSize>() ?? AppSize.regular;

  /// Semantic shape tokens for corner radii, border widths, strokes, and dividers.
  AppShape get shape =>
      Theme.of(this).extension<AppShape>() ?? AppShape.standard;
}
