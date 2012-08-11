package amfSocket
{
  import flash.events.EventDispatcher;
  import flash.sampler.getSetterInvocationCount;

  public class RpcRequest extends EventDispatcher
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private var _messageId:String = null;
    private var _manager:RpcManager = null;
    private var _command:String = null;
    private var _params:Object = null;
    private var _state:String = 'initialized' // Valid states: initialized, delivered, succeeded, failed.
    private var _rpcManager:RpcManager = null;

    //
    // Constructor.
    //

    public function RpcRequest(command:String, params:Object) {
      super();

      _command = command;
      _params = params;
      _messageId = genMessageId();
    }

    //
    // Getters and setters.
    //

    public function get messageId():String { return _messageId; }
    public function get command():String { return _command; }
    public function get params():Object { return _params; }
    public function get state():String { return _state; }

    //
    // Public methods.
    //

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
    // Signals.
    // Even though these are public, it should only be called by the RPC Manager.
    // Your user code should never call them directly.
    //

    public function __signalDelivered__():void {
      if(isInitialized())
        _state = 'delivered'
      else
        throw new Error("Received 'delivered' signal an already delivered RPC request.");
    }

    public function __signalSucceeded__(object:Object):void {
      if(isDelivered()) {
        _state = 'succeeded';
        dispatchEvent(new RpcRequestEvent(RpcRequestEvent.SUCCEEDED, object));
      }
      else
        throw new Error("Received 'succeeded' signal when not in 'delivered' state.");
    }

    public function __signalFailed__(reason:String=null):void {
      if(isDelivered()) {
        _state = 'failed';
        dispatchEvent(new RpcRequestEvent(RpcRequestEvent.FAILED, reason));
      }
      else
        throw new Error("Received 'failed' signal when not in 'delivered' state.");
    }

    //
    // Private methods.
    //

    private function isState(state:String):Boolean {
      if(_state == state)
        return true;
      else
        return false;
    }

    private function randomInt(begin:int=100000000, end:int=999999999):int {
      var num:int = Math.floor(begin + (Math.random() * (end - begin + 1)));

      return num;
    }

    private function genMessageId():String {
      var date:Date = new Date();
      var messageId:String = date.getTime().toString() + ':' + randomInt().toString() + ':' + randomInt().toString();

      return messageId;
    }
  }
}
