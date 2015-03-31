package amfSocket {
import amfSocket.events.RpcObjectEvent;

import flash.events.EventDispatcher;

public class RpcObject extends EventDispatcher {
  //
  // Instance variables.
  //

  private var _messageId:String = null;
  private var _command:String = null;
  private var _params:Object = null;
  private var _state:String = 'initialized'; // Valid states: initialized, delivered, succeeded, failed.
  private var _onDelivered:Function = null;
  private var _onFailed:Function = null;

  //
  // Constructor.
  //

  public function RpcObject(command:String, params:Object) {
    super();

    _command = command;
    _params = params || {};
    _messageId = genMessageId();
  }

  public function toObject():Object {
    throw new Error('You must override toObject() in a subclass.');
  }

  //
  // Getters and setters.
  //

  public function set messageId(value:String):void {
    _messageId = value;
  }

  public function get messageId():String {
    return _messageId;
  }

  public function set command(value:String):void {
    _command = value;
  }

  public function get command():String {
    return _command;
  }

  public function set params(value:Object):void {
    _params = value;
  }

  public function get params():Object {
    return _params;
  }

  public function set state(value:String):void {
    _state = value;
  }

  public function get state():String {
    return _state;
  }

  public function set onDelivered(value:Function):void {
    _onDelivered = value;
  }

  public function set onFailed(value:Function):void {
    _onFailed = value;
  }

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
  // Protected methods.
  //

  protected function isState(state:String):Boolean {
    if (_state == state)
      return true;
    else
      return false;
  }

  protected function randomInt(begin:int = 100000000, end:int = 999999999):int {
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
    if (isInitialized()) {
      _state = 'delivered';
      if (_onDelivered)
        _onDelivered();
      dispatchEvent(new RpcObjectEvent(RpcObjectEvent.DELIVERED));
    }
    else
      throw new Error("Received 'delivered' signal an already delivered RPC request.");
  }

  public function __signalFailed__(reason:String = null):void {
    if (isDelivered()) {
      _state = 'failed';
      if (_onFailed)
        _onFailed();
      dispatchEvent(new RpcObjectEvent(RpcObjectEvent.FAILED, reason));
    }
    else
      throw new Error("Received 'failed' signal when not in 'delivered' state.");
  }
}
}