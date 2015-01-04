package amfSocket {
public class RpcReceivedObject {
  //
  // Instance variables.
  //

  protected var _messageId:String = null;
  protected var _command:String = null;
  protected var _params:Object = null;

  //
  // Constructor.
  //

  public function RpcReceivedObject(object:Object) {
    super();
    fromObject(object);
  }

  //
  // Getters and setters.
  //

  public function get messageId():String {
    return _messageId;
  }

  public function get command():String {
    return _command;
  }

  public function get params():Object {
    return _params;
  }

  //
  // Protected methods.
  //

  protected function fromObject(object:Object):void {
    throw new Error('You must override this method in a subclass');
  }
}
}