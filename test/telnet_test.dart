import 'package:telnet/telnet.dart';
import 'package:test/test.dart';

void main() {

  // 可以通过 docker 创建一个 telnet-server 来进行测试：
  // `docker run -it --name telnet-server -p 20023:23 flemingcsi/telnet-server`
  // 进入容器后执行 `passwd` 修改登录密码。
  const host = "0.0.0.0";
  const port = 20023;
  const username = "root";
  const password = "4376";

  test("Connection and Login", () async {
    var loginSuccessful = false;
    final task = TelnetClient.startConnect(host: host, port: port, onEvent: (client, event) async {
      print(event);
      if (loginSuccessful || event.type != TLMsgEventType.read) {
        return;
      }

      final msg = event.msg;
      if (msg is TLTextMsg) {
        final text = msg.text.toLowerCase();
        if (text.contains("welcome")) {
          loginSuccessful = true;
          client?.write(TLOptMsg(TLCmd.doNot, TLOpt.echo));
          client?.write(TLOptMsg(TLCmd.wont, TLOpt.echo));
          client!.write(TLTextMsg("uname -a\r\n"));
        } else if (text.contains("login:") || text.contains("username:")) {
          client!.write(TLTextMsg("$username\r\n"));
        } else if (text.contains("password:")) {
          client!.write(TLTextMsg("$password\r\n"));
        }
      } else if (msg is TLOptMsg) {
        if (msg.cmd == TLCmd.doIt) {
          client!.write(TLOptMsg(TLCmd.wont, msg.opt));
        } else if (msg.cmd == TLCmd.will) {
          client!.write(TLOptMsg(TLCmd.doNot, msg.opt));
        }
      }
    }, onError: (cli, err) => print(err));

    await task.waitDone();
    final client = task.client;
    expect(client != null, true);

    await Future.delayed(const Duration(seconds: 10));
    expect(loginSuccessful, true);
    await Future.delayed(const Duration(seconds: 1));
    await task.client?.terminate();
  });

  test("Capture error", () async {
    var hasError = false;
    final task = TelnetClient.startConnect(host: host, port: 99999);
    task.onError = (e) {
      print(e);
      hasError = true;
    };
    await task.waitDone();
    expect(hasError, true);
  });

  test("Cancel connection", () async {
    final task = TelnetClient.startConnect(host: host, port: port);
    task.cancel();
    await task.waitDone();
    expect(task.client, null);
  });

  test("Terminate connection", () async {
    var hasTerminated = false;
    final task = TelnetClient.startConnect(host: host, port: port, onDone: (client) {
      hasTerminated = true;
    });
    await task.waitDone();
    expect(task.client != null, true);
    await Future.delayed(const Duration(seconds: 2));
    expect(hasTerminated, false);
    await task.client?.terminate();
    await Future.delayed(const Duration(seconds: 1));
    expect(hasTerminated, true);
  });

  test("Secure connection", () async {
    var loginSuccessful = false;
    final task = TelnetClient.startSecureConnect(host: host, port: port, onEvent: (client, event) {
      if (loginSuccessful || event.type != TLMsgEventType.read) {
        return;
      }

      final msg = event.msg;
      if (msg is TLTextMsg) {
        final text = msg.text.toLowerCase();
        if (text.contains("welcome")) {
          loginSuccessful = true;
          client?.write(TLOptMsg(TLCmd.doNot, TLOpt.echo));
          client?.write(TLOptMsg(TLCmd.wont, TLOpt.echo));
          client!.write(TLTextMsg("uname -a\r\n"));
        } else if (text.contains("login:") || text.contains("username:")) {
          client!.write(TLTextMsg("$username\r\n"));
        } else if (text.contains("password:")) {
          client!.write(TLTextMsg("$password\r\n"));
        }
      } else if (msg is TLOptMsg) {
        if (msg.cmd == TLCmd.doIt) {
          client!.write(TLOptMsg(TLCmd.wont, msg.opt));
        } else if (msg.cmd == TLCmd.will) {
          client!.write(TLOptMsg(TLCmd.doNot, msg.opt));
        }
      }
    }, onBadCertificate: (_) => true, onError: (client, err) => print(err));

    await task.waitDone();
    expect(task.client != null, true);

    await Future.delayed(const Duration(seconds: 10));
    expect(loginSuccessful, true);

    await Future.delayed(const Duration(seconds: 2));
    await task.client?.terminate();
  });
}
