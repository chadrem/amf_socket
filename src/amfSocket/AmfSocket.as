package amfSocket
{
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.net.Socket;
  import flash.utils.ByteArray;
  import amfSocket.events.AmfSocketEvent;

  public class AmfSocket extends EventDispatcher
  {
    //
    // Instance variables.
    //

    private var _host:String = null;
    private var _port:int = 0;
    private var _socket:Socket = null;
    private var _objectLength:int = -1;

    //
    // Constructor.
    //

    public function AmfSocket(host:String = null, port:int = 0) {
      _host = host;
      _port = port;
    }

    //
    // Public methods.
    //

    public function connect():void {
      if(connected)
        throw new Error('Can not connect an already connected socket.');

      _socket = new Socket();
      addEventListeners();
      _socket.connect(_host, _port);
    }

    public function disconnect():void {
      if(_socket) {
        removeEventListeners();

        if(_socket.connected)
          _socket.close();
      }

      _socket = null;
    }

    public function get connected():Boolean {
      if(!_socket || !_socket.connected)
        return false;
      else
        return true;
    }

    public function sendObject(object:Object):void {
      if(!connected)
        throw new Error('Can not send over a non-connected socket.');

      var byteArray:ByteArray = encodeObject(object);
      _socket.writeUnsignedInt(byteArray.length);
      _socket.writeBytes(byteArray);
      _socket.flush();
    }

    //
    // Private methods.
    //

    private function addEventListeners():void {
      if(!_socket)
        throw new Error('Can not add event listeners to a null socket.');

      _socket.addEventListener(Event.CONNECT, socket_connect);
      _socket.addEventListener(Event.CLOSE, socket_disconnect);
      _socket.addEventListener(IOErrorEvent.IO_ERROR, socket_ioError);
      _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socket_securityError);
      _socket.addEventListener(ProgressEvent.SOCKET_DATA, socket_socketData);
    }

    private function removeEventListeners():void {
      if(!_socket)
        throw new Error('Can not remove event listeners from a null socket.');

      _socket.removeEventListener(Event.CONNECT, socket_connect);
      _socket.removeEventListener(Event.CLOSE, socket_disconnect);
      _socket.removeEventListener(IOErrorEvent.IO_ERROR, socket_ioError);
      _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, socket_securityError);
      _socket.removeEventListener(ProgressEvent.SOCKET_DATA, socket_socketData);
    }

    private function encodeObject(object:*):ByteArray {
      var byteArray:ByteArray = new ByteArray();
      byteArray.writeObject(object);

      return byteArray;
    }

    //
    // Event handlers.
    //

    private function socket_connect(event:Event):void {
      dispatchEvent(new AmfSocketEvent(AmfSocketEvent.CONNECTED));
    }

    private function socket_disconnect(event:Event):void {
      removeEventListeners();
      _socket = null;

      dispatchEvent(new AmfSocketEvent(AmfSocketEvent.DISCONNECTED));
    }

    private function socket_ioError(event:IOErrorEvent):void {
      dispatchEvent(new AmfSocketEvent(AmfSocketEvent.IO_ERROR));
    }

    private function socket_securityError(event:SecurityErrorEvent):void {
      dispatchEvent(new AmfSocketEvent(AmfSocketEvent.SECURITY_ERROR));
    }

    private function socket_socketData(event:ProgressEvent):void {
      while(true) {
        // Read header.
        if( (_objectLength == -1) && (_socket.bytesAvailable >= 4) ) {
          _objectLength = _socket.readUnsignedInt();
        }
        else
          return;

        // Read payload.
        if( (_objectLength >= 0) && (_socket.bytesAvailable >= _objectLength) ) {
          var byteArray:ByteArray = new ByteArray();
          _socket.readBytes(byteArray, 0, _objectLength);

          byteArray.position = 0;
          var object:* = byteArray.readObject();

          _objectLength = -1;

          dispatchEvent(new AmfSocketEvent(AmfSocketEvent.RECEIVED_OBJECT, object));
        }
        else
          return;
      }
    }
  }
}
