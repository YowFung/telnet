part of "package:telnet/telnet.dart";

/// Telnet 命令代码。
///
/// 参考资料: [Telnet commands and options](https://www.ibm.com/docs/en/zos/2.3.0?topic=problems-telnet-commands-options)
class TLCmd {
  static final _map = <int, TLCmd>{};

  TLCmd._(this.code) {
    assert(code >= 128 && code <= 255);
    _map[code] = this;
  }

  /// 通过代码数值来获取 [TLCmd] 实例。
  ///
  /// 注意：相同的代码所获得的实例为同一个。
  factory TLCmd.get(int code) {
    return _map[code] ?? TLCmd._(code);
  }

  /// 代码数值。
  final int code;

  @override
  int get hashCode => code;

  @override
  bool operator ==(Object other) => other is TLCmd && other.code == code;

  @override
  String toString() => "$runtimeType($code)";

  /// End of subnegotiation parameters.
  static final se = TLCmd._(240);

  /// No operation.
  static final nop = TLCmd._(241);

  /// Data Mark (part of the Synch function). Indicates the position of a Synch event within the data stream.
  static final dm = TLCmd._(242);

  /// NYT character break.
  static final brk = TLCmd._(243);

  /// Suspend, interrupt or abort the process to which the NVT is connected.
  static final ip = TLCmd._(244);

  /// Abort Output. Allows the current process to run to completion but do not send its output to the user.
  static final ao = TLCmd._(245);

  /// Are you there? AYT is used to determine if the remote TELNET partner is still up and running.
  static final ayt = TLCmd._(246);

  /// Erase character. Erase character is used to indicate the receiver should delete the last preceding undeleted character from the data stream.
  static final ec = TLCmd._(247);

  /// Erase line. Delete characters from the data stream back to but not including the previous CRLF.
  static final el = TLCmd._(248);

  /// Go ahead. Go ahead is used in half-duplex mode to indicate the other end that it can transmit.
  static final ga = TLCmd._(249);

  /// Begin of subnegotiation.
  static final sb = TLCmd._(250);

  /// The sender wants to enable an option.
  ///
  /// 使用场景：
  /// - 发送方想激活选项
  /// - 接收方答复 Do 请求（同意）
  static final will = TLCmd._(251);

  /// The sender do not wants to enable an option.
  ///
  /// 使用场景：
  /// - 发送方想禁止选项
  /// - 接收方答复 Do（不同意）或 Don't（必须同意）请求
  static final wont = TLCmd._(252);

  /// Sender asks receiver to enable an option.
  ///
  /// 使用场景：
  /// - 发送方想让接收方激活选项
  /// - 接收方答复 Will 请求（同意）
  static final doIt = TLCmd._(253);

  /// Sender asks receiver not to enable an option.
  ///
  /// 使用场景：
  /// - 发送方想让接收方禁止选项
  /// - 接收方答复 Will（不同意）或 Won't（必须同意）请求
  static final doNot = TLCmd._(254);

  /// IAC (Interpret as Command).
  static final iac = TLCmd._(255);
}

/// Telnet 选项代码。
///
/// 参考资料: [Telnet Options](https://www.iana.org/assignments/telnet-options/telnet-options.xhtml)
class TLOpt {
  static final _map = <int, TLOpt>{};

  TLOpt._(this.code) {
    _map[code] = this;
  }

  /// 通过代码数值来获取 [TLOpt] 实例。
  ///
  /// 注意：相同的代码所获得的实例为同一个。
  factory TLOpt.get(int code) {
    assert(code >= 0 && code <= 255);
    return _map[code] ?? TLOpt._(code);
  }

  /// 代码数值。
  final int code;

  @override
  int get hashCode => code.hashCode;

  @override
  bool operator ==(Object other) => other is TLOpt && other.code == code;

  @override
  String toString() => "$runtimeType($code)";

  /// Binary Transmission.
  ///
  /// 参考：[RFC856](https://www.rfc-editor.org/rfc/rfc856.html)
  static final bin = TLOpt._(0);

  /// Echo.
  ///
  /// 参考：[RFC857](https://www.rfc-editor.org/rfc/rfc857.html)
  static final echo = TLOpt._(1);

  /// Reconnection.
  ///
  /// 参考：[NIC 15391 of 1973]()
  static final reconn = TLOpt._(2);

  /// Suppress Go Ahead.
  ///
  /// 参考：[RFC858](https://www.rfc-editor.org/rfc/rfc858.html)
  static final suppress = TLOpt._(3);

  /// Approx Message Size Negotiation.
  ///
  /// 参考：[NIC 15393 of 1973]()
  static final msgSize = TLOpt._(4);

  /// Status.
  ///
  /// 参考：[RFC859](https://www.rfc-editor.org/rfc/rfc859.html)
  static final status = TLOpt._(5);

  /// Timing Mark.
  ///
  /// 参考：[RFC860](https://www.rfc-editor.org/rfc/rfc859.html)
  static final timingMark = TLOpt._(6);

  /// Remote Controlled Trans and Echo.
  ///
  /// 参考：[RFC729](https://www.rfc-editor.org/rfc/rfc726.html)
  static final remoteCtrl = TLOpt._(7);

  /// Output Line Width.
  ///
  /// 参考：[NIC 20196 of August 1978]()
  static final oLineWidth = TLOpt._(8);

  /// Output Page Size.
  ///
  /// 参考：[NIC 20197 of August 1978]()
  static final oPageSize = TLOpt._(9);

  /// Output Carriage-Return Disposition.
  ///
  /// 参考：[RFC652](https://www.rfc-editor.org/rfc/rfc652.html)
  static final oCRD = TLOpt._(10);

  /// Output Horizontal Tab Stops.
  ///
  /// 参考：[RFC653](https://www.rfc-editor.org/rfc/rfc653.html)
  static final oHTS = TLOpt._(11);

  /// Output Horizontal Tab Disposition.
  ///
  /// 参考：[RFC654](https://www.rfc-editor.org/rfc/rfc654.html)
  static final oHTD = TLOpt._(12);

  /// Output Formfeed Disposition.
  ///
  /// 参考：[RFC655](https://www.rfc-editor.org/rfc/rfc655.html)
  static final oFD = TLOpt._(13);

  /// 	Output Vertical Tab Stops.
  ///
  /// 参考：[RFC656](https://www.rfc-editor.org/rfc/rfc656.html)
  static final oVTS = TLOpt._(14);

  /// 	Output Vertical Tab Disposition.
  ///
  /// 参考：[RFC657](https://www.rfc-editor.org/rfc/rfc657.html)
  static final oVTD = TLOpt._(15);

  /// Output Linefeed Disposition.
  ///
  /// 参考：[RFC658](https://www.rfc-editor.org/rfc/rfc658.html)
  static final oLD = TLOpt._(16);

  /// Extended ASCII.
  ///
  /// 参考：[RFC698](https://www.rfc-editor.org/rfc/rfc698.html)
  static final extAscii = TLOpt._(17);

  /// Logout.
  ///
  /// 参考：[RFC727](https://www.rfc-editor.org/rfc/rfc727.html)
  static final logout = TLOpt._(18);

  /// Byte Macro.
  ///
  /// 参考：[RFC735](https://www.rfc-editor.org/rfc/rfc735.html)
  static final byteMacro = TLOpt._(19);

  /// Data Entry Terminal.
  ///
  /// 参考：[RFC1043](https://www.rfc-editor.org/rfc/rfc1043.html)、[RFC732](https://www.rfc-editor.org/rfc/rfc732.html)
  static final dataEntry = TLOpt._(20);

  /// SUPDUP.
  ///
  /// 参考：[RFC736](https://www.rfc-editor.org/rfc/rfc736.html)、[RFC734](https://www.rfc-editor.org/rfc/rfc734.html)
  static final supdup = TLOpt._(21);

  /// SUPDUP Output.
  ///
  /// 参考：[RFC749](https://www.rfc-editor.org/rfc/rfc749.html)
  static final supdupOut = TLOpt._(22);

  /// Send Location.
  ///
  /// 参考：[RFC779](https://www.rfc-editor.org/rfc/rfc779.html)
  static final sendLoc = TLOpt._(23);

  /// Terminal Type.
  ///
  /// 参考：[RFC1091](https://www.rfc-editor.org/rfc/rfc1091.html)
  static final tmlType = TLOpt._(24);

  /// End of Record.
  ///
  /// 参考：[RFC885](https://www.rfc-editor.org/rfc/rfc885.html)
  static final eor = TLOpt._(25);

  /// TACACS User Identification.
  ///
  /// 参考：[RFC927](https://www.rfc-editor.org/rfc/rfc927.html)
  static final tacacs = TLOpt._(26);

  /// Output Marking.
  ///
  /// 参考：[RFC933](https://www.rfc-editor.org/rfc/rfc933.html)
  static final oMarking = TLOpt._(27);

  /// Terminal Location Number.
  ///
  /// 参考：[RFC946](https://www.rfc-editor.org/rfc/rfc946.html)
  static final tmlLocNum = TLOpt._(28);

  /// Telnet 3270 Regime.
  ///
  /// 参考：[RFC1041](https://www.rfc-editor.org/rfc/rfc1041.html)
  static final regimeOf3270 = TLOpt._(29);

  /// X.3 PAD.
  ///
  /// 参考：[RFC1053](https://www.rfc-editor.org/rfc/rfc1053.html)
  static final x3Pad = TLOpt._(30);

  /// Negotiate About Window Size.
  ///
  /// 参考：[RFC1073](https://www.rfc-editor.org/rfc/rfc1073.html)
  static final windowSize = TLOpt._(31);

  /// Terminal Speed.
  ///
  /// 参考：[RFC1079](https://www.rfc-editor.org/rfc/rfc1079.html)
  static final tmlSpeed = TLOpt._(32);

  /// Remote Flow Control.
  ///
  /// 参考：[RFC1372](https://www.rfc-editor.org/rfc/rfc1372.html)
  static final flowCtrl = TLOpt._(33);

  /// Line Mode.
  ///
  /// 参考：[RFC1184](https://www.rfc-editor.org/rfc/rfc1184.html)
  static final lineMode = TLOpt._(34);

  /// X Display Location.
  ///
  /// 参考：[RFC1096](https://www.rfc-editor.org/rfc/rfc1096.html)
  static final xDspLoc = TLOpt._(35);

  /// Environment Option.
  ///
  /// 参考：[RFC1408](https://www.rfc-editor.org/rfc/rfc1408.html)
  static final env = TLOpt._(36);

  /// Authentication Option.
  ///
  /// 参考：[RFC2941](https://www.rfc-editor.org/rfc/rfc2941.html)
  static final auth = TLOpt._(37);

  /// Encryption Option.
  ///
  /// 参考：[RFC2946](https://www.rfc-editor.org/rfc/rfc2946.html)
  static final encryption = TLOpt._(38);

  /// New Environment Option.
  ///
  /// 参考：[RFC1572](https://www.rfc-editor.org/rfc/rfc1572.html)
  static final newEnv = TLOpt._(39);

  /// TN3270E.
  ///
  /// 参考：[RFC2355](https://www.rfc-editor.org/rfc/rfc2355.html)
  static final tn3270e = TLOpt._(40);

  /// XAUTH.
  static final xauth = TLOpt._(41);

  /// CHARSET.
  ///
  /// 参考：[RFC2066](https://www.rfc-editor.org/rfc/rfc2066.html)
  static final charset = TLOpt._(42);

  /// Telnet Remote Serial Port (RSP).
  static final rsp = TLOpt._(43);

  /// Com Port Control Option.
  ///
  /// 参考：[RFC2217](https://www.rfc-editor.org/rfc/rfc2217.html)
  static final comPortCtrl = TLOpt._(44);

  /// Telnet Suppress Local Echo.
  static final suppressLocalEcho = TLOpt._(45);

  /// Telnet Start TLS.
  static final startTls = TLOpt._(46);

  /// KERMIT.
  ///
  /// 参考：[RFC2840](https://www.rfc-editor.org/rfc/rfc2840.html)
  static final kermit = TLOpt._(47);

  /// SEND-URL.
  static final sendUrl = TLOpt._(48);

  /// FORWARD_X.
  static final forwardX = TLOpt._(49);

  /// TELOPT PRAGMA LOGON.
  static final pragmaLogon = TLOpt._(138);

  /// TELOPT SSPI LOGON.
  static final sspiLogon = TLOpt._(139);

  /// TELOPT PRAGMA HEARTBEAT.
  static final pragmaHeartbeat = TLOpt._(140);

  /// Extended-Options-List.
  ///
  /// 参考：[RFC861](https://www.rfc-editor.org/rfc/rfc861.html)
  static final eol = TLOpt._(255);
}
