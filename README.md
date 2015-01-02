# AMF Socket - Actionscript

AMF Socket is a bi-directional remote procedure call (RPC) system for Adobe Actionscript programs.
This library aims to make high quality and free RPC accessible to all of the Flash platforms (web, mobile, and desktop).
Using this library you can easily add event driven network functionality to your Flash applications without having to deal with the low level details.
High performance and low latency is accomplished through the use of persistent TCP/IP sockets and Flash's native serialization format (AMF).
Due to the use of AMF, you can send primitives, hashes, arrays, and even your custom classes over the network.
AMF Socket tries to be the "easy button" for Flash networking by hiding as many details as possible.
Additionally, you can use any encoder/decoder functions you want in case you prefer JSON, MessagePack, etc.

## Examples

Coming soon.

## Requests VS Messages

AMF Socket has two fundamental forms of communication.
Depending on your application, you can choose to use one or both at the same time.

### Requests
Requests are designed to work similar to HTTP.
An endpoint (either your client or your server) can make a request to the other end of the connection.
The other end is then responsible for replying.
An example use case is asking your server to send back the result of a database query.

### Messages
Messages are fire and forget.
Unlike requests, you can't respond to a message.
Use cases include push notifications, chat messages, and stock tickers.

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

* Create appropriate instance variables, getters, and setters (these will be serialized).

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

Copyright (c) 2012-2014 Chad Remesch. See LICENSE.txt for details.
