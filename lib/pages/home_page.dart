import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stiki/components/widgets_options2.dart';
import 'package:stiki/models/widget_model.dart';
import 'package:stiki/pages/widget_screen.dart';
import 'package:stiki/components/quote_card.dart';
import 'package:stiki/pages/widget_screens_edit.dart';
import 'package:stiki/utils/storage_helper.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSavedWidgets();
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
    HapticFeedback.mediumImpact();
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
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
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'YOUR DAILY SOUL SPACE',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500,
                              fontFamily: GoogleFonts.inter().fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    PremiumEntrance(
                      index: 1,
                      child: CozyTapScale(
                        onTap: () {},
                        child: const QuoteCard(
                          quote:
                              "The best way to predict the future is to create it.",
                          author: "Peter Drucker",
                          backgroundColor: AppColors.yellowWidget,
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    PremiumEntrance(
                      index: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Create New",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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
                        const SizedBox(width: 16),
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

                    const SizedBox(height: 48),

                    PremiumEntrance(
                      index: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "My Widgets",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (mySavedWidgets.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
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
                                  fontSize: 13,
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
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(20),
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
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Created ${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
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
                    const SizedBox(height: 32),
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
