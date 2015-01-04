package amfSocket {
public class RpcReceivedRequest extends RpcReceivedObject {
  //
  // Instance variables.
  //

  private var _state:String = 'initialized' // Valid states: initialized, responded.

  //
  // Constructor.
  //

  public function RpcReceivedRequest(receivedObject:Object) {
    super(receivedObject);
  }

  //
  // Getters and setters.
  //

  public function get state():String {
    return _state;
  }

  //
  // Public methods.
  //

  public function isInitialized():Boolean {
    return isState('initialized');
  }

  public function isResponded():Boolean {
    return isState('responded');
  }

  //
  // Protected methods.
  //

  protected override function fromObject(object:Object):void {
    _messageId = object.request.messageId;
    _command = object.request.command;
    _params = object.request.params;
  }

  //
  // Private methods.
  //

  private function isState(state:String):Boolean {
    if (_state == state)
      return true;
    else
      return false;
  }

  //
  // Signals.
  // Even though these are public, they should only be called by the RPC Manager.
  // Your user code should never call them directly.
  //

  public function __signalResponded__():void {
    _state = 'responded';
  }
}
}