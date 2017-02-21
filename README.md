# fuse-backgroundservice

In this repo you find a library for managing background services in Fuse Android.

With that you can make fuse apps running in background for long running tasks, even when the app is completely killed.
Its a perfect solution if you want to do things permanently in frequent time intervals. Think about sending data frequently to a server. Also useful when
a special sensor event occurs, or if you dont want that a download breaks off.

It runs on a separate process, which makes it independent from any runtime happenings.

### Support
* Android

Unfortunately it currently only works on live devices or the Android preview. No support for pc preview or iOS.


## How to use

Most things have to be done inside foreign code and Uno.

### Uno and Java

You can add your own written Java Code inside the `onStartCommand` method of the `ServiceClass.java`. Currently there is a small
example, how that could look like.

You can pass data from JavaScript to Uno and from Uno to the Service. You can pass all through the `intent.putExtra()` like so
#### Service.uno
```javascript
    [Foreign(Language.Java)]
    extern(Android) void StartServiceJ(string arg)
    @{
        if(!@{Service_status:Get()}) {
           Context context = com.fuse.Activity.getRootActivity();
           Intent intent = new Intent(context, ServiceClass.class);
           intent.putExtra("amount", arg);
           @{Service:Of(_this).SetReceiver(Java.Object):Call(intent)};
           ...
```
and receive it via `intent.getExtras()` inside the Service
#### ServiceClass.java
```javascript
    try {
            resultReceiver = intent.getParcelableExtra(RECEIVER);
            if (intent !=null && intent.getExtras()!=null) {
                String value = intent.getExtras().getString("amount");
                msg_global = Integer.parseInt(value);
            }
        } catch(Exception e) {
        ...
 ```
 
If the Service is supposed to deliver back an event or some kind of result, you can easily create a new Bundle and put that
back by using the `ResultReceiver`-object this way
#### ServiceClass.java
```javascript
    ...
    } else {
            try {
                Bundle result = new Bundle();
                result.putString("result", "Youre done with all toasts! :) PS this comes from inside the Service");
                resultReceiver.send(100, result);
                ...
```
This throws the event on the Uno side
#### Service.uno
```javascript
        ...
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
 ```
 Very easy stuff :)
 
 Inside the `ServiceClass.java` you can control the service type with the return value of
 the `onStartCommand` method.
 * Long running tasks have a return value of `START_STICKY` which is currently the case. The process runs as long until the
 user manually decides to terminate it.
 
 * If you want the service to be terminated after the work is done you should give back `START_NOT_STICKY`.
 
Please have a look to the official Android Docs for more information...
 
### JavaScript
 
Of course you can manage the complete Service appearance from JavaScript, where you can bind it into the UX part.

```javascript
<JavaScript>
        var Service = require("Service");
        var Observable = require("FuseJS/Observable");

        var textinput = Observable("");
        var textoutput = Observable("");


        function startservice() {
            Service.start(textinput.value);
        }

        function stopservice() {
            Service.stop();
        }

        Service.on("onServiceChanged", function(arg) {
            textoutput.value = arg;
        });

        module.exports = {
            startservice : startservice,
            stopservice : stopservice,
            textinput : textinput,
            textoutput : textoutput
        };
    </JavaScript>
```

## To Do's

* Add support to inject data while the service is running
* Support for iOS
