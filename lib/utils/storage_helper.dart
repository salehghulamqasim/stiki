import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stiki/models/widget_model.dart';
import 'package:uuid/uuid.dart';

// this class takes key named quotes
// and then uses saveQuote to save the quotes with sharedprefence.getisntance method
//then uses getQuotes to get the quotes from sharedprefence.getisntance method
//then uses deleteQuote to delete the quotes from sharedprefence.getisntance method
class StorageHelper {
  static const _key = 'quotes';

  // Update this method to handle both New and Existing quotes
  static Future<void> saveQuote(
    String quote, {
    String? id,
    List<String> quotes = const [],
    String topic = '',
    String frequency = 'none',
    int? currentIndex, // Changed from int currentIndex = 0 => int?
    String? widgetName, // ⬅️ Add this
    DateTime? lastUpdated, // ⬅️ Add this
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final allWidgets = await getQuotes();

    debugPrint('💾 saveQuote called with id: $id, quote: $quote');
    debugPrint(
      '💾 Existing widgets before save: ${allWidgets.map((w) => w.id).toList()}',
    );

    if (id != null) {
      final index = allWidgets.indexWhere((q) => q.id == id);
      if (index != -1) {
        allWidgets[index] = QuoteWidget(
          id: id,
          quote: quote,
          quotes: quotes.isNotEmpty ? quotes : allWidgets[index].quotes,
          topic: topic.isNotEmpty ? topic : allWidgets[index].topic,
          frequency: frequency != 'none'
              ? frequency
              : allWidgets[index].frequency,
          currentIndex:
              currentIndex ?? allWidgets[index].currentIndex, // Fix here
          widgetName:
              widgetName ?? allWidgets[index].widgetName, // ⬅️ Keep old if null
          createdAt: allWidgets[index].createdAt,
          lastUpdated: lastUpdated ?? DateTime.now(),
        );
        debugPrint('💾 Updated existing widget with id: $id');
      } else {
        allWidgets.add(
          QuoteWidget(
            id: id,
            quote: quote,
            quotes: quotes,
            topic: topic,
            frequency: frequency,
            currentIndex: currentIndex ?? 0,
            widgetName: widgetName ?? 'StikiWidgetLight',
            createdAt: DateTime.now(),
            lastUpdated: lastUpdated ?? DateTime.now(),
          ),
        );
        debugPrint('💾 Added new widget with id: $id');
      }
    } else {
      allWidgets.add(
        QuoteWidget(
          id: const Uuid().v4(),
          quote: quote,
          quotes: quotes,
          topic: topic,
          frequency: frequency,
          currentIndex: currentIndex ?? 0,
          widgetName: widgetName ?? 'StikiWidgetLight', // ⬅️ Default to Light
          createdAt: DateTime.now(),
          lastUpdated: lastUpdated ?? DateTime.now(),
        ),
      );
      debugPrint('💾 Added new widget with random UUID');
    }
    final jsonList = allWidgets.map((q) => jsonEncode(q.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
    debugPrint(
      '💾 Widgets after save: ${allWidgets.map((w) => w.id).toList()}',
    );

    if (id != null) {
      // No need to save text here as it's already in the JSON and
      // note_screenshot_$id key is reserved for the rendered image path
    }
  }

  // Get all quotes
  static Future<List<QuoteWidget>> getQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    // Use .cast<String>() and ensure the map returns QuoteWidget
    return jsonList
        .map(
          (json) =>
              QuoteWidget.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  // Delete quote
  static Future<void> deleteQuote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final quotes = await getQuotes();
    quotes.removeWhere((q) => q.id == id);

    final jsonList = quotes.map((q) => jsonEncode(q.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  /// Helper to find a widget by ID, or create a new default one if not found.
  static Future<QuoteWidget> getQuoteByIdOrNew(String id) async {
    debugPrint("🔍 getQuoteByIdOrNew called with id: $id");
    final widgets = await getQuotes();

    try {
      // Try to find the existing widget
      return widgets.firstWhere((w) => w.id == id);
    } catch (e) {
      // Not found, need to create new
      // First, determine the widget type by checking installed widgets
      String widgetName = 'StikiWidgetLight'; // Default

      try {
        final installedWidgets = await HomeWidget.getInstalledWidgets();
        // The appWidgetId from Android is an integer, but our id is a string
        final widgetIdInt = int.tryParse(id);

        if (widgetIdInt != null) {
          // Find the widget with this ID
          final matchingWidget = installedWidgets.firstWhere(
            (w) => w.androidWidgetId == widgetIdInt,
            orElse: () => installedWidgets.first,
          );

          // Use the className to determine the type
          if (matchingWidget.androidClassName?.contains('Dark') ?? false) {
            widgetName = 'StikiWidgetDark';
          } else if (matchingWidget.androidClassName?.contains('Light') ??
              false) {
            widgetName = 'StikiWidgetLight';
          }
        }
      } catch (e) {
        // If querying fails, use default Light
        debugPrint("Could not determine widget type: $e");
      }

      final newWidget = QuoteWidget(
        id: id,
        quote: "Tap to edit",
        quotes: ["Tap to edit"],
        topic: "General",
        frequency: "none",
        currentIndex: 0,
        widgetName: widgetName,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      // Save it immediately so it exists next time
      await saveQuote(
        newWidget.quote,
        id: newWidget.id,
        widgetName: newWidget.widgetName,
      );

      return newWidget;
    }
  }

  // --- DAILY QUOTE FEATURE ---
  static const _dailyQuoteKey = 'daily_quote_data';

  static Future<Map<String, dynamic>?> getDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_dailyQuoteKey);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static Future<void> saveDailyQuote(String quote, String dateString) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {'quote': quote, 'date': dateString};
    await prefs.setString(_dailyQuoteKey, jsonEncode(data));
  }

  // --- BATCH CACHE FEATURE ---
  static const _futureQuotesKey = 'future_quotes_cache';

  // Save a list of new quotes to the cache
  static Future<void> addFutureQuotes(List<String> newQuotes) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFutureQuotes();
    current.addAll(newQuotes);
    await prefs.setStringList(_futureQuotesKey, current);
  }

  // Get current cache
  static Future<List<String>> getFutureQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_futureQuotesKey) ?? [];
  }

  // Get one quote and remove it from cache (Pop)
  static Future<String?> popFutureQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFutureQuotes();

    if (current.isEmpty) return null;

    final quote = current.removeAt(0); // Take the first one
    await prefs.setStringList(_futureQuotesKey, current); // Save updated list
    return quote;
  }
}
