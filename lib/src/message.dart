part of "package:telnet/telnet.dart";


/// Telnet Message.
abstract class TLMsg {

  const TLMsg(this.bytes);

  /// 完整的字节序列数据。
  final List<int> bytes;

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) => other.runtimeType == runtimeType
      && (other as TLMsg).bytes.length == bytes.length && other.toString() == toString();

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write(runtimeType.toString());
    buffer.write("(");
    var isFirstElement = true;
    for (final byte in bytes) {
      if (isFirstElement) {
        buffer.write(byte);
        isFirstElement = false;
      } else {
        buffer.write(" ");
        buffer.write(byte);
      }
    }
    buffer.write(")");
    return buffer.toString();
  }
}


/// Telnet Text Message.
class TLTextMsg extends TLMsg {

  TLTextMsg(this.text) : super(text.codeUnits);

  TLTextMsg.fromBytes(List<int> bytes) : super(bytes) {
    text = utf8.decode(this.bytes, allowMalformed: true);
  }

  /// 消息文本内容。
  late final String text;

  static const _asciiTable = ['NUL', 'SOH', 'STX', 'ETX', 'EOT', 'ENQ', 'ACK', 'BEL', 'BS',
  'TAB', 'LF', 'VT', 'FF', 'CR', 'SO', 'SI', 'DLE', 'DC1', 'DC2', 'DC3', 'DC4', 'NAK', 'SYN', 'ETB',
  'CAN', 'EM', 'SUB', 'ESC', 'FS', 'GS', 'RS', 'US'];

  @override
  String toString() {
    final buffer = StringBuffer(runtimeType);
    buffer.write("(\"");
    for (final char in text.codeUnits) {
      if (char >= 0 && char < _asciiTable.length) {
        buffer.write('{');
        buffer.write(_asciiTable[char]);
        buffer.write('}');
      } else {
        buffer.writeCharCode(char);
      }
    }
    buffer.write("\")");
    return buffer.toString();
  }
}


/// Telnet Option Message.
class TLOptMsg extends TLMsg {

  TLOptMsg(this.cmd, this.opt) : super([TLCmd.iac.code, cmd.code, opt.code]);

  TLOptMsg.fromBytes(List<int> bytes) : super(bytes) {
    assert(bytes.length == 3
        && bytes[0] == TLCmd.iac.code
        && bytes[1] != TLCmd.iac.code, "Invalid telnet option event.");
    cmd = TLCmd.get(bytes[1]);
    opt = TLOpt.get(bytes.last);
  }

  /// 选项协商的命令码。
  late final TLCmd cmd;

  /// 选项协商的选项码。
  late final TLOpt opt;
}


/// Telnet Subnegotiation Message.
class TLSubMsg extends TLMsg {

  TLSubMsg(this.opt, this.arg)
      : super([TLCmd.iac.code, TLCmd.sb.code, opt.code, ...arg, TLCmd.iac.code, TLCmd.se.code]);

  TLSubMsg.fromBytes(List<int> bytes) : super(bytes) {
    assert(bytes.length > 4
        && bytes[0] == TLCmd.iac.code
        && bytes[1] == TLCmd.sb.code
        && bytes[bytes.length-2] == TLCmd.iac.code
        && bytes.last == TLCmd.se.code, "Invalid telnet subnegotiation option event.");
    opt = TLOpt.get(bytes[2]);
    arg = bytes.sublist(2, bytes.length-2);
  }

  /// 选项协商的选项码。
  late final TLOpt opt;

  /// 附带的参数数据。
  late final List<int> arg;
}
