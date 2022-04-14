part of "package:telnet/telnet.dart";

/// Telnet 消息事件类型。
enum TLMsgEventType {
  /// 读事件，客户端已接收到服务端发来的消息。
  read,

  /// 写事件，客户端向服务端发送消息。
  write,
}

/// Telnet 消息事件。
class TLMsgEvent {
  const TLMsgEvent._(this.type, this.msg);

  /// 消息事件类型。
  final TLMsgEventType type;

  /// 消息体。
  final TLMsg msg;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[');
    buffer.write(type.name.toUpperCase());
    buffer.write('] ');
    buffer.write(msg);
    return buffer.toString();
  }
}
