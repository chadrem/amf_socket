package amfSocket
{
  import flash.events.Event;

  public class RpcManagerEvent extends Event
  {
    //
    // Constants.
    //

    public static const CONNECTED:String = "RPC_MANAGER_EVENT_CONNECTED";
    public static const DISCONNECTED:String = "RPC_MANAGER_EVENT_DISCONNECTED";
    public static const FAILED:String = "RPC_MANAGER_EVENT_FAILED";

    //
    // Instance variables.
    //

    private var _data:Object;

    //
    // Constructor.
    //

    public function RpcManagerEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
      _data = data;

      super(type, bubbles, cancelable);
    }
  }
}