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

class StikiWidgetLight : HomeWidgetProvider() {
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

                // Get background color (default to honey yellow)
                val bgColorHex = widgetData.getString("widget_bg_color_$idToUse", "#FFF1A8")
                val textColorHex = widgetData.getString("widget_text_color_$idToUse", "#221A16")

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
                        setTextColor(R.id.widget_text, Color.parseColor("#221A16"))
                    }

                    // Set background color via tint
                    // Set background color via tint on the image (preserves rounded corners)
                    try {
                        setInt(R.id.widget_bg_image, "setColorFilter", Color.parseColor(bgColorHex))
                    } catch (e: Exception) {
                        // Fallback
                    }
                } else {
                    // Show setup prompt
                    setViewVisibility(R.id.native_text_container, View.VISIBLE)
                    setViewVisibility(R.id.widget_bg_image, View.VISIBLE)
                    setViewVisibility(R.id.note_screenshot, View.GONE)
                    setViewVisibility(R.id.widget_default_text, View.GONE)
                    setTextViewText(R.id.widget_text, "Tap to setup")
                    try {
                        setInt(R.id.widget_bg_image, "setColorFilter", Color.parseColor("#FFF1A8"))
                    } catch (e: Exception) {}
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
