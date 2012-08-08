package amfSocket
{
  import flash.events.EventDispatcher;
  import flash.events.TimerEvent;
  import flash.utils.Dictionary;
  import flash.utils.Timer;

  import mx.messaging.channels.StreamingAMFChannel;

  public class RpcManager extends EventDispatcher
  {
    //
    // Instance variables.
    //

    private var _host:String = null;
    private var _port:int = 0;
    private var _socket:AmfSocket = null;
    private var _state:String = 'initialized'; // Valid states: initialized, disconnected, connected, failed, connecting, disposed.
    private var _reconnectTimer:Timer = null;
    private var _requests:Dictionary = new Dictionary();

    //
    // Constructor.
    //

    public function RpcManager(host:String, port:int) {
      super();

      _host = host;
      _port = port;

      _reconnectTimer = new Timer(3000, 0);
      _reconnectTimer.start();
    }

    //
    // Public methods.
    //

    public function connect():void {
      if(isDisconnected() || isInitialized())
        __connect();
      else
        throw new Error('Can not connect when in state: ' + _state);
    }

    public function disconnect():void {
      if(isConnected()) {
        __disconnect();
        _state = 'initialized';
      }
    }

    public function isInitialized():Boolean {
      return isState('initialized');
    }

    public function isConnected():Boolean {
      return isState('connected');
    }

    public function isDisconnected():Boolean {
      return isState('disconnected');
    }

    public function isConnecting():Boolean {
      return isState('connecting');
    }

    public function isDisposed():Boolean {
      return isState('disposed');
    }

    public function isFailed():Boolean {
      return isState('failed');
    }

    public function dispose():void {
      disconnect();
      _reconnectTimer.stop();
      _reconnectTimer = null;
    }

    public function deliver(request:RpcRequest):void {
      _requests[request.messageId] = request;

      var msg:Object = {}
      msg.type = 'rpcRequest';
      msg.request = {};
      msg.request.command = request.command;
      msg.request.params = request.params;
      msg.request.messageId = request.messageId;

      _socket.sendObject(msg);
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

    private function addEventListeners():void {
      _socket.addEventListener(AmfSocketEvent.CONNECTED, socket_connected);
      _socket.addEventListener(AmfSocketEvent.DISCONNECTED, socket_disconnected);
      _socket.addEventListener(AmfSocketEvent.RECEIVED_OBJECT, socket_receivedObject);
      _socket.addEventListener(AmfSocketEvent.IO_ERROR, socket_ioError);
      _socket.addEventListener(AmfSocketEvent.SECURITY_ERROR, socket_securityError);

      _reconnectTimer.addEventListener(TimerEvent.TIMER, reconnectTimer_timer);
    }

    private function removeEventListeners():void {
      _socket.removeEventListener(AmfSocketEvent.CONNECTED, socket_connected);
      _socket.removeEventListener(AmfSocketEvent.DISCONNECTED, socket_disconnected);
      _socket.removeEventListener(AmfSocketEvent.RECEIVED_OBJECT, socket_receivedObject);
      _socket.removeEventListener(AmfSocketEvent.IO_ERROR, socket_ioError);
      _socket.removeEventListener(AmfSocketEvent.SECURITY_ERROR, socket_securityError);

      _reconnectTimer.removeEventListener(TimerEvent.TIMER, reconnectTimer_timer);
    }

    private function __connect():void {
      _state = 'connecting';

      _socket = new AmfSocket(_host, _port);
      addEventListeners();
      _socket.connect();
    }

    private function __disconnect():void {
      _state = 'disconnected';

      removeEventListeners();
      _socket.disconnect();
      _socket = null;
    }

    private function reconnect():void {
      __disconnect();
      __connect();
    }

    //
    // Event handlers.
    //

    private function socket_connected(event:AmfSocketEvent):void {
      _state = 'connected';
      dispatchEvent(new RpcManagerEvent(RpcManagerEvent.CONNECTED));
    }

    private function socket_disconnected(event:AmfSocketEvent):void {
      _state = 'disconnected';
      dispatchEvent(new RpcManagerEvent(RpcManagerEvent.DISCONNECTED));
    }

    private function socket_receivedObject(event:AmfSocketEvent):void {
    }

    private function socket_ioError(event:AmfSocketEvent):void {
      _state = 'failed';
      dispatchEvent(new RpcManagerEvent(RpcManagerEvent.FAILED));
    }

    private function socket_securityError(event:AmfSocketEvent):void {
      _state = 'failed';
      dispatchEvent(new RpcManagerEvent(RpcManagerEvent.FAILED));
    }

    private function reconnectTimer_timer(event:TimerEvent):void {
      if(isFailed() || isDisconnected()) {
        reconnect();
      }
    }
  }
}
