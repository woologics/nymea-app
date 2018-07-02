package io.guh.nymeaapp;

import android.app.Notification;
import android.app.NotificationManager;
import android.content.Context;

public class NotificationClient extends org.qtproject.qt5.android.bindings.QtActivity
{
    private static NotificationManager m_notificationManager;
    private static Notification.Builder m_builder;
    private static NotificationClient m_instance;

    public NotificationClient()
    {
        m_instance = this;
    }

    public static void notify(String s)
    {
        if (m_notificationManager == null) {
            m_notificationManager = (NotificationManager)m_instance.getSystemService(Context.NOTIFICATION_SERVICE);
            m_builder = new Notification.Builder(m_instance);
            m_builder.setSmallIcon(R.drawable.icon);
            m_builder.setContentTitle("ContentTitle");
        }

        action = new Notification.Action(R.drawable.icon, "actiontext");
        m_builder.addAction(action);
        m_builder.setContentText(s);
        m_builder.setSubText("subText");
        Notification notification = m_builder.getNotification();
        notification.tickerText="blabla";
        notification.icon=R.drawable.lights_off;
        m_notificationManager.notify(1, notification);
    }
}

