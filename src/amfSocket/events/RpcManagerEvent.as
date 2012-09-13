package amfSocket.events
{
  import flash.events.Event;

  public class RpcManagerEvent extends Event
  {
    //
    // Constants.
    //

    public static const CONNECTED:String = 'RPC_MANAGER_EVENT_CONNECTED';
    public static const DISCONNECTED:String = 'RPC_MANAGER_EVENT_DISCONNECTED';
    public static const FAILED:String = 'RPC_MANAGER_EVENT_FAILED';
    public static const RECEIVED_REQUEST:String = 'RPC_MANAGER_RECEIVED_REQUEST';
    public static const RECEIVED_MESSAGE:String = 'RPC_MANAGER_RECEIVED_MESSAGE';
    public static const RECEIVED_PING:String = 'RPC_MANAGER_RECEIVED_PING';

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

    //
    // Getters and setters.
    //

    public function get data():Object { return _data; }
  }
}