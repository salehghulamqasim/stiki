import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stiki/models/widget_model.dart';
import 'package:uuid/uuid.dart';

class StorageHelper {
  static const _key = 'quotes';

  static Future<void> saveQuote(
    String quote, {
    String? id,
    List<String> quotes = const [],
    String topic = '',
    String frequency = 'none',
    int? currentIndex,
    String? widgetName,
    DateTime? lastUpdated,
    int? backgroundColor,
    int? textColor,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final allWidgets = await getQuotes();

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
          currentIndex: currentIndex ?? allWidgets[index].currentIndex,
          widgetName: widgetName ?? allWidgets[index].widgetName,
          createdAt: allWidgets[index].createdAt,
          lastUpdated: lastUpdated ?? DateTime.now(),
          backgroundColor: backgroundColor ?? allWidgets[index].backgroundColor,
          textColor: textColor ?? allWidgets[index].textColor,
        );
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
            backgroundColor: backgroundColor,
            textColor: textColor,
          ),
        );
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
          widgetName: widgetName ?? 'StikiWidgetLight',
          createdAt: DateTime.now(),
          lastUpdated: lastUpdated ?? DateTime.now(),
          backgroundColor: backgroundColor,
          textColor: textColor,
        ),
      );
    }
    final jsonList = allWidgets.map((q) => jsonEncode(q.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  static Future<List<QuoteWidget>> getQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList
        .map(
          (json) =>
              QuoteWidget.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  static Future<void> deleteQuote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final quotes = await getQuotes();
    quotes.removeWhere((q) => q.id == id);

    final jsonList = quotes.map((q) => jsonEncode(q.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  static Future<QuoteWidget> getQuoteByIdOrNew(String id) async {
    final widgets = await getQuotes();

    try {
      return widgets.firstWhere((w) => w.id == id);
    } catch (e) {
      String widgetName = 'StikiWidgetLight';

      try {
        final installedWidgets = await HomeWidget.getInstalledWidgets();
        final widgetIdInt = int.tryParse(id);

        if (widgetIdInt != null) {
          final matchingWidget = installedWidgets.firstWhere(
            (w) => w.androidWidgetId == widgetIdInt,
            orElse: () => installedWidgets.first,
          );

          if (matchingWidget.androidClassName?.contains('Dark') ?? false) {
            widgetName = 'StikiWidgetDark';
          } else if (matchingWidget.androidClassName?.contains('Light') ??
              false) {
            widgetName = 'StikiWidgetLight';
          }
        }
      } catch (e) {
        // Silently fail
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

      await saveQuote(
        newWidget.quote,
        id: newWidget.id,
        widgetName: newWidget.widgetName,
      );

      return newWidget;
    }
  }

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

  static const _futureQuotesKey = 'future_quotes_cache';

  static Future<void> addFutureQuotes(List<String> newQuotes) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFutureQuotes();
    current.addAll(newQuotes);
    await prefs.setStringList(_futureQuotesKey, current);
  }

  static Future<List<String>> getFutureQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_futureQuotesKey) ?? [];
  }

  static Future<String?> popFutureQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFutureQuotes();

    if (current.isEmpty) return null;

    final quote = current.removeAt(0);
    await prefs.setStringList(_futureQuotesKey, current);
    return quote;
  }
}
