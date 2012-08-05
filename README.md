# AMF Socket

AMF Socket makes it easy for you to send/receive serialized objects over TCP/IP sockets.
It is compatible with web, desktop, and mobile Flash applications.

## Wire Protocol

Each message has a 4 byte header followed by a variable length payload encoded in AMF verison 3.
The header contains a single unsigned int that indicates the length (in bytes) of the payload.
All messages use big-endian byte ordering.

For more information on AMF: [http://en.wikipedia.org/wiki/Action_Message_Format](http://en.wikipedia.org/wiki/Action_Message_Format)

## Copyright

Copyright (c) 2012 - 2012 Chad Remesch. See LICENSE for details.
