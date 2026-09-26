import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import 'package:sixvalley_vendor_app/theme/dark_theme.dart';
import 'package:sixvalley_vendor_app/theme/light_theme.dart';

double contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  for (final theme in [light, dark]) {
    final mode = theme.brightness.name;

    test('$mode surface text and actions remain readable', () {
      final body = theme.textTheme.bodyLarge!.color!;
      final muted = theme.textTheme.bodySmall!.color!;
      final heading = theme.textTheme.headlineLarge!.color!;
      final hint = theme.hintColor;
      final accent = AppDesign.foregroundAccent(theme.brightness);

      for (final surface in [theme.cardColor, theme.scaffoldBackgroundColor]) {
        expect(contrast(body, surface), greaterThanOrEqualTo(4.5));
        expect(contrast(muted, surface), greaterThanOrEqualTo(4.5));
        expect(contrast(heading, surface), greaterThanOrEqualTo(4.5));
        expect(contrast(hint, surface), greaterThanOrEqualTo(4.5));
        expect(contrast(accent, surface), greaterThanOrEqualTo(4.5));
      }
    });
  }
}
