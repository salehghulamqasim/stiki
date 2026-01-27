import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stiki/components/widgets_options2.dart';
import 'package:stiki/models/widget_model.dart';
import 'package:stiki/pages/widget_screen.dart';
import 'package:stiki/components/quote_card.dart';
import 'package:stiki/pages/widget_screens_edit.dart';
import 'package:stiki/utils/haptic_helper.dart';
import 'package:stiki/utils/storage_helper.dart';
import 'dart:async';
import 'dart:math';
import 'package:stiki/services/ai_service.dart';
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
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadSavedWidgets();
    _checkDailyQuote();
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

    debugPrint("🧠 Daily quote needed. Checking cache...");

    // 2. Try to get from Cache (INSTANT)
    final cachedQuote = await StorageHelper.popFutureQuote();

    if (cachedQuote != null) {
      debugPrint("🚀 Cache HIT! Using pre-fetched quote.");
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
    debugPrint("🐢 Cache MISS. Performing live fetch...");
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
        topic + " (max 50 chars)",
        useDeepMode: true,
      );

      // Strict Length Filtering
      final validQuotes = quotes
          .where((q) => q.length >= 10 && q.length <= 60)
          .toList();

      if (validQuotes.isNotEmpty) {
        final quote = validQuotes.first;
        await StorageHelper.saveDailyQuote(quote, today);
        if (mounted) {
          final authors = ["Stiki Wisdom", "Mr. Stiki", "Stiki Intelligence"];
          setState(() {
            _displayQuote = quote;
            _quoteAuthor = authors[Random().nextInt(authors.length)];
          });
        }

        // If we got extra quotes from this fetch, save them to cache!
        if (validQuotes.length > 1) {
          await StorageHelper.addFutureQuotes(validQuotes.sublist(1));
        }
      }

      _refillCacheIfNeeded();
    } catch (e) {
      debugPrint("❌ Failed to fetch daily quote: $e");
    }
  }

  // --- BACKGROUND REFILL (Silent) ---
  Future<void> _refillCacheIfNeeded() async {
    final cache = await StorageHelper.getFutureQuotes();
    debugPrint("📦 Current Cache Size: ${cache.length}");

    if (cache.length >= 3) return; // We have enough

    debugPrint("♻️ Refilling Quote Cache silently...");
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
        debugPrint("✅ Added ${validQuotes.length} quotes to cache!");
      }
    } catch (e) {
      debugPrint("⚠️ Background refill failed: $e");
    }
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
        debugPrint("🧹 Cleaning up deleted widget: ${orphan.id}");
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
      debugPrint("⚠️ Widget sync failed: $e. Showing all saved widgets.");
      final saved = await StorageHelper.getQuotes();
      if (!mounted) return;
      setState(() {
        mySavedWidgets = saved;
      });
    }
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

                    PremiumEntrance(
                      index: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Create New",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: PremiumEntrance(
                            index: 3,
                            child: WidgetOptionCard2(
                              title: 'stiki dark',
                              backgroundColor: AppColors.darkBackground,
                              textColor: AppColors.textLight,
                              circleColor: Colors.white.withValues(alpha: 0.1),
                              iconColor: Colors.white.withValues(alpha: 0.3),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  PageTransitionHelper.createRoute(
                                    const WidgetScreen(
                                      backgroundColor: AppColors.darkBackground,
                                      cardColor: AppColors.darkBackground,
                                      textColor: AppColors.textLight,
                                      androidWidgetName: 'StikiWidgetDark',
                                    ),
                                  ),
                                );
                                _loadSavedWidgets();
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: PremiumEntrance(
                            index: 4,
                            child: WidgetOptionCard2(
                              title: 'stiki light',
                              backgroundColor: AppColors.yellowWidget,
                              circleColor: Colors.black.withValues(alpha: 0.05),
                              iconColor: Colors.black.withValues(alpha: 0.3),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  PageTransitionHelper.createRoute(
                                    const WidgetScreen(
                                      backgroundColor: AppColors.background,
                                      cardColor: AppColors.yellowWidget,
                                      textColor: AppColors.textPrimary,
                                      androidWidgetName: 'StikiWidgetLight',
                                    ),
                                  ),
                                );
                                _loadSavedWidgets();
                              },
                            ),
                          ),
                        ),
                      ],
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
