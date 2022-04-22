[中文](./README.md)|[English](./README_en.md)



# Telnet

使用 Dart 语言实现的 Telnet 客户端。



## 功能特点

- 支持选项协商、子选项协商和文本消息传输
- 支持 TLS 安全传输
- 消息事件侦听
- 枚举了所有的 Telnet 命令码和选项码



## 使用方法

创建一个 Telnet 连接任务：

```dart
// 常规方式
final task = TelnetClient.startConnect(
  host: host, 
  port: port, 
  timeout: timeout,
  onError: onError,
  onDone: onDone,
  onEvent: onEvent,
);

// 使用 TLS 安全传输
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

等待连接任务结束，然后获取 `TelnetClient` 实例对象：

```dart
// 同步方式
await task.waitDone();
final client = task.client;
final connected = client != null;

// 异步方式
task.onDone = (client) {
  final connected = client != null;
}
```

取消连接任务：

```dart
task.cancel();
```

关闭 Telnet 连接：

```dart
client.terminate();
```

侦听并处理消息事件：

```dart
final task = TelnetClient.startConnect(
  host: host, 
  port: port, 
  onEvent: (client, event) {
    final eventType = event.type;
    final eventMsg = event.msg;
    
    if (eventType == TLMsgEventType.write) {
      print("这是一个写事件，数据由客户端发往服务端。");
    } else if (eventType == TLMsgEventType.read) {
      print("这是一个读事件，数据由服务端发往客户端。");
    }
    
    if (eventMsg is TLOptMsg) {
      // 选项协商
      print("IAC ${eventMsg.cmd.code} ${eventMsg.opt.code}");
    } else if (eventMsg is TLSubMsg) {
      // 子选项协商
      print("IAC SB ${eventMsg.opt.code} ${eventMsg.arg.join(' ')} IAC SE");
    } else if (eventMsg is TLTextMsg) {
      // 文本消息
      print(eventMsg.text);
    }
  },
);
```

完整使用方法请参考 `Example` 代码，更多详细说明请参考 API 文档。