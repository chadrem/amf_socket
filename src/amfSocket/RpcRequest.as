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
    private var _args:Array = null;

    //
    // Constructor.
    //

    public function RpcRequest(messageId:String, manager:RpcManager, command:String, args:Array) {
      super();

      _messageId = messageId;
      _manager = manager;
      _command = command;
      _args = args;
    }

    //
    // Getters and setters.
    //

    public function get messageId():String { return _messageId; }
    public function get manager():RpcManager { return _manager; }
    public function get command():String { return _command; }
    public function get args():Array { return _args; }

    //
    // Public methods.
    //

    //
    // Private methods.
    //

    //
    // Event handlers.
    //
  }
}
