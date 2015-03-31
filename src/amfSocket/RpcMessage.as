package amfSocket {
public class RpcMessage extends RpcObject {
  //
  // Constructor.
  //

  public function RpcMessage(command:String, params:Object) {
    super(command, params);
  }

  public override function toObject():Object {
    var object:Object = {};

    object.type = 'rpcMessage';
    object.message = {};
    object.message.command = command;
    object.message.params = params;
    object.message.messageId = messageId;

    return object;
  }
}
}