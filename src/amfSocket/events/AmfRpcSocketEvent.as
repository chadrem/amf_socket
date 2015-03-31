package amfSocket.events {
import flash.events.Event;

public class AmfRpcSocketEvent extends Event {
  //
  // Constants.
  //

  public static const CONNECTED:String = 'AMF_RPC_SOCKET_EVENT_CONNECTED';
  public static const DISCONNECTED:String = 'AMF_RPC_SOCKET_EVENT_DISCONNECTED';
  public static const FAILED:String = 'AMF_RPC_SOCKET_EVENT_FAILED';
  public static const RECEIVED_REQUEST:String = 'AMF_RPC_SOCKET_RECEIVED_REQUEST';
  public static const RECEIVED_MESSAGE:String = 'AMF_RPC_SOCKET_RECEIVED_MESSAGE';
  public static const RECEIVED_PING:String = 'AMF_RPC_SOCKET_RECEIVED_PING';

  //
  // Instance variables.
  //

  private var _data:Object;

  //
  // Constructor.
  //

  public function AmfRpcSocketEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
    _data = data;

    super(type, bubbles, cancelable);
  }

  //
  // Getters and setters.
  //

  public function get data():Object {
    return _data;
  }
}
}