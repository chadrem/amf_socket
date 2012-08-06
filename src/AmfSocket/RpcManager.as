package AmfSocket
{
  import flash.events.EventDispatcher;

  import mx.messaging.channels.StreamingAMFChannel;

  public class RpcManager extends EventDispatcher
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private var _host:String = null;
    private var _port:int = 0;
    private var _nextRpcRequestId:int = 0;

    //
    // Constructor.
    //

    public function RpcManager(host:String, port:int) {
      super();

      _host = host;
      _port = port;
    }

    //
    // Getters and setters.
    //

    //
    // Public methods.
    //

    public function connect():void {

    }

    public function disconnect():void {

    }

    private function genRpcRequest():String {
      return (_nextRpcRequestId++).toString();
    }

    //
    // Private methods.
    //

    //
    // Event handlers.
    //
  }
}