package amfSocket
{
  import flash.events.Event;

  public class AmfSocketEvent extends Event
  {
    //
    // Constants.
    //

    public static const CONNECTED:String = "AMF_SOCKET_EVENT_CONNECTED";
    public static const DISCONNECTED:String = "AMF_SOCKET_EVENT_DISCONNECTED";
    public static const IO_ERROR:String = "AMF_SOCKET_EVENT_IO_ERROR";
    public static const SECURITY_ERROR:String = "AMF_SOCKET_EVENT_SECURITY_ERROR";
    public static const RECEIVED_OBJECT:String = "AMF_SOCKET_EVENT_RECEIVED_OBJECT";

    //
    // Instance variables.
    //

    private var _data:Object;

    //
    // Constructor.
    //

    public function AmfSocketEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
      _data = data;

      super(type, bubbles, cancelable);
    }
  }
}
