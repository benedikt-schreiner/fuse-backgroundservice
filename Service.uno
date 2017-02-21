using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.UX;
using Uno;
using Uno.Compiler.ExportTargetInterop;


[extern(Android) Require("AndroidManifest.ApplicationElement", "<service android:name=\"com.fuse.BackgroundService.ServiceClass\" android:enabled=\"true\" android:process=\":backgProc\" />")]
[extern(Android) ForeignInclude(Language.Java, 
    "android.content.Intent", 
    "android.content.Context", 
    "android.os.Bundle",
    "android.content.SharedPreferences",
    "android.os.Handler",
    "android.os.ResultReceiver",
    "com.fuse.BackgroundService.ServiceClass")]
[UXGlobalModule]
public class Service : NativeEventEmitterModule
{ 
    static readonly Service _instance;

    public static extern(Android) Java.Object Handler;
    public static extern(Android) Java.Object SharedPref;
    public static bool Service_status;

    public Service() : base(true, "onServiceChanged")
    { 
        if(_instance != null) {
            return;
        } else {
            _instance = this;
            if defined(Android) Init();
        }
        Resource.SetGlobalKey(_instance, "Service");
        AddMember(new NativeFunction("start", (NativeCallback)StartService));
        AddMember(new NativeFunction("stop", (NativeCallback)StopService));
        
    }

    
    object StartService(Context c, object[] args)
    {
        if defined(Android) StartServiceJ((string) args[0]);
        return null;
    }

    object StopService(Context c, object[] args)
    {
        if defined(Android) StopServiceJ();
        return null;
    }

    [Foreign(Language.Java)]
    extern(Android) void Init()
    @{
        Context context = com.fuse.Activity.getRootActivity();
        @{Handler:Set(new Handler())};
        @{SharedPref:Set(context.getSharedPreferences(ServiceClass.RECEIVER, Context.MODE_PRIVATE))};
        SharedPreferences pref = (SharedPreferences) @{SharedPref:Get()};
        if(pref.getBoolean("started", false)) {
            @{Service_status:Set(true)};
            
            Intent intent = new Intent(context, ServiceClass.class);
            @{Service:Of(_this).SetReceiver(Java.Object):Call(intent)};
        }
    @}
    
    [Foreign(Language.Java)]
    extern(Android) void StartServiceJ(string arg)
    @{
        if(!@{Service_status:Get()}) {
           Context context = com.fuse.Activity.getRootActivity();
           Intent intent = new Intent(context, ServiceClass.class);
           intent.putExtra("amount", arg);
           @{Service:Of(_this).SetReceiver(Java.Object):Call(intent)};
           context.startService(intent);
           @{Service:Of(_this).SetServiceState(bool):Call(true)};
           android.util.Log.d("BackgService", "Service started");
        } else {
            android.util.Log.d("BackgService", "Service already started");
        }
    @}

    
    [Foreign(Language.Java)]
    extern(Android) void StopServiceJ()
    @{
        if(@{Service_status:Get()}) {
           Context context = com.fuse.Activity.getRootActivity();
            context.stopService(new Intent(context, ServiceClass.class));
            @{Service:Of(_this).SetServiceState(bool):Call(false)};
            android.util.Log.d("BackgService", "Service stopped");
        } else {
            android.util.Log.d("BackgService", "Service already stopped");
        }
    @}

    [Foreign(Language.Java)]
    extern(Android) void SetReceiver(Java.Object arg_intent)
    @{
        Context context = com.fuse.Activity.getRootActivity();
        Intent intent = (Intent) arg_intent;
        intent.putExtra("AndroidServiceReceiver", new ResultReceiver((Handler) @{Handler:Get()}) {
            @Override
            protected void onReceiveResult(int code, Bundle data) {
                if(code == 100)
                @{Service:Of(_this).UpdateView(string):Call(data.getString("result"))};
            }
        });
        context.startService(intent);
    @}


    void UpdateView(string args) {
        Emit("onServiceChanged", args);
    }

    [Foreign(Language.Java)]
    extern(Android) void SetServiceState(bool arg)
    @{
        SharedPreferences pref = (SharedPreferences) @{SharedPref:Get()};
        final SharedPreferences.Editor edit = pref.edit();
        edit.putBoolean("started", arg);
        edit.commit();
        @{Service_status:Set(arg)};
    @}

    
}