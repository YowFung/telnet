part of "package:telnet/telnet.dart";


/// Telnet Message Event Type.
enum TLMsgEventType { read, write }


/// Telnet Message Event.
class TLMsgEvent {

  const TLMsgEvent._(this.type, this.msg);

  final TLMsgEventType type;
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
