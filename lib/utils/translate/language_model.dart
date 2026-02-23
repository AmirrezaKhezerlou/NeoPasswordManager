import 'package:flutter/material.dart';

class LanguageModel {
  final String name;
  final Locale locale;
  final String flagCode;

  const LanguageModel({
    required this.name,
    required this.locale,
    required this.flagCode,
  });

  static List<LanguageModel> get languages => [
    const LanguageModel(
      name: 'فارسی',
      locale: Locale('fa', 'IR'),
      flagCode: '🇮🇷',
    ),
    const LanguageModel(
      name: 'English',
      locale: Locale('en', 'US'),
      flagCode: '🇺🇸',
    ),
    const LanguageModel(
      name: 'العربية',
      locale: Locale('ar', 'SA'),
      flagCode: '🇸🇦',
    ),
    const LanguageModel(
      name: 'Deutsch',
      locale: Locale('de', 'DE'),
      flagCode: '🇩🇪',
    ),
  ];
}