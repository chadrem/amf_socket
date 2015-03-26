package amfSocket {
import amfSocket.events.AmfRpcSocketEvent;
import amfSocket.events.AmfSocketEvent;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;

public class AmfRpcSocket extends EventDispatcher {
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
  private var _latency:Number = 0.0;
  private var _requestTimer:Timer = null;

  //
  // Constructor.
  //

  // Valid options:
  //   autoReconnect (boolean).
  //   connectTimeout (integer seconds).
  public function AmfRpcSocket(host:String, port:int, options:Object = null) {
    super();

    _host = host;
    _port = port;
    _options = options;

    if (options == null)
      options = {};

    if (options['autoReconnect'] == null)
      options['autoReconnect'] = true;

    autoReconnect = !!options['autoReconnect'];
  }

  //
  // Getters and setters.
  //

  public function get latency():Number {
    return _latency;
  }

  public function get autoReconnect():Boolean {
    return !!_reconnectTimer;
  }

  public function set autoReconnect(val:Boolean):void {
    (val) ? autoReconnectStart() : autoReconnectStop();
  }

  //
  // Public methods.
  //

  public function connect():void {
    if (isDisconnected() || isInitialized())
      __connect();
    else
      throw new Error('Can not connect when in state: ' + _state);
  }

  public function disconnect():void {
    if (isConnected()) {
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
    autoReconnectStop();
    requestTimerStop();
    disconnect();
  }

  public function deliver(rpcObject:RpcObject):void {
    if (rpcObject.hasOwnProperty('__signalSucceeded__'))
      _requests[rpcObject.messageId] = rpcObject;

    var object:Object = rpcObject.toObject();
    _socket.sendObject(object);

    rpcObject.__signalDelivered__();
  }

  public function respond(request:RpcReceivedRequest, result:Object):void {
    if (!request.isInitialized())
      throw new Error('You must only reply to a request one time.');

    var object:Object = {}

    object.type = 'rpcResponse';
    object.response = {};
    object.response.messageId = request.messageId;
    object.response.result = result;

    _socket.sendObject(object);
  }

  public function sendMessage(command:String, params:Object, onFailed:Function):void {
    var message:RpcMessage = new RpcMessage(command, params);

    message.onFailed = onFailed;

    deliver(message);
  }

  public function sendRequest(command:String, params:Object, onSucceeded:Function, onFailed:Function, timeout:int = 0):void {
    var request:RpcRequest = new RpcRequest(command, params);

    request.onSucceeded = onSucceeded;
    request.onFailed = onFailed;
    request.timeout = timeout;

    deliver(request);
  }

  //
  // Protected methods.
  //

  protected function receivedMessageHandler(message:RpcReceivedMessage):void {
    dispatchEvent(new AmfRpcSocketEvent(AmfRpcSocketEvent.RECEIVED_MESSAGE, message));
  }

  protected function receivedRequestHandler(request:RpcReceivedRequest):void {
    switch (request.command) {
      case 'amf_socket_ping':
        respond(request, 'pong');
        dispatchEvent(new AmfRpcSocketEvent(AmfRpcSocketEvent.RECEIVED_PING, request.params));
        break;
      default:
        dispatchEvent(new AmfRpcSocketEvent(AmfRpcSocketEvent.RECEIVED_REQUEST, request));
    }
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

    if (_options['connectTimeout'])
      _socket.timeout = _options['connectTimeout'];

    addSocketEventListeners();
    _socket.connect();
  }

  private function __disconnect():void {
    _state = 'disconnected';
    cleanUp('disconnect');
  }

  private function cleanUp(reason:String = null):void {
    if (_socket) {
      removeSocketEventListeners();
      _socket.disconnect();
      _socket = null;
    }

    requestTimerStop();

    for (var messageId:String in _requests) {
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
    if (!(data is Object))
      return false;

    if (data.type != 'rpcResponse')
      return false;

    if (!data.hasOwnProperty('response'))
      return false;

    if (!(data.response is Object))
      return false;

    if (!data.response.hasOwnProperty('messageId'))
      return false;

    if (!(data.response.messageId is String))
      return false;

    if (!data.response.hasOwnProperty('result'))
      return false;

    if (!_requests.hasOwnProperty(data.response.messageId))
      return false;

    return true;
  }

  private function isValidRpcRequest(data:Object):Boolean {
    if (!(data is Object))
      return false;

    if (data.type != 'rpcRequest')
      return false;

    if (!data.hasOwnProperty('request'))
      return false;

    if (!(data.request is Object))
      return false;

    if (!data.request.hasOwnProperty('messageId'))
      return false;

    if (!(data.request.messageId is String))
      return false;

    if (!data.request.hasOwnProperty('command'))
      return false;

    if (!(data.request.command is String))
      return false;

    if (!data.request.hasOwnProperty('params'))
      return false;

    if (!(data.request.params is Object))
      return false;


    return true;
  }

  private function isValidRpcMessage(data:Object):Boolean {
    if (!(data is Object))
      return false;

    if (data.type != 'rpcMessage')
      return false;

    if (!data.hasOwnProperty('message'))
      return false;

    if (!(data.message is Object))
      return false;

    if (!data.message.hasOwnProperty('messageId'))
      return false;

    if (!(data.message.messageId is String))
      return false;

    if (!data.message.hasOwnProperty('command'))
      return false;

    if (!(data.message.command is String))
      return false;

    if (!data.message.hasOwnProperty('params'))
      return false;

    if (!(data.message.params is Object))
      return false;

    return true;
  }

  private function autoReconnectStart():void {
    if (_reconnectTimer)
      return;

    _reconnectTimer = new Timer(3000, 0);
    _reconnectTimer.addEventListener(TimerEvent.TIMER, reconnectTimer_timer);
    _reconnectTimer.start();
  }

  private function autoReconnectStop():void {
    if (!_reconnectTimer)
      return;

    _reconnectTimer.stop();
    _reconnectTimer.removeEventListener(TimerEvent.TIMER, reconnectTimer_timer);
    _reconnectTimer = null;
  }

  private function requestTimerStart():void {
    if (_requestTimer)
      return;

    _requestTimer = new Timer(1000, 0);
    _requestTimer.addEventListener(TimerEvent.TIMER, requestTimer_timer);
    _requestTimer.start();
  }

  private function requestTimerStop():void {
    if (!_requestTimer)
      return;

    _requestTimer.stop();
    _requestTimer.removeEventListener(TimerEvent.TIMER, requestTimer_timer);
    _requestTimer = null;
  }

  private function timeoutRequests():void {
    for (var messageId:String in _requests) {
      var request:RpcRequest = _requests[messageId];
      if (request.isTimedOut()) {
        delete _requests[messageId];
        request.__signalFailed__('timeout');
      }
    }
  }

  //
  // Event handlers.
  //

  private function socket_connected(event:AmfSocketEvent):void {
    _state = 'connected';
    requestTimerStart();
    dispatchEvent(new AmfRpcSocketEvent(AmfRpcSocketEvent.CONNECTED));
  }

  private function socket_disconnected(event:AmfSocketEvent):void {
    _state = 'disconnected';
    dispatchEvent(new AmfRpcSocketEvent(AmfRpcSocketEvent.DISCONNECTED));
    cleanUp();
  }

  private function socket_receivedObject(event:AmfSocketEvent):void {
    var data:Object = event.data;

    if (isValidRpcResponse(data)) {
      var request:RpcRequest = _requests[data.response.messageId];
      delete _requests[data.response.messageId];
      request.__signalSucceeded__(data.response.result);
    }
    else if (isValidRpcRequest(data)) {
      var received_request:RpcReceivedRequest = new RpcReceivedRequest(data);
      receivedRequestHandler(received_request);
    }
    else if (isValidRpcMessage(data)) {
      var received_message:RpcReceivedMessage = new RpcReceivedMessage(data);
      receivedMessageHandler(received_message);
    }
  }

  private function socket_ioError(event:AmfSocketEvent):void {
    _state = 'failed';
    dispatchEvent(new AmfRpcSocketEvent(AmfRpcSocketEvent.FAILED));
    cleanUp('ioError');
  }

  private function socket_securityError(event:AmfSocketEvent):void {
    _state = 'failed';
    dispatchEvent(new AmfRpcSocketEvent(AmfRpcSocketEvent.FAILED));
    cleanUp('securityError');
  }

  private function reconnectTimer_timer(event:TimerEvent):void {
    if (isFailed() || isDisconnected()) {
      reconnect();
    }
  }

  private function requestTimer_timer(event:TimerEvent):void {
    timeoutRequests();
  }
}
}
