package amfSocket
{
  public class RpcReceivedMessage extends RpcReceivedObject
  {
    //
    // Constructor.
    //

    public function RpcReceivedMessage(receivedObject:Object) {
      super(receivedObject);
    }

    //
    // Protected methods.
    //

    protected override function fromObject(object:Object):void {
     _messageId = object.message.messageId;
     _command = object.message.command;
     _params = object.message.params;
    }
  }
}