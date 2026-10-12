import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('fr');

  void toggleLocale() {
    state = state.languageCode == 'fr'
        ? const Locale('en')
        : const Locale('fr');
  }

  void setLocale(Locale newLocale) {
    state = newLocale;
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
