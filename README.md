# AMF Socket - Actionscript 3 socket class with AMF 3 object protocol

AMF Socket makes it easy for you to send/receive serialized objects over
TCP/IP sockets in all of your Flash applications (including web and
mobile).  The wire protocol is very simple assuming your server platform
supports the [Action Message Format](http://en.wikipedia.org/wiki/Action_Message_Format).

## Wire Protocol

Each message has a 4 byte header followed by a variable length payload
encoded in AMF verison 3.  The header contains a single unsigned int
that indicates the length (in bytes) of the payload.  All messages use
big-endian byte ordering.
