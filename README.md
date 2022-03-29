# Telnet

Telnet client implemented in dart language.



## Features

- Negotiation.
- TLS support.
- Event listening.
- Enumerate all Telnet commands and options.



## Using

Create a Telnet connection task.

```dart
// Ordinary
final task = TelnetClient.startConnect(
  host: host, 
  port: port, 
  timeout: timeout,
  onError: onError,
  onDone: onDone,
  onEvent: onEvent,
);

// Secure
final task = TelnetClient.startSecureConnect(
	host: host,
  port: port,
  timeout: timeout,
  onError: onError,
  onDone: onDone,
  onEvent: onEvent,
  securityContext: securityContext,
  supportedProtocols: supportedProtocols,
  onBadCertificate: onBadCertificate,
);
```

Wait the connection task completed and get the `TelnetClient` instance.

```dart
// Sync
await task.waitDone();
final client = task.client;
final connected = client != null;

// Async
task.onDone = (client) {
  final connected = client != null;
}
```

Cancel the connection task.

```dart
task.cancel();
```

Close the TelnetClient.

```dart
client.terminate();
```

Listen and handle events.

```dart
final task = TelnetClient.startConnect(
  host: host, 
  port: port, 
  onEvent: (client, event) {
    final eventType = event.type;
    final eventMsg = event.msg;
    
    if (eventType == TLMsgEventType.write) {
      print("This is write event. Data flows from the client to the server.");
    } else if (eventType == TLMsgEventType.read) {
      print("This is write event. Data flows from the server to the client.");
    }
    
    if (eventMsg is TLOptMsg) {
      // Negotiation.
      print("IAC ${eventMsg.cmd.code} ${eventMsg.opt.code}");
    } else if (eventMsg is TLSubMsg) {
      // Subnegotiation.
      print("IAC SB ${eventMsg.opt.code} ${eventMsg.arg.join(' ')} IAC SE");
    } else if (eventMsg is TLTextMsg) {
      // String message.
      print(eventMsg.text);
    }
  },
);
```

