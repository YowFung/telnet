part of "package:telnet/telnet.dart";


/// Telnet 交互异常时的回调。
typedef TLErrCallback = void Function(TelnetClient? client, dynamic error);

/// Telnet 连接被关闭时的回调。
typedef TLDoneCallback = void Function(TelnetClient? client);

/// Telnet 有消息事件产生时的回调。
typedef TLEventCallback = FutureOr<void> Function(TelnetClient? client, TLMsgEvent event);
