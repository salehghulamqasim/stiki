package com.stiki.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class StikiWidgetDark : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.stiki_widget_layout).apply {
                // Open App on Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.note_screenshot, pendingIntent)

                // 1. Try to get mapped internal ID
                val internalId = widgetData.getString("widget_id_$widgetId", null)
                val idToUse = internalId ?: widgetId.toString()
                
                // 2. Get image path
                val imagePath = widgetData.getString("note_screenshot_$idToUse", null)

                if (imagePath != null) {
                    val bitmap = BitmapFactory.decodeFile(imagePath)
                    if (bitmap != null) {
                        setImageViewBitmap(R.id.note_screenshot, bitmap)
                        setViewVisibility(R.id.widget_default_text, View.GONE)
                        setViewVisibility(R.id.note_screenshot, View.VISIBLE)
                    } else {
                        setViewVisibility(R.id.widget_default_text, View.VISIBLE)
                    }
                } else {
                    setViewVisibility(R.id.widget_default_text, View.VISIBLE)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
