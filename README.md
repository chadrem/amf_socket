# AMF Socket - Actionscript

AMF Socket is a bi-directional RPC system for Adobe Flash (Actionscript) programs.
This library aims to make high quality and free RPC accessible to all of the Flash platforms (web, mobile, and desktop).
Using this library you can easily add event driven network functionality to your Flash applications without having to deal with the low level details.
High performance and low latency is accomplished through the use of persistent TCP/IP sockets and Flash's native serialization format (AMF).
Due to the use of AMF, you can send primitives, hashes, arrays, and even your custom classes over the network with minimal effort.
See Class Mapper details below for more information on serializing custom classes.

## Example (Higher level AMF RPC layer)

This is the API layer you normally use in your applications.
It hides all of the networking details and presents you with a simple API for both requests and messages.

    var manager:RpcManager = new RpcManager('localhost', 9000);

    manager.addEventListener(RpcManagerEvent.CONNECTED, function(event:RpcManagerEvent):void {
      trace('connected');

      //
      // SEND REQUEST: Requests follow the request/response pattern similar to HTTP.
      //
      var request:RpcRequest = new RpcRequest('hello', {'someData': ['foobar', 5]});

      request.addEventListener(RpcObjectEvent.SUCCEEDED, function(event:RpcObjectEvent):void {
        trace(event.data);  // Reply sent from the server.
      });

      request.addEventListener(RpcObjectEvent.FAILED, function(event:RpcObjectEvent):void {
        trace('request failure');
      });

      manager.deliver(request);

      //
      // SEND MESSAGE: Messages are fire and forget.
      //
      var message:RpcMessage = new RpcMessage('hello', {'someData': ['foobar', 5]});

      request.addEventListener(RpcObjectEvent.FAILED, function(event:RpcObjectEvent):void {
        trace('message failure');
      });

      manager.deliver(message);
    });

    //
    // RECEIVE REQUEST: Receive a request from the server.  AmfSocket is bi-directional.
    //
    manager.addEventListener(RpcManagerEvent.RECEIVED_REQUEST, function(event:RpcManagerEvent):void {
      trace(event.data); // Received request.
      manager.respond(event.data as RpcReceivedRequest, 'yeeeeeehawww!');
    });

    //
    // RECEIVE MESSAGE: Receive a message from the server.  No need to reply.
    //
    manager.addEventListener(RpcManagerEvent.RECEIVED_MESSAGE, function(event:RpcManagerEvent):void {
      trace(event.data); // Received message.
    });

    manager.connect();

## Example (lower level AMF socket layer)

The lower layer is responsible for sending and receiving messages over the network.
You normally let the RPC layer take care of these details for you.
The main advantage of using this layer directly is slightly less overhead.
It allows you to quickly implement 'fire and forget' style network protocols.

    var sock:AmfSocket = new AmfSocket('localhost', 9000);
    sock.addEventListener(AmfSocketEvent.CONNECTED, function(event:AmfSocketEvent):void {
      trace('connected');
      sock.sendObject({'someData': ['foobar', 5]});
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

## Class Mapper

AMF has built in support for custom class mapping.
This is a great feature that isn't available by default in many other serialization formats (such as JSON).
By using it you will save time and and write less boilerplate code.
In order to use class mapping, you must must perform a number of steps for each of the classes you want to be able to send and receive:

* Map your class in Actionscript:

        // Pure Actionscript example:
        registerClassAlias("com.some.namespace.CoolClass", CoolClass);

        // Flex example:
        [RemoteClass(alias="com.some.namespace.CoolClass")]
        public class CoolClass {
        }

* Map your class in the server code (details are specific to each server side implementation of AMF).

* Create appopriate instance variables, getters, and setters (these will be serialized).

## Future Features

* Periodic heartbeats for detecting failed connections.
* Automatic latency computation (useful for games that want to display a ping time).
* RPC timeouts (global and per request).
* Auto disconnect/reconnect based on heartbeats (important for low quality mobile networks).

## Server Implementations

Contact me if you are interested in building server implementations.
The current list of implementations can be found below:

* [Ruby](https://github.com/chadrem/amf_socket_ruby)

## Wire Protocol

Each message has a 4 byte header followed by a variable length payload encoded in AMF verison 3.
The header contains a single unsigned int that indicates the length (in bytes) of the payload.
All messages use big-endian byte ordering.

For more information on AMF: [http://en.wikipedia.org/wiki/Action_Message_Format](http://en.wikipedia.org/wiki/Action_Message_Format)

## Copyright

Copyright (c) 2012 Chad Remesch. See LICENSE.txt for details.
