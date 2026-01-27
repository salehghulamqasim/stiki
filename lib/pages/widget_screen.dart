import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stiki/animations/stiki_animations.dart';
import 'package:stiki/components/generator_widget.dart';
import 'package:stiki/services/ai_service.dart';
import 'package:stiki/services/widget_service.dart';
import 'package:stiki/theme/app_colors.dart';
import 'package:stiki/utils/haptic_helper.dart';
import 'package:stiki/utils/storage_helper.dart';

import 'package:stiki/components/report_dialog.dart';
import 'package:stiki/components/note_card.dart';

class WidgetScreen extends StatefulWidget {
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final String androidWidgetName;
  final String? existingQuote;
  final String? existingId;
  final String? selectedFrequency;
  final bool useDeepMode;
  const WidgetScreen({
    super.key,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.androidWidgetName,
    this.existingQuote,
    this.existingId,
    this.selectedFrequency,
    this.useDeepMode = false,
  });

  @override
  State<WidgetScreen> createState() => _WidgetScreenState();
}

class _WidgetScreenState extends State<WidgetScreen> {
  late TextEditingController _controller;
  List<String> generatedQuotes = [];
  bool loadingQuotes = false;
  String _currentFrequency = 'daily';
  bool _useDeepMode = false; // disabled by default

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existingQuote);

    _currentFrequency = widget.selectedFrequency ?? 'daily';
  }

  Future<void> _handleWidgetSave(String quote, String widgetId) async {
    // Save to Flutter storage
    await StorageHelper.saveQuote(
      quote,
      id: widgetId,
      quotes: generatedQuotes,
      topic: _controller.text.trim(),
      frequency: _currentFrequency,
      widgetName: widget.androidWidgetName,
    );

    // Save to HomeWidget storage
    await HomeWidget.saveWidgetData('note_screenshot_$widgetId', quote);
    await HomeWidget.saveWidgetData('widget_id_$widgetId', widgetId);

    // Render the widget image
    await HomeWidget.renderFlutterWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.transparent,
          child: NoteCard(
            text: quote,
            color: widget.cardColor,
            textColor: widget.textColor,
          ),
        ),
      ),
      key: 'note_screenshot_$widgetId',
      logicalSize: const Size(200, 200),
    );

    // Update the widget
    await HomeWidget.updateWidget(
      name: widget.androidWidgetName,
      androidName: widget.androidWidgetName,
    );

    if (!mounted) return;
    final navigator = Navigator.of(context);
    navigator.pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PremiumEntrance(
                      index: 0,
                      child: CozyTapScale(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    PremiumEntrance(
                      index: 1,
                      child: Text(
                        "Ai Quote Generator",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PremiumEntrance(
                      index: 2,
                      child: GeneratorWidget(
                        quote: "AI generator textfield",
                        backgroundColor: widget.cardColor,
                        frequency: _currentFrequency, //current state
                        onFrequencyChanged: (newFreq) {
                          setState(() {
                            _currentFrequency = newFreq;
                          });
                        },
                        onDeepModeChanged: (newMode) {
                          setState(() {
                            _useDeepMode = newMode;
                          });
                        },
                        isDeepMode: _useDeepMode,
                        isLoading: loadingQuotes, //load while laoding quotes

                        onTap: () async {
                          if (_controller.text.isEmpty) return;

                          // Capture context-dependent objects before async gap
                          final messenger = ScaffoldMessenger.of(context);

                          // Dismiss keyboard
                          FocusManager.instance.primaryFocus?.unfocus();

                          setState(() {
                            loadingQuotes = true;
                            generatedQuotes = []; // Clear previous results
                          });

                          try {
                            // final result = await AiService().fetchQuotes(
                            //   _controller.text.trim(),
                            // );
                            final result = await AiService().fetchQuotes(
                              _controller.text.trim(),
                              useDeepMode: _useDeepMode, // Add this parameter
                            );
                            if (!mounted) return;
                            setState(() {
                              generatedQuotes = result;
                            });
                          } catch (e) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                loadingQuotes = false;
                              });
                            }
                          }
                        },
                        controller: _controller,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Helper Guide - Simplified
                    if (!loadingQuotes && generatedQuotes.isEmpty)
                      PremiumEntrance(
                        index: 3,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Topic suggestions
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    size: 14,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Try: motivation, funny jokes or book quotes',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Deep mode
                              Row(
                                children: [
                                  Icon(
                                    Icons.psychology_outlined,
                                    size: 14,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Deep Mode: thoughtful quotes, takes longer',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Frequency
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_outlined,
                                    size: 14,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Quotes refresh: hourly, daily, or weekly',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Disclaimer
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 13,
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'AI-generated • May Not Be Perfect',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),

                    // Results Section
                    // Placeholder loading state
                    if (loadingQuotes)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Shimmer.fromColors(
                          baseColor: Colors.black.withValues(alpha: 0.05),
                          highlightColor: Colors.black.withValues(alpha: 0.01),
                          child: Column(
                            children: List.generate(
                              3,
                              (index) => Container(
                                height: 100,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (generatedQuotes.isNotEmpty) ...[
                      PremiumEntrance(
                        index: 3,
                        child: Text(
                          "Choose Your Favorite",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        key: ValueKey(
                          generatedQuotes.length +
                              (generatedQuotes.isNotEmpty
                                  ? generatedQuotes.first.hashCode
                                  : 0),
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: generatedQuotes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return RepaintBoundary(
                            child: PremiumEntrance(
                              index: 4 + index,
                              duration: const Duration(milliseconds: 1000),
                              delay: const Duration(milliseconds: 300),
                              slideOffset: const Offset(-15, 10),
                              enableHaptic: true,
                              child: CozyTapScale(
                                onTap: () async {
                                  // HapticFeedback.mediumImpact();
                                  HapticHelper.medium();
                                  final quote = generatedQuotes[index];

                                  // Capture context-dependent objects before any async gap
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );

                                  // 1. iOS / Fallback Handling
                                  // iOS doesn't support programmatic pinning. We just save the data.
                                  if (Platform.isIOS) {
                                    final simpleId = DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString();
                                    await _handleWidgetSave(quote, simpleId);
                                    return;
                                  }

                                  // 2. Android Pinning Flow
                                  // Get baseline of existing widgets
                                  final baselineWidgets =
                                      await HomeWidget.getInstalledWidgets();
                                  final baselineIds = baselineWidgets
                                      .map((w) => w.androidWidgetId)
                                      .toSet();

                                  // Request the pin
                                  await WidgetService().requestWidgetPinning(
                                    widget.androidWidgetName,
                                  );

                                  // Find the NEW widget ID
                                  String? widgetId;

                                  // Polling loop (10 seconds)
                                  for (
                                    int attempt = 0;
                                    attempt < 10;
                                    attempt++
                                  ) {
                                    await Future.delayed(
                                      const Duration(milliseconds: 1000),
                                    );

                                    final currentWidgets =
                                        await HomeWidget.getInstalledWidgets();

                                    try {
                                      final newWidget = currentWidgets
                                          .firstWhere(
                                            (w) => !baselineIds.contains(
                                              w.androidWidgetId,
                                            ),
                                          );
                                      widgetId = newWidget.androidWidgetId
                                          .toString();
                                      debugPrint(
                                        "✨ Discovered NEW widget ID: $widgetId",
                                      );
                                      break;
                                    } catch (_) {
                                      // Continue waiting
                                    }
                                  }

                                  if (widgetId == null) {
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Widget not detected. Try adding it manually?",
                                        ),
                                      ),
                                    );
                                    // Optional logic: Save efficiently anyways for manual add
                                    // But for independent widgets, we usually need the ID.
                                    // We'll just return to let user try again.
                                    return;
                                  }

                                  // 3. Save with the discovered ID
                                  await _handleWidgetSave(quote, widgetId);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: AppColors.standardShadow,
                                  ),
                                  child: Row(
                                    children: [
                                      // Subtle Number Indicator
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: AppColors.darkBackground
                                              .withValues(alpha: 0.05),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${index + 1}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary
                                                  .withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          generatedQuotes[index],
                                          style: GoogleFonts.merriweather(
                                            fontSize: 14,
                                            height: 1.5,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      CozyTapScale(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => ReportDialog(
                                              quote: generatedQuotes[index],
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          Icons.outlined_flag,
                                          size: 20,
                                          color: AppColors.textPrimary
                                              .withValues(alpha: 0.15),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 20,
                                        color: AppColors.textPrimary.withValues(
                                          alpha: 0.15,
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
                    ],
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
