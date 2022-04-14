import 'package:telnet/telnet.dart';

const host = "192.168.4.163";
const port = 23;
const username = "admin";
const password = "";
var hasLogin = false;

void main() async {
  // Create a Telnet connection task.
  final task = TelnetClient.startConnect(
    host: host,
    port: port,
    onError: onError,
    onDone: onDone,
    onEvent: onEvent,
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

  await Future.delayed(const Duration(seconds: 15));
  // Close the Telnet connection.
  await client?.terminate();
}

void onError(TelnetClient? client, dynamic error) {
  print("[ERROR] $error");
}

void onDone(TelnetClient? client) {
  print("[DONE]");
}

void onEvent(TelnetClient? client, TLMsgEvent event) {
  if (event.type == TLMsgEventType.write) {
    print("[WRITE] ${event.msg}");
  } else if (event.type == TLMsgEventType.read) {
    print("[READ] ${event.msg}");
    if (event.msg is TLOptMsg) {
      final cmd = (event.msg as TLOptMsg).cmd; // Telnet Negotiation Command.
      final opt = (event.msg as TLOptMsg).opt; // Telnet Negotiation Option.
      if (cmd == TLCmd.doIt) {
        if (opt == TLOpt.windowSize) {
          // Send `IAC WILL TERMINAL_WINDOW_SIZE`.
          client!.write(TLOptMsg(TLCmd.will, opt));
          // Send `IAC SB TERMINAL_WINDOW_SIZE 100 24 IAC SE`.
          client.write(TLSubMsg(opt, [0x00, 0x64, 0x00, 0x18]));
        } else {
          // `IAC WONT xxx` to reply to `IAC DO xxx`.
          client!.write(TLOptMsg(TLCmd.wont, opt));
        }
      } else if (cmd == TLCmd.will) {
        // `IAC DONT xxx` to reply to `IAC WILL xxx`.
        client!.write(TLOptMsg(TLCmd.doNot, opt));
      }
    } else if (!hasLogin && event.msg is TLTextMsg) {
      final text = (event.msg as TLTextMsg).text.toLowerCase();
      if (text.contains("welcome")) {
        hasLogin = true;
        print("[INFO] Login OK!");
      } else if (text.contains("login:") || text.contains("username:")) {
        // Write username.
        client!.write(TLTextMsg("$username\r\n"));
      } else if (text.contains("password:")) {
        // Write password.
        client!.write(TLTextMsg("$password\r\n"));
      }
    }
  }
}
