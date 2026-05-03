import 'package:flutter/material.dart';

import '../models/app_models.dart';
import 'app_scope.dart';

class AppLocalization {
  static const _en = <String, String>{
    'home': 'Home',
    'trips': 'Trips',
    'favorites': 'Favorites',
    'profile': 'Profile',
    'search_destinations': 'Search destinations',
    'categories': 'Categories',
    'featured_destinations': 'Featured Destinations',
    'map': 'Map',
    'quick_insights': 'Quick Insights',
    'offline_mode_ready': 'Offline mode ready',
    'timeline': 'Timeline',
    'create_new_trip': 'Create new trip',
    'clear_trip': 'Clear Trip',
    'estimated_cost': 'Estimated cost',
    'suggested_stops': 'Suggested stops',
    'saved_data': 'Saved data',
    'language': 'Language',
    'reset_local_data': 'Reset local data',
    'saved_places': 'Saved Places',
    'no_saved_places': 'No saved places yet',
  };

  static const _am = <String, String>{
    'home': 'ዋና ገጽ',
    'trips': 'ጉዞዎች',
    'favorites': 'የተወደዱ',
    'profile': 'መገለጫ',
    'search_destinations': 'መዳረሻዎችን ይፈልጉ',
    'categories': 'ምድቦች',
    'featured_destinations': 'ተወዳጅ መዳረሻዎች',
    'map': 'ካርታ',
    'quick_insights': 'ፈጣን መረጃዎች',
    'offline_mode_ready': 'ያለ በይነመረብ ዝግጁ ነው',
    'timeline': 'የጊዜ ሰሌዳ',
    'create_new_trip': 'አዲስ ጉዞ ፍጠር',
    'clear_trip': 'ጉዞ ሰርዝ',
    'estimated_cost': 'የተገመተ ወጪ',
    'suggested_stops': 'የተጠቆሙ ማቆሚያዎች',
    'saved_data': 'የተቀመጠ መረጃ',
    'language': 'ቋንቋ',
    'reset_local_data': 'አካባቢያዊ መረጃን ዳግም አስጀምር',
    'saved_places': 'የተቀመጡ ቦታዎች',
    'no_saved_places': 'እስካሁን ምንም የተቀመጡ ቦታዎች የሉም',
  };

  static String tr(BuildContext context, String key) {
    final language = AppStateScope.watch(context).language;
    final map = language == LanguageOption.amharic ? _am : _en;
    return map[key] ?? key;
  }
}
