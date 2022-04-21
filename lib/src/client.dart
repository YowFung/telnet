part of "package:telnet/telnet.dart";

abstract class ITLConnectionTask {
  /// Telnet 客户端实例。
  ///
  /// 连接完成前，或者连接失败时，此属性均为 `null`，可通过判空来判断是否连接成功。
  ITelnetClient? get client;

  /// 连接结束时的回调事件。
  ///
  /// 其中 [client] 参数为 Telnet 客户端实例，若连接失败，则 [client] 为 `null`。
  void Function(ITelnetClient? client)? onDone;

  /// 连接过程中有异常发生时的回调。
  void Function(dynamic)? onError;

  /// 连接耗时。
  Duration get elapsed;

  /// 等待连接结束。
  Future<void> waitDone();

  /// 取消连接。
  ///
  /// 该方法只在连接进行中时有效，一旦连接结束（无论是连接成功还是失败）后再调用该方法则无任何效果。
  void cancel();
}

/// Telnet 连接任务类。
class TLConnectionTask implements ITLConnectionTask {
  TLConnectionTask._(Future<void> Function(TLConnectionTask) handler) {
    _watch.start();
    handler(this).catchError((error) {
      onError?.call(error);
    }).whenComplete(() {
      if (!_watch.isRunning) {
        _client?.terminate();
        _client = null;
      }
      _watch.stop();
      _task = null;
      onDone?.call(_client);
    });
  }

  ConnectionTask? _task;
  ITelnetClient? _client;
  final _watch = Stopwatch();

  @override
  ITelnetClient? get client => _client;

  @override
  void Function(ITelnetClient? client)? onDone;

  @override
  void Function(dynamic)? onError;

  @override
  Duration get elapsed => _watch.elapsed;

  @override
  Future<void> waitDone() async {
    while (_watch.isRunning) {
      await Future.delayed(const Duration(milliseconds: 5));
    }
  }

  @override
  void cancel() {
    _watch.stop();
    _task?.cancel();
    _task = null;
  }
}

abstract class ITelnetClient {
  /// 服务端的主机地址。
  String get remoteAddress;

  /// 服务端的端口号。
  int get remotePort;

  /// 交互过程中有异常发生时的回调。
  TLErrCallback? get onError;

  /// 连接被关闭时（断开连接或因发生异常而中止）的回调。
  TLDoneCallback? get onDone;

  /// 当有 Telnet 消息事件发生时（发送一个 Telnet 消息或接收到一个 Telnet 消息时）的回调。
  /// 可在这个回调中侦听和处理各种消息事件。
  TLEventCallback? get onEvent;

  /// 客户端的主机地址。
  String? get localAddress;

  /// 客户端的端口号。
  int? get localPort;

  /// 是否已建立连接。
  bool get isConnected;

  /// 中断连接。
  Future<void> terminate();

  /// 向服务端发送一个 Telnet 消息。
  ///
  /// 该消息可以是选项协商（[TLOptMsg]）、子选项协商（[TLSubMsg]），也可以是文本消息（[TLTextMsg]）。
  void write(TLMsg msg);

  /// 一次性向服务端发送多个 Telnet 消息。
  void writeAll(Iterable<TLMsg> messages);
}

/// Telnet 客户端类。
class TelnetClient implements ITelnetClient {
  /// 启动一个 Telnet 连接。
  ///
  /// 返回一个 [ITLConnectionTask] 实例，可使用该实例来取消连接、获取连接过程中发生的异常、获取连接耗时等。
  ///
  /// [timeout] 是指连接超时时间。
  ///
  /// [onError] 是在连接成功之后的交互过程中发生异常时的回调（例如异常断开连接），
  /// 正在连接的过程中所产生的异常请在 [ITLConnectionTask.onError] 回调中捕获。
  ///
  /// [onDone] 是连接被关闭（手动断开或由于网络异常等原因自动断开）时的回调。
  ///
  /// [onEvent] 是在有传输消息事件发生时（发送一个 Telnet 消息或接收到一个 Telnet 消息时）的回调，
  /// 可在这个回调中侦听和处理各种消息事件。
  static ITLConnectionTask startConnect({
    required String host,
    int port = 23,
    Duration timeout = const Duration(seconds: 10),
    TLErrCallback? onError,
    TLDoneCallback? onDone,
    TLEventCallback? onEvent,
  }) =>
      _getTask(host, port, timeout, onError, onDone, onEvent,
          (task) => RawSocket.startConnect(host, port));

  /// 启动一个安全的 Telnet 连接。
  ///
  /// 使用这个方法来创建的 Telnet 连接将使用 TLS 技术对传输的数据进行加密。
  /// 需要注意的是，必须服务端也支持 TLS 时才能正常使用。
  ///
  /// [securityContext]、[onBadCertificate] 和 [supportedProtocols] 参数的含义
  /// 请参阅 [RawSecureSocket.startConnect] 方法的文档注释。
  /// 其他参数含义请参阅 [TelnetClient.startConnect] 方法的文档注释。
  static ITLConnectionTask startSecureConnect({
    required String host,
    int port = 23,
    Duration timeout = const Duration(seconds: 10),
    SecurityContext? securityContext,
    bool Function(X509Certificate)? onBadCertificate,
    List<String>? supportedProtocols,
    TLErrCallback? onError,
    TLDoneCallback? onDone,
    TLEventCallback? onEvent,
  }) =>
      _getTask(
          host,
          port,
          timeout,
          onError,
          onDone,
          onEvent,
          (task) => RawSecureSocket.startConnect(host, port,
              context: securityContext,
              onBadCertificate: onBadCertificate,
              supportedProtocols: supportedProtocols));

  static ITLConnectionTask _getTask(
      String host,
      int port,
      Duration timeout,
      TLErrCallback? onError,
      TLDoneCallback? onDone,
      TLEventCallback? onEvent,
      Future<ConnectionTask> Function(ITLConnectionTask) f) {
    final task = TLConnectionTask._((task) async {
      task._task = await f(task).timeout(timeout - task.elapsed);
      if (task._task == null) {
        return;
      }
      final client = TelnetClient._(host, port, onError, onDone, onEvent);
      client._socket = await task._task!.socket.timeout(timeout - task.elapsed);
      if (client._socket == null) {
        return;
      }
      client._socket!.writeEventsEnabled = false;
      client._subscription = client._socket!.listen(client._onData,
          onError: client._onError, onDone: client._onDone);
      task._client = client;
    });
    task.onError = (err) => onError?.call(null, err);
    return task;
  }

  TelnetClient._(this.remoteAddress, this.remotePort, this.onError, this.onDone,
      this.onEvent);

  @override
  final String remoteAddress;

  @override
  late final int remotePort;

  @override
  final TLErrCallback? onError;

  @override
  final TLDoneCallback? onDone;

  @override
  final TLEventCallback? onEvent;

  RawSocket? _socket;
  StreamSubscription? _subscription;
  final _buffer = <int>[];
  _CodeState _state = _CodeState.normal;
  int _tick = 0;

  @override
  String? get localAddress => _socket?.address.address;

  @override
  int? get localPort => _socket?.port;

  @override
  bool get isConnected => _socket != null;

  @override
  Future<void> terminate() async {
    write(TLOptMsg(TLCmd.doIt, TLOpt.logout));

    final watch = Stopwatch()..start();
    while (watch.elapsedMilliseconds < 2000) {
      if (_socket == null) {
        watch.stop();
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    watch.stop();
    await _terminateForce();
  }

  Future<void> _terminateForce() async {
    await _socket?.close();
    _socket = null;
  }

  @override
  void write(TLMsg msg) {
    final res = _socket?.write(msg.bytes);
    if (res != null && res > 0) {
      onEvent?.call(this, TLMsgEvent._(TLMsgEventType.write, msg));
    }
  }

  @override
  void writeAll(Iterable<TLMsg> messages) {
    final bytes = <int>[];
    for (final msg in messages) {
      bytes.addAll(msg.bytes);
    }
    final res = _socket?.write(bytes);
    if (res != null && res > 0) {
      for (final msg in messages) {
        onEvent?.call(this, TLMsgEvent._(TLMsgEventType.write, msg));
      }
    }
  }

  void _onData(RawSocketEvent event) {
    if (event != RawSocketEvent.read) {
      return;
    }

    final data = _socket?.read() ?? [];
    _tick++;
    for (final code in data) {
      _handleCharCode(code);
    }
    if (_state == _CodeState.normal) {
      final lastTick = _tick;
      Future.delayed(const Duration(milliseconds: 3), () {
        if (lastTick == _tick && _state == _CodeState.normal) {
          _outputMsg((data) => TLTextMsg.fromBytes(data));
        }
      });
    }
  }

  void _handleCharCode(int code) {
    switch (_state) {
      case _CodeState.normal:
        {
          if (code == TLCmd.iac.code) {
            _outputMsg((data) => TLTextMsg.fromBytes(data));
            _state = _CodeState.iac;
          }
          _buffer.add(code);
        }
        break;
      case _CodeState.iac:
        {
          _buffer.add(code);
          if (code == TLCmd.sb.code) {
            _state = _CodeState.subOpt;
          } else if (code == TLCmd.se.code) {
            _outputMsg((data) => TLSubMsg.fromBytes(data));
            _state = _CodeState.normal;
          } else {
            _state = _CodeState.opt;
          }
        }
        break;
      case _CodeState.opt:
        {
          _buffer.add(code);
          _outputMsg((data) => TLOptMsg.fromBytes(data));
          _state = _CodeState.normal;
        }
        break;
      case _CodeState.subOpt:
        {
          _buffer.add(code);
          if (code == TLCmd.iac.code) {
            _state = _CodeState.iac;
          }
        }
    }
  }

  void _outputMsg(TLMsg Function(List<int> data) msgBuilder) {
    final data = _buffer.take(_buffer.length).toList();
    _buffer.clear();
    if (data.isNotEmpty) {
      final msg = msgBuilder(data);
      onEvent?.call(this, TLMsgEvent._(TLMsgEventType.read, msg));

      if (msg is TLOptMsg && msg.opt == TLOpt.logout) {
        if (msg.cmd == TLCmd.doIt) {
          terminate();
        } else {
          _terminateForce();
        }
      }
    }
  }

  void _onDone() {
    _socket = null;
    _subscription?.cancel();
    _subscription = null;
    onDone?.call(this);
  }

  void _onError(dynamic error) {
    onError?.call(this, error);
  }
}
