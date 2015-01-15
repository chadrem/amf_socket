package amfSocket {
import amfSocket.events.AmfSocketEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.utils.ByteArray;

public class AmfSocket extends EventDispatcher {
  //
  // Constants.
  //

  public static const DEFAULT_CONNECT_TIMEOUT:int = 20; // Seconds.

  //
  // Instance variables.
  //

  private static var _logger:Object;
  private static var _encoder:Function;
  private static var _decoder:Function;

  public static function set logger(value:Object):void {
    _logger = value;
  }

  public static function get logger():Object {
    return _logger;
  }

  public function log(message:String):void {
    if (!_logger)
      return;

    _logger.debug(message);
  }

  private var _host:String = null;
  private var _port:int = 0;
  private var _socket:Socket = null;
  private var _buffer:ByteArray = new ByteArray();
  private var _timeout:int = DEFAULT_CONNECT_TIMEOUT;

  //
  // Constructor.
  //

  public function AmfSocket(host:String = null, port:int = 0) {
    _host = host;
    _port = port;
  }

  //
  // Getters and setters.
  //

  public static function get encoder():Function {
    return _encoder;
  }

  public static function set encoder(value:Function):void {
    _encoder = value;
  }

  public static function get decoder():Function {
    return _decoder;
  }

  public static function set decoder(value:Function):void {
    _decoder = value;
  }

  public function get timeout():int {
    return _timeout;
  }

  public function set timeout(value:int):void {
    _timeout = value;
  }

  //
  // Public methods.
  //

  public function connect():void {
    if (connected)
      throw new Error('Can not connect an already connected socket.');

    _socket = new Socket();
    _socket.timeout = _timeout * 1000;
    addEventListeners();
    _socket.connect(_host, _port);
  }

  public function disconnect():void {
    if (_socket) {
      removeEventListeners();

      if (_socket.connected)
        _socket.close();
    }

    _socket = null;
  }

  public function get connected():Boolean {
    if (!_socket || !_socket.connected)
      return false;
    else
      return true;
  }

  public function sendObject(object:Object):void {
    if (!connected)
      throw new Error('Can not send over a non-connected socket.');

    var byteArray:ByteArray = encodeObject(object);
    _socket.writeUnsignedInt(byteArray.length);
    _socket.writeBytes(byteArray);
    _socket.flush();
  }

  //
  // Protected methods.
  //

  protected function encodeObject(object:*):ByteArray {
    if (_encoder)
      return _encoder(object);

    var byteArray:ByteArray = new ByteArray();
    byteArray.writeObject(object);

    return byteArray;
  }

  protected function decodeByteArray(bytes:ByteArray):Object {
    if (_decoder)
      return _decoder(bytes);

    return bytes.readObject();
  }

  //
  // Private methods.
  //

  private function addEventListeners():void {
    if (!_socket)
      throw new Error('Can not add event listeners to a null socket.');

    _socket.addEventListener(Event.CONNECT, socket_connect);
    _socket.addEventListener(Event.CLOSE, socket_disconnect);
    _socket.addEventListener(IOErrorEvent.IO_ERROR, socket_ioError);
    _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socket_securityError);
    _socket.addEventListener(ProgressEvent.SOCKET_DATA, socket_socketData);
  }

  private function removeEventListeners():void {
    if (!_socket)
      throw new Error('Can not remove event listeners from a null socket.');

    _socket.removeEventListener(Event.CONNECT, socket_connect);
    _socket.removeEventListener(Event.CLOSE, socket_disconnect);
    _socket.removeEventListener(IOErrorEvent.IO_ERROR, socket_ioError);
    _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, socket_securityError);
    _socket.removeEventListener(ProgressEvent.SOCKET_DATA, socket_socketData);
  }

  //
  // Event handlers.
  //

  private function socket_connect(event:Event):void {
    log('Connected.');

    dispatchEvent(new AmfSocketEvent(AmfSocketEvent.CONNECTED));
  }

  private function socket_disconnect(event:Event):void {
    log('Disconnected.');

    removeEventListeners();
    _socket = null;

    dispatchEvent(new AmfSocketEvent(AmfSocketEvent.DISCONNECTED));
  }

  private function socket_ioError(event:IOErrorEvent):void {
    log('IO Error.');

    dispatchEvent(new AmfSocketEvent(AmfSocketEvent.IO_ERROR));
  }

  private function socket_securityError(event:SecurityErrorEvent):void {
    log('Security Error.');

    dispatchEvent(new AmfSocketEvent(AmfSocketEvent.SECURITY_ERROR));
  }

  private function socket_socketData(event:ProgressEvent):void {
    log('Received Data. bytesAvailable=' + _socket.bytesAvailable);

    // Append socket data to buffer.
    _buffer.position = 0;
    _socket.readBytes(_buffer, _buffer.length, _socket.bytesAvailable);

    // Process any buffered objects.
    var object:* = readBufferedObject();
    while (object) {
      log('Received Object.');
      dispatchEvent(new AmfSocketEvent(AmfSocketEvent.RECEIVED_OBJECT, object));
      object = readBufferedObject();
    }
  }

  private function readBufferedObject():* {
    _buffer.position = 0;

    if (_buffer.length >= 4) {
      var payloadSize:int = _buffer.readUnsignedInt();

      if (_buffer.length >= payloadSize + 4) {
        var object:* = decodeByteArray(_buffer);
        shiftBuffer(4 + payloadSize);

        return object;
      }

      return null;
    }

    return null;
  }

  private function shiftBuffer(count:int):void {
    var tmpBuffer:ByteArray = new ByteArray();

    _buffer.position = count;
    _buffer.readBytes(tmpBuffer);
    _buffer = tmpBuffer;
  }
}
}