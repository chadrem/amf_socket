package amfSocket
{
  import flash.events.Event;

  public class RpcRequestEvent extends Event
  {
    //
    // Constants.
    //

    public static const SUCCEEDED:String = 'RPC_REQUEST_EVENT_SUCCEEDED';
    public static const FAILED:String = 'RPC_REQUEST_EVENT_FAILED';

    //
    // Instance variables.
    //

    private var _data:Object;

    //
    // Constructors.
    //

    public function RpcRequestEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
      _data = data;

      super(type, bubbles, cancelable);
    }

    //
    // Getters and setters.
    //
  }
}