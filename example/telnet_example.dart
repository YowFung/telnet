import 'package:telnet/telnet.dart';

const host = "127.0.0.1";
const port = 23;
const username = "root";
const password = "admin";
const echoEnabled = true;

void main() async {
  // Create a Telnet connection task.
  final task = TelnetClient.startConnect(
    host: host,
    port: port,
    onEvent: _onEvent,
    onError: _onError,
    onDone: _onDone,
  );

  // Cancel the connection task.
  // task.cancel();

  // Wait the connection task finished.
  await task.waitDone();

  // Get the `TelnetClient` instance. It will be `null` if connect failed.
  final client = task.client;
  if (client == null) {
    print("Fail to connect to $host:$port");
  } else {
    print("Successfully connect to $host:$port");
  }

  await Future.delayed(const Duration(seconds: 10));

  // Close the Telnet connection.
  await client?.terminate();
}

var _hasLogin = false;
final _willReplyMap = <TLOpt, List<TLMsg>>{
  TLOpt.echo: [echoEnabled
      ? TLOptMsg(TLCmd.doIt, TLOpt.echo)                      // [IAC DO ECHO]
      : TLOptMsg(TLCmd.doNot, TLOpt.echo)],                   // [IAC DON'T ECHO]
  TLOpt.suppress: [TLOptMsg(TLCmd.doIt, TLOpt.suppress)],     // [IAC DO SUPPRESS_GO_AHEAD]
  TLOpt.logout: [],
};
final _doReplyMap = <TLOpt, List<TLMsg>>{
  TLOpt.echo: [echoEnabled
      ? TLOptMsg(TLCmd.will, TLOpt.echo)                      // [IAC WILL ECHO]
      : TLOptMsg(TLCmd.wont, TLOpt.echo)],                    // [IAC WONT ECHO]
  TLOpt.logout: [],
  TLOpt.tmlType: [
    TLOptMsg(TLCmd.will, TLOpt.tmlType),                      // [IAC WILL TERMINAL_TYPE]
    TLSubMsg(TLOpt.tmlType, [0x00, 0x41, 0x4E, 0x53, 0x49]),  // [IAC SB TERMINAL_TYPE IS ANSI IAC SE]
  ],
  TLOpt.windowSize: [
    TLOptMsg(TLCmd.will, TLOpt.windowSize),                   // [IAC WILL WINDOW_SIZE]
    TLSubMsg(TLOpt.windowSize, [0x00, 0x5A, 0x00, 0x18]),     // [IAC SB WINDOW_SIZE 90 24 IAC SE]
  ],
};

void _onEvent(TelnetClient? client, TLMsgEvent event) {
  if (event.type == TLMsgEventType.write) {
    print("[WRITE] ${event.msg}");

  } else if (event.type == TLMsgEventType.read) {
    print("[READ] ${event.msg}");

    if (event.msg is TLOptMsg) {
      final cmd = (event.msg as TLOptMsg).cmd; // Telnet Negotiation Command.
      final opt = (event.msg as TLOptMsg).opt; // Telnet Negotiation Option.

      if (cmd == TLCmd.wont) {
        // Write [IAC DO opt].
        client?.write(TLOptMsg(TLCmd.doNot, opt));
      } else if (cmd == TLCmd.doNot) {
        // Write [IAC WON'T opt].
        client?.write(TLOptMsg(TLCmd.wont, opt));
      } else if (cmd == TLCmd.will) {
        if (_willReplyMap.containsKey(opt)) {
          // Reply the option.
          for (var msg in _willReplyMap[opt]!) {
            client?.write(msg);
          }
        } else {
          // Write [IAC DON'T opt].
          client?.write(TLOptMsg(TLCmd.doNot, opt));
        }
      } else if (cmd == TLCmd.doIt) {
        // Reply the option.
        if (_doReplyMap.containsKey(opt)) {
          for (var msg in _doReplyMap[opt]!) {
            client?.write(msg);
          }
        } else {
          // Write [IAC WON'T opt].
          client?.write(TLOptMsg(TLCmd.wont, opt));
        }
      }

    } else if (!_hasLogin && event.msg is TLTextMsg) {

      final text = (event.msg as TLTextMsg).text.toLowerCase();
      if (text.contains("welcome")) {
        _hasLogin = true;
        print("[INFO] Login OK!");
      } else if (text.contains("login:") || text.contains("username:")) {
        // Write [username].
        client!.write(TLTextMsg("$username\r\n"));
      } else if (text.contains("password:")) {
        // Write [password].
        client!.write(TLTextMsg("$password\r\n"));
      }

    }
  }
}

void _onError(TelnetClient? client, dynamic error) {
  print("[ERROR] $error");
}

void _onDone(TelnetClient? client) {
  print("[DONE]");
}