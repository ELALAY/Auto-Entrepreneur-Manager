package com.example.auto_entrepreneur_manager

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class DashboardPeekWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.dashboard_peek_widget)
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                LAUNCH_URI,
            )
            views.setOnClickPendingIntent(R.id.dash_peek_root, pendingIntent)

            views.setTextViewText(
                R.id.dash_peek_title,
                widgetData.getString("dash_peek_title", null)
                    ?: context.getString(R.string.widget_dashboard_peek_placeholder_title),
            )
            views.setTextViewText(
                R.id.dash_peek_body,
                widgetData.getString("dash_peek_body", null)
                    ?: context.getString(R.string.widget_dashboard_peek_placeholder_body),
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    companion object {
        private val LAUNCH_URI: Uri = Uri.parse("autoentinvoice://dashboard/")
    }
}
