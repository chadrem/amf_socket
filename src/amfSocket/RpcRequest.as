package amfSocket {
import amfSocket.events.RpcObjectEvent;

public class RpcRequest extends RpcObject {
  //
  // Instance variables.
  //

  private var _onSucceeded:Function = null;

  //
  // Constructor.
  //

  public function RpcRequest(command:String, params:Object) {
    super(command, params);
  }

  public override function toObject():Object {
    var object:Object = {}

    object.type = 'rpcRequest';
    object.request = {};
    object.request.command = command;
    object.request.params = params;
    object.request.messageId = messageId;

    return object;
  }

  //
  // Getters and setters.
  //

  public function set onSucceeded(value:Function):void {
    _onSucceeded = value;
  }

  //
  // Signals.
  // Even though these are public, they should only be called by the RPC Manager.
  // Your user code should never call them directly.
  //

  public function __signalSucceeded__(object:Object):void {
    if (isDelivered()) {
      state = 'succeeded';
      if (_onSucceeded)
        _onSucceeded(object);
      dispatchEvent(new RpcObjectEvent(RpcObjectEvent.SUCCEEDED, object));
    }
    else
      throw new Error("Received 'succeeded' signal when not in 'delivered' state.");
  }
}
}
