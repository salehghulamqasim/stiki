package com.stiki.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import android.net.Uri

class StikiWidgetDark : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.stiki_widget_layout).apply {
                // Open App on Click with widget ID
                val uri = Uri.parse("stiki://widget/$widgetId")
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, uri)
                setOnClickPendingIntent(R.id.native_text_container, pendingIntent)

                // Get internal ID mapping
                val internalId = widgetData.getString("widget_id_$widgetId", null)
                val idToUse = internalId ?: widgetId.toString()

                // Get quote text
                val quoteText = widgetData.getString("widget_text_$idToUse", null)

                // Get background color (default to dark)
                val bgColorHex = widgetData.getString("widget_bg_color_$idToUse", "#221A16")
                val textColorHex = widgetData.getString("widget_text_color_$idToUse", "#FFFFFF")

                if (quoteText != null) {
                    // Use native auto-sizing text
                    setViewVisibility(R.id.native_text_container, View.VISIBLE)
                    setViewVisibility(R.id.note_screenshot, View.GONE)
                    setViewVisibility(R.id.widget_default_text, View.GONE)

                    // Set text
                    setTextViewText(R.id.widget_text, quoteText)

                    // Dynamic font size based on quote length
                    setTextViewTextSize(R.id.widget_text, android.util.TypedValue.COMPLEX_UNIT_SP, getTextSizeForLength(quoteText.length))

                    // Set text color
                    try {
                        setTextColor(R.id.widget_text, Color.parseColor(textColorHex))
                    } catch (e: Exception) {
                        setTextColor(R.id.widget_text, Color.WHITE)
                    }

                    // Set background color
                    // Set background color via tint on image
                    try {
                        setInt(R.id.widget_bg_image, "setColorFilter", Color.parseColor(bgColorHex))
                    } catch (e: Exception) {
                        // Fallback
                    }
                } else {
                    // Show setup prompt with dark theme
                    setViewVisibility(R.id.native_text_container, View.VISIBLE)
                    setViewVisibility(R.id.note_screenshot, View.GONE)
                    setViewVisibility(R.id.widget_default_text, View.GONE)
                    setTextViewText(R.id.widget_text, "Tap to setup")
                    setTextColor(R.id.widget_text, Color.WHITE)
                    setInt(R.id.widget_bg_image, "setColorFilter", Color.parseColor("#221A16"))
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun getTextSizeForLength(length: Int): Float {
        return when {
            length <= 20  -> 32f
            length <= 50  -> 26f
            length <= 100 -> 20f
            length <= 150 -> 16f
            else          -> 14f
        }
    }
}
