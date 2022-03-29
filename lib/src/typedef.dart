part of "package:telnet/telnet.dart";


typedef TLErrCallback = void Function(TelnetClient? client, dynamic error);

typedef TLDoneCallback = void Function(TelnetClient? client);

typedef TLEventCallback = FutureOr<void> Function(TelnetClient? client, TLMsgEvent event);
