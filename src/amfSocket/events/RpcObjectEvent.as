package amfSocket.events {
import flash.events.Event;

public class RpcObjectEvent extends Event {
  //
  // Constants.
  //

  public static const DELIVERED:String = 'RPC_OBJECT_EVENT_DELIVERED';
  public static const SUCCEEDED:String = 'RPC_OBJECT_EVENT_SUCCEEDED';
  public static const FAILED:String = 'RPC_OBJECT_EVENT_FAILED';

  //
  // Instance variables.
  //

  private var _data:Object;

  //
  // Constructor.
  //

  public function RpcObjectEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
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