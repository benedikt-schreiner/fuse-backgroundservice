package com.fuse.BackgroundService;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.ResultReceiver;
import android.widget.Toast;



public class ServiceClass extends Service {

    // Global Variable Declaration
    private ResultReceiver resultReceiver;
    Context cont;
    public static final String RECEIVER = "AndroidServiceReceiver";
    SharedPreferences sharedpref;
  //  Alarm alarm = new Alarm();


    // Example Variable Declaration
    boolean run = true;
    int msg_global = 0;

    

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        
        try {
            resultReceiver = intent.getParcelableExtra(RECEIVER);
            if (intent !=null && intent.getExtras()!=null) {
                String value = intent.getExtras().getString("amount");
                msg_global = Integer.parseInt(value);
            }
        } catch(Exception e) {

        }
        cont = this;
        sharedpref = cont.getSharedPreferences(RECEIVER, Context.MODE_PRIVATE);
        final SharedPreferences.Editor edit = sharedpref.edit();





        // PUT HERE ALL YOUR LONG RUNNING JAVA CODE! Like so...

        // Example Start
        Toast.makeText(this,"Now start eating the toasts!", Toast.LENGTH_SHORT).show();
        final Handler handler = new Handler();
        final Runnable r = new Runnable() {
            public void run() {

                msg_global = sharedpref.getInt("zwsp", msg_global);
                if(msg_global > 0) {
                    Toast.makeText(cont, msg_global + " toasts left yummy... *nomnomnom*", Toast.LENGTH_SHORT).show();
                    msg_global--;
                    edit.putInt("zwsp", msg_global);
                    edit.commit();
                } else {
                    try {
                        Bundle result = new Bundle();
                        result.putString("result", "Youre done with all toasts! :) PS this comes from inside the Service");
                        resultReceiver.send(100, result);
                        edit.remove("zwsp");
                        edit.commit();
                        run = false;
                    } catch (Exception e) {

                    }
                }
                if(run) {
                    handler.postDelayed(this, 3000);
                }
            }
        };
        if(run)
        handler.postDelayed(r, 1000);
        // Example End






        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        run = false;
        Toast.makeText(cont,"STOP!", Toast.LENGTH_SHORT).show();
    }


    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }


}
/*
class Alarm extends BroadcastReceiver
{
    @Override
    public void onReceive(Context context, Intent intent)
    {
        PowerManager pm = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
        PowerManager.WakeLock wl = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "");
        wl.acquire();

        // Put here YOUR code.

        Toast.makeText(context,"...and again", Toast.LENGTH_SHORT).show();

        Toast.makeText(context, "Alarm !!!!!!!!!!", Toast.LENGTH_LONG).show(); // For example

        wl.release();
    }

    public void setAlarm(Context context)
    {
        AlarmManager am =( AlarmManager)context.getSystemService(Context.ALARM_SERVICE);
        Intent i = new Intent(context, Alarm.class);
        PendingIntent pi = PendingIntent.getBroadcast(context, 0, i, 0);
        am.setRepeating(AlarmManager.RTC_WAKEUP, System.currentTimeMillis(), 5000, pi); // Millisec * Second * Minute
    }

    public void cancelAlarm(Context context)
    {
        Intent intent = new Intent(context, Alarm.class);
        PendingIntent sender = PendingIntent.getBroadcast(context, 0, intent, 0);
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        alarmManager.cancel(sender);
    }
}
*/