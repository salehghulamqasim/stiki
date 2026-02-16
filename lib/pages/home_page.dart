import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stiki/components/widget_gallery.dart';
import 'package:stiki/models/widget_model.dart';
import 'package:stiki/pages/widget_screen.dart';
import 'package:stiki/components/quote_card.dart';
import 'package:stiki/pages/widget_screens_edit.dart';
import 'package:stiki/utils/haptic_helper.dart';
import 'package:stiki/utils/storage_helper.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stiki/services/ai_service.dart';
import 'package:stiki/services/widget_service.dart';
import 'package:stiki/theme/app_colors.dart';
import 'package:home_widget/home_widget.dart';
import 'package:stiki/animations/stiki_animations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<QuoteWidget> mySavedWidgets = [];
  String _displayQuote = "The best way to predict the future is to create it.";
  String _quoteAuthor = "Stiki";
  final bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadSavedWidgets();
    _checkDailyQuote();
    _checkAndRotateOverdueWidgets();
    _promptBatteryOptimization();
  }

  // --- DAILY QUOTE LOGIC (Instant Update via Cache) ---
  Future<void> _checkDailyQuote() async {
    final savedData = await StorageHelper.getDailyQuote();
    final today = DateTime.now().toIso8601String().split('T')[0];

    // 1. Check if we already have today's quote (Production Logic)
    if (savedData != null && savedData['date'] == today) {
      if (mounted) {
        setState(() {
          _displayQuote = savedData['quote'];
          _quoteAuthor = "Stiki Wisdom";
          _quoteAuthor = "Stiki Wisdom";
        });
      }
      _refillCacheIfNeeded(); // Check if we need to top up for tomorrow
      return;
    }

    // 2. Try to get from Cache (INSTANT)
    final cachedQuote = await StorageHelper.popFutureQuote();

    if (cachedQuote != null) {
      await StorageHelper.saveDailyQuote(cachedQuote, today);
      final authors = ["Stiki Wisdom", "Mr. Stiki", "Stiki Intelligence"];

      if (mounted) {
        setState(() {
          _displayQuote = cachedQuote;
          _quoteAuthor = authors[Random().nextInt(authors.length)];
        });
      }
      _refillCacheIfNeeded(); // Top up cache
      return;
    }

    // 3. Cache Miss (First run or empty) - Fallback to Slow Fetch
    try {
      final topics = [
        "Wise life advice",
        "Funny corporate joke",
        "Mindfulness reminder",
        "Motivational quote",
        "Philosophy in one sentence",
      ];
      final topic = topics[Random().nextInt(topics.length)];

      // Fetch ONE for now to show user ASAP
      final quotes = await AiService().fetchQuotes(
        "$topic (max 50 chars)",
        useDeepMode: true,
      );

      // Strict Validation: Length & Filter out API Error messages
      final validQuotes = quotes
          .where(
            (q) =>
                q.length >= 10 &&
                q.length <= 80 &&
                !q.toLowerCase().contains("error") &&
                !q.toLowerCase().contains("unable to") &&
                !q.toLowerCase().contains("connection"),
          )
          .toList();

      String finalQuote;

      if (validQuotes.isNotEmpty) {
        finalQuote = validQuotes.first;
        // If we got extra quotes from this fetch, save them to cache!
        if (validQuotes.length > 1) {
          await StorageHelper.addFutureQuotes(validQuotes.sublist(1));
        }
      } else {
        // FALLBACK: Use offline safe quotes if API failed or returned errors
        final fallbacks = [
          "Believe you can and you're halfway there.",
          "Act as if what you do makes a difference.",
          "Success is not final, failure is not fatal.",
          "You are never too old to set another goal.",
          "Keep your face always toward the sunshine.",
          "The only way to do great work is to love it.",
          "Dream big and dare to fail.",
          "Life is 10% what happens to us and 90% how we react.",
          "Simplification is the ultimate sophistication.",
        ];
        finalQuote = fallbacks[Random().nextInt(fallbacks.length)];
      }

      // Save valid result (or fallback) so we don't retry today
      await StorageHelper.saveDailyQuote(finalQuote, today);

      if (mounted) {
        final authors = ["Stiki Wisdom", "Mr. Stiki", "Stiki Intelligence"];
        setState(() {
          _displayQuote = finalQuote;
          _quoteAuthor = authors[Random().nextInt(authors.length)];
        });
      }

      _refillCacheIfNeeded();
    } catch (e) {
      // Logic failure? Fallback silently to initial default or previous state
    }
  }

  // --- BACKGROUND REFILL (Silent) ---
  Future<void> _refillCacheIfNeeded() async {
    final cache = await StorageHelper.getFutureQuotes();

    if (cache.length >= 3) return; // We have enough

    try {
      // Fetch a BIG BATCH
      final topics = ["Wisdom", "Funny", "Motivation", "Life"];
      final topic = topics[Random().nextInt(topics.length)];

      final quotes = await AiService().fetchQuotes(
        "Mix of $topic quotes (10-50 chars)",
        useDeepMode: true,
      );

      final validQuotes = quotes
          .where((q) => q.length >= 10 && q.length <= 60)
          .toList();

      if (validQuotes.isNotEmpty) {
        await StorageHelper.addFutureQuotes(validQuotes);
      }
    } catch (e) {}
  }

  Future<void> _loadSavedWidgets() async {
    try {
      // 1. Get all widgets saved in app storage
      final saved = await StorageHelper.getQuotes();

      // 2. Get all widgets currently installed on home screen
      final installedWidgets = await HomeWidget.getInstalledWidgets();
      final installedIds = installedWidgets
          .map((w) => w.androidWidgetId.toString())
          .toSet();

      // 3. Find widgets that are in storage but NOT on home screen (orphaned)
      final orphanedWidgets = saved.where((widget) {
        return !installedIds.contains(widget.id);
      }).toList();

      // 4. Clean up: Delete orphaned widgets from storage
      for (var orphan in orphanedWidgets) {
        await StorageHelper.deleteQuote(orphan.id);
      }

      // 5. Reload the cleaned list
      final cleanedWidgets = await StorageHelper.getQuotes();

      if (!mounted) return;
      setState(() {
        mySavedWidgets = cleanedWidgets;
      });
    } catch (e) {
      // Fallback: If sync fails, just show what's in storage (current behavior)
      final saved = await StorageHelper.getQuotes();
      if (!mounted) return;
      setState(() {
        mySavedWidgets = saved;
      });
    }
  }

  // --- FOREGROUND ROTATION CHECK ---
  // Runs when app opens. If WorkManager missed a rotation, this catches it.
  Future<void> _checkAndRotateOverdueWidgets() async {
    try {
      final widgets = await StorageHelper.getQuotes();
      final now = DateTime.now();
      bool anyRotated = false;

      for (var w in widgets) {
        // Skip widgets that don't rotate or have too few quotes
        if (w.frequency == 'none' || w.quotes.length < 2) continue;

        // Determine required interval
        Duration interval;
        if (w.frequency == 'hourly') {
          interval = const Duration(hours: 1);
        } else if (w.frequency == 'daily') {
          interval = const Duration(days: 1);
        } else if (w.frequency == 'weekly') {
          interval = const Duration(days: 7);
        } else {
          continue;
        }

        // Check if overdue
        final timeSinceLastUpdate = now.difference(w.lastUpdated);
        if (timeSinceLastUpdate >= interval) {
          // debugPrint removed

          // Pick a random different quote
          int nextIndex;
          int attempts = 0;
          do {
            nextIndex = Random().nextInt(w.quotes.length);
            attempts++;
          } while (nextIndex == w.currentIndex && attempts < 10);

          final nextQuote = w.quotes[nextIndex];

          // Determine widget colors
          final bgColor = w.backgroundColor != null
              ? Color(w.backgroundColor!)
              : (w.widgetName.contains('Dark')
                    ? AppColors.darkBackground
                    : AppColors.yellowWidget);
          final txtColor = w.textColor != null
              ? Color(w.textColor!)
              : (w.widgetName.contains('Dark')
                    ? AppColors.textLight
                    : AppColors.textPrimary);

          // Update the home screen widget
          await WidgetService().updateStickyWidget(
            text: nextQuote,
            color: bgColor,
            textColor: txtColor,
            androidWidgetName: w.widgetName,
            id: w.id,
          );

          // Save to storage
          await StorageHelper.saveQuote(
            nextQuote,
            id: w.id,
            currentIndex: nextIndex,
            lastUpdated: now,
          );

          anyRotated = true;
        }
      }

      // Refresh the list if any widgets were rotated
      if (anyRotated && mounted) {
        _loadSavedWidgets();
      }
    } catch (e) {}
  }

  // --- BATTERY OPTIMIZATION PROMPT ---
  // Ask user once to disable battery optimization so WorkManager runs reliably
  Future<void> _promptBatteryOptimization() async {
    if (!Platform.isAndroid) return;

    // Only ask once
    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool('battery_opt_asked') ?? false;
    if (alreadyAsked) return;

    // Wait for the UI to settle before showing dialog
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.background,
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('✨', style: TextStyle(fontSize: 32.sp)),
              SizedBox(height: 12.h),
              Text(
                'Stay Fresh',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Allow background activity so your quotes refresh on time.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    const platform = MethodChannel('com.stiki.app/battery');
                    try {
                      await platform.invokeMethod('requestBatteryOptimization');
                    } catch (e) {}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBackground,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Allow',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Not now',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Mark as asked regardless of choice
    await prefs.setBool('battery_opt_asked', true);
  }

  Future<void> _deleteWidget(String id) async {
    HapticHelper.medium();
    await StorageHelper.deleteQuote(id);
    _loadSavedWidgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    AppColors.background.withValues(alpha: 0.8),
                    AppColors.background.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PremiumEntrance(
                      index: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              "Stiki",
                              style: GoogleFonts.poppins(
                                color: AppColors.textPrimary,
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'YOUR DAILY SOUL SPACE',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500,
                              fontFamily: GoogleFonts.inter().fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    PremiumEntrance(
                      index: 1,
                      child: CozyTapScale(
                        onTap: () {},
                        child: QuoteCard(
                          quote: _displayQuote,
                          author: _quoteAuthor,
                          backgroundColor: AppColors.yellowWidget,
                        ),
                      ),
                    ),

                    SizedBox(height: 48.h),

                    // Widget Gallery Slider with "View All" button
                    PremiumEntrance(
                      index: 2,
                      child: WidgetGallerySlider(
                        onStyleSelected: (style) async {
                          // Resolve dynamic colors if needed
                          final Color resolvedCardColor = style.isDynamic
                              ? (style.name == 'dynamic_light'
                                    ? AppColors.dynamicLightWidget
                                    : AppColors.dynamicDarkWidget)
                              : style.backgroundColor;

                          final Color resolvedTextColor = style.isDynamic
                              ? (style.name == 'dynamic_light'
                                    ? AppColors.dynamicLightText
                                    : AppColors.dynamicDarkText)
                              : style.textColor;

                          await Navigator.push(
                            context,
                            PageTransitionHelper.createRoute(
                              WidgetScreen(
                                backgroundColor: AppColors.background,
                                cardColor: resolvedCardColor,
                                textColor: resolvedTextColor,
                                androidWidgetName: style.androidWidgetName,
                              ),
                            ),
                          );
                          _loadSavedWidgets();
                        },
                        onViewAllTap: () async {
                          await Navigator.push(
                            context,
                            PageTransitionHelper.createRoute(
                              WidgetGalleryPage(
                                onStyleSelected: (style) async {
                                  // Resolve dynamic colors if needed
                                  final Color resolvedCardColor =
                                      style.isDynamic
                                      ? (style.name == 'dynamic_light'
                                            ? AppColors.dynamicLightWidget
                                            : AppColors.dynamicDarkWidget)
                                      : style.backgroundColor;

                                  final Color resolvedTextColor =
                                      style.isDynamic
                                      ? (style.name == 'dynamic_light'
                                            ? AppColors.dynamicLightText
                                            : AppColors.dynamicDarkText)
                                      : style.textColor;

                                  // Navigate to widget creation with selected style
                                  await Navigator.pushReplacement(
                                    context,
                                    PageTransitionHelper.createRoute(
                                      WidgetScreen(
                                        backgroundColor: AppColors.background,
                                        cardColor: resolvedCardColor,
                                        textColor: resolvedTextColor,
                                        androidWidgetName:
                                            style.androidWidgetName,
                                      ),
                                    ),
                                  );
                                  _loadSavedWidgets();
                                },
                              ),
                            ),
                          );
                          _loadSavedWidgets();
                        },
                      ),
                    ),

                    SizedBox(height: 48.h),

                    PremiumEntrance(
                      index: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "My Widgets",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    if (mySavedWidgets.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: PremiumEntrance(
                          index: 6,
                          child: Column(
                            children: [
                              const Icon(
                                Icons.dashboard_customize_outlined,
                                size: 48,
                                color: Colors.black12,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No widgets created yet!\nGenerate one to get started.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.black26,
                                  fontSize: 13.sp,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mySavedWidgets.length,
                        itemBuilder: (context, index) {
                          final item = mySavedWidgets[index];

                          return RepaintBoundary(
                            child: PremiumEntrance(
                              index: 6 + index,
                              child: CozyTapScale(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    PageTransitionHelper.createRoute(
                                      WidgetEditScreen(widget: item),
                                    ),
                                  );
                                  _loadSavedWidgets();
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 14.h),
                                  padding: EdgeInsets.all(18.r),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: AppColors.standardShadow,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.quote,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Created ${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13.sp,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteWidget(item.id),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
