package amfSocket
{
  import amfSocket.events.AmfSocketEvent;
  import amfSocket.events.RpcManagerEvent;

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
    private var _options:Object;
    private var _socket:AmfSocket = null;
    private var _state:String = 'initialized'; // Valid states: initialized, disconnected, connected, failed, connecting, disposed.
    private var _reconnectTimer:Timer = null;
    private var _requests:Dictionary = new Dictionary();

    //
    // Constructor.
    //

    public function RpcManager(host:String, port:int, options:Object=null) {
      super();

      _host = host;
      _port  = port;
      _options = options;

      if(options == null)
        options = {};

      if(options['autoReconnect'] == null)
        options['autoReconnect'] = true

      if(options['autoReconnect']) {
        _reconnectTimer = new Timer(3000, 0);
        _reconnectTimer.addEventListener(TimerEvent.TIMER, reconnectTimer_timer);
        _reconnectTimer.start();
      }
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

      if(_reconnectTimer) {
        _reconnectTimer.removeEventListener(TimerEvent.TIMER, reconnectTimer_timer);
        _reconnectTimer.stop();
        _reconnectTimer = null;
      }
    }

    public function deliver(rpcObject:RpcObject):void {
      if(rpcObject.hasOwnProperty('__signalSucceeded__'))
        _requests[rpcObject.messageId] = rpcObject;

      var object:Object = rpcObject.toObject();
      _socket.sendObject(object);

      rpcObject.__signalDelivered__();
    }

    public function respond(request:RpcReceivedRequest, result:Object):void {
      if(!request.isInitialized())
        throw new Error('You must only reply to a request one time.');

      var object:Object = {}

      object.type = 'rpcResponse';
      object.response = {};
      object.response.messageId = request.messageId;
      object.response.result = result;

      _socket.sendObject(object);
    }

    //
    // Protected methods.
    //

    protected function received_message_handler(message:RpcReceivedMessage):void {
      dispatchEvent(new RpcManagerEvent(RpcManagerEvent.RECEIVED_MESSAGE, message));
    }

    protected function received_request_handler(request:RpcReceivedRequest):void {
      dispatchEvent(new RpcManagerEvent(RpcManagerEvent.RECEIVED_REQUEST, request));
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

    private function addSocketEventListeners():void {
      _socket.addEventListener(AmfSocketEvent.CONNECTED, socket_connected);
      _socket.addEventListener(AmfSocketEvent.DISCONNECTED, socket_disconnected);
      _socket.addEventListener(AmfSocketEvent.RECEIVED_OBJECT, socket_receivedObject);
      _socket.addEventListener(AmfSocketEvent.IO_ERROR, socket_ioError);
      _socket.addEventListener(AmfSocketEvent.SECURITY_ERROR, socket_securityError);
    }

    private function removeSocketEventListeners():void {
      _socket.removeEventListener(AmfSocketEvent.CONNECTED, socket_connected);
      _socket.removeEventListener(AmfSocketEvent.DISCONNECTED, socket_disconnected);
      _socket.removeEventListener(AmfSocketEvent.RECEIVED_OBJECT, socket_receivedObject);
      _socket.removeEventListener(AmfSocketEvent.IO_ERROR, socket_ioError);
      _socket.removeEventListener(AmfSocketEvent.SECURITY_ERROR, socket_securityError);
    }

    private function __connect():void {
      _state = 'connecting';

      _socket = new AmfSocket(_host, _port);
      addSocketEventListeners();
      _socket.connect();
    }

    private function __disconnect():void {
      _state = 'disconnected';
      cleanUp('disconnect');
    }

    private function cleanUp(reason:String=null):void {
      if(!_socket) {
        removeSocketEventListeners();
        _socket.disconnect();
        _socket = null;
      }

      for(var messageId:String in _requests) {
        var request:RpcRequest = _requests[messageId];
        request.__signalFailed__(reason);
        delete _requests[messageId];
      }
    }

    private function reconnect():void {
      __disconnect();
      __connect();
    }

    private function isValidRpcResponse(data:Object):Boolean {
      if(!(data is Object))
        return false;

      if(data.type != 'rpcResponse')
        return false;

      if(!data.hasOwnProperty('response'))
        return false;

      if(!(data.response is Object))
        return false;

      if(!data.response.hasOwnProperty('messageId'))
        return false;

      if(!(data.response.messageId is String))
        return false;

      if(!data.response.hasOwnProperty('result'))
        return false;

      if(!(data.response.result is String))
        return false;

      if(!_requests.hasOwnProperty(data.response.messageId))
        return false;

      return true;
    }

    private function isValidRpcRequest(data:Object):Boolean {
      if(!(data is Object))
        return false;

      if(data.type != 'rpcRequest')
        return false;

      if(!data.hasOwnProperty('request'))
        return false;

      if(!(data.request is Object))
        return false;

      if(!data.request.hasOwnProperty('messageId'))
        return false;

      if(!(data.request.messageId is String))
        return false;

      if(!data.request.hasOwnProperty('command'))
        return false;

      if(!(data.request.command is String))
        return false;

      if(!data.request.hasOwnProperty('params'))
        return false;

      if(!(data.request.params is Object))
        return false;


      return true;
    }

    private function isValidRpcMessage(data:Object):Boolean {
      if(!(data is Object))
        return false;

      if(data.type != 'rpcMessage')
        return false;

      if(!data.hasOwnProperty('message'))
        return false;

      if(!(data.message is Object))
        return false;

      if(!data.message.hasOwnProperty('messageId'))
        return false;

      if(!(data.message.messageId is String))
        return false;

      if(!data.message.hasOwnProperty('command'))
        return false;

      if(!(data.message.command is String))
        return false;

      if(!data.message.hasOwnProperty('params'))
        return false;

      if(!(data.message.params is Object))
        return false;

      return true;
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
      cleanUp();
    }

    private function socket_receivedObject(event:AmfSocketEvent):void {
      var data:Object = event.data;

      if(isValidRpcResponse(data)) {
        var request:RpcRequest = _requests[data.response.messageId];
        delete _requests[data.response.messageId];
        request.__signalSucceeded__(data.response.result);
      }
      else if(isValidRpcRequest(data)) {
        var received_request:RpcReceivedRequest = new RpcReceivedRequest(data);
        received_request_handler(received_request);
      }
      else if(isValidRpcMessage(data)) {
        var received_message:RpcReceivedMessage = new RpcReceivedMessage(data);
        received_message_handler(received_message);
      }
    }

    private function socket_ioError(event:AmfSocketEvent):void {
      _state = 'failed';
      dispatchEvent(new RpcManagerEvent(RpcManagerEvent.FAILED));
      cleanUp('ioError');
    }

    private function socket_securityError(event:AmfSocketEvent):void {
      _state = 'failed';
      dispatchEvent(new RpcManagerEvent(RpcManagerEvent.FAILED));
      cleanUp('securityError');
    }

    private function reconnectTimer_timer(event:TimerEvent):void {
      if(isFailed() || isDisconnected()) {
        reconnect();
      }
    }
  }
}
