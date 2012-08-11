package amfSocket
{
  public class RpcRequest extends RpcObject
  {
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
    // Signals.
    //

    public function __signalSucceeded__(object:Object):void {
      if(isDelivered()) {
        _state = 'succeeded';
        dispatchEvent(new RpcObjectEvent(RpcObjectEvent.SUCCEEDED, object));
      }
      else
        throw new Error("Received 'succeeded' signal when not in 'delivered' state.");
    }
  }
}
