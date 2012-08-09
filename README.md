# AMF Socket - Actionscript

AMF Socket makes it easy for you to send/receive serialized objects over TCP/IP sockets.
It is compatible with web, desktop, and mobile Flash applications.

## Example

    var sock:AmfSocket = new AmfSocket('localhost', 9000);
    sock.addEventListener(AmfSocketEvent.CONNECTED, function(event:AmfSocketEvent):void {
      trace('connected');
      sock.sendObject({'some_key': 'some_value'});
    });

    sock.addEventListener(AmfSocketEvent.DISCONNECTED, function(event:AmfSocketEvent):void {
      trace('disconnected');
    });

    sock.addEventListener(AmfSocketEvent.IO_ERROR, function(event:AmfSocketEvent):void {
      trace('io error');
    });

    sock.addEventListener(AmfSocketEvent.RECEIVED_OBJECT, function(event:AmfSocketEvent):void {
      trace('received object');
    });

    sock.addEventListener(AmfSocketEvent.SECURITY_ERROR, function(event:AmfSocketEvent):void {
      trace('security error');
    });

    sock.connect();

## Wire Protocol

Each message has a 4 byte header followed by a variable length payload encoded in AMF verison 3.
The header contains a single unsigned int that indicates the length (in bytes) of the payload.
All messages use big-endian byte ordering.

For more information on AMF: [http://en.wikipedia.org/wiki/Action_Message_Format](http://en.wikipedia.org/wiki/Action_Message_Format)

## Server Implementations

* (ruby)[https://github.com/chadrem/amf_socket_ruby]

## Copyright

Copyright (c) 2012 Chad Remesch. See LICENSE for details.
