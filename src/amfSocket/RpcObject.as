package amfSocket
{
  import flash.events.EventDispatcher;

  public class RpcObject extends EventDispatcher
  {
    //
    // Instance variables.
    //

    protected var _messageId:String = null;
    protected var _command:String = null;
    protected var _params:Object = null;
    protected var _state:String = 'initialized'; // Valid states: initialized, delivered, succeeded, failed.

    //
    // Constructor.
    //

    public function RpcObject(command:String, params:Object) {
      super();

      _command = command;
      _params = params;
      _messageId = genMessageId();
    }

    public function toObject():Object {
      throw new Error('You must override toObject() in a subclass.');
    }

    //
    // Getters and setters.
    //

    public function get messageId():String { return _messageId; }
    public function get command():String { return _command; }
    public function get params():Object { return _params; }
    public function get state():String { return _state; }

    public function isInitialized():Boolean {
      return isState('initialized');
    }

    public function isDelivered():Boolean {
      return isState('delivered');
    }

    public function isCompleted():Boolean {
      return isState('completed');
    }

    public function isFailed():Boolean {
      return isState('failed');
    }

    //
    // Protected methods.
    //

    protected function isState(state:String):Boolean {
      if(_state == state)
        return true;
      else
        return false;
    }

    protected function randomInt(begin:int=100000000, end:int=999999999):int {
      var num:int = Math.floor(begin + (Math.random() * (end - begin + 1)));

      return num;
    }

    protected function genMessageId():String {
      var date:Date = new Date();
      var messageId:String = date.getTime().toString() + ':' + randomInt().toString() + ':' + randomInt().toString();

      return messageId;
    }

    //
    // Signals.
    // Even though these are public, they should only be called by the RPC Manager.
    // Your user code should never call them directly.
    //

    public function __signalDelivered__():void {
      if(isInitialized()) {
        _state = 'delivered';
        dispatchEvent(new RpcObjectEvent(RpcObjectEvent.DELIVERED));
      }
      else
        throw new Error("Received 'delivered' signal an already delivered RPC request.");
    }

    public function __signalFailed__(reason:String=null):void {
      if(isDelivered()) {
        _state = 'failed';
        dispatchEvent(new RpcObjectEvent(RpcObjectEvent.FAILED, reason));
      }
      else
        throw new Error("Received 'failed' signal when not in 'delivered' state.");
    }
  }
}