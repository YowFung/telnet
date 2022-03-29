part of "package:telnet/telnet.dart";


class TelnetClientConnectionTask {

  TelnetClientConnectionTask._(Future<void> Function(TelnetClientConnectionTask) handler) {
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
  TelnetClient? _client;
  final _watch = Stopwatch();

  TelnetClient? get client => _client;

  void Function(TelnetClient?)? onDone;
  void Function(dynamic)? onError;

  Duration get elapsed => _watch.elapsed;

  Future<void> waitDone() async {
    while (_watch.isRunning) {
      await Future.delayed(const Duration(milliseconds: 5));
    }
  }

  void cancel() {
    _watch.stop();
    _task?.cancel();
    _task = null;
  }
}


class TelnetClient {

  static TelnetClientConnectionTask startConnect({
    required String host,
    int port = 23,
    Duration timeout = const Duration(seconds: 10),
    TLErrCallback? onError,
    TLDoneCallback? onDone,
    TLEventCallback? onEvent,
  }) => _getTask(host, port, timeout, onError, onDone, onEvent,
          (task) => RawSocket.startConnect(host, port));

  static TelnetClientConnectionTask startSecureConnect({
    required String host,
    int port = 23,
    Duration timeout = const Duration(seconds: 10),
    SecurityContext? securityContext,
    bool Function(X509Certificate)? onBadCertificate,
    List<String>? supportedProtocols,
    TLErrCallback? onError,
    TLDoneCallback? onDone,
    TLEventCallback? onEvent,
  }) => _getTask(host, port, timeout, onError, onDone, onEvent,
          (task) => RawSecureSocket.startConnect(host, port,
          context: securityContext,
          onBadCertificate: onBadCertificate,
          supportedProtocols: supportedProtocols));

  static TelnetClientConnectionTask _getTask(String host, int port, Duration timeout,
      TLErrCallback? onError,
      TLDoneCallback? onDone,
      TLEventCallback? onEvent,
      Future<ConnectionTask> Function(TelnetClientConnectionTask) f)
  {
    final task = TelnetClientConnectionTask._((task) async {
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
          onError: client._onError,
          onDone: client._onDone
      );
      task._client = client;
    });
    task.onError = (err) => onError?.call(null, err);
    return task;
  }

  TelnetClient._(this.remoteAddress, this.remotePort, this.onError, this.onDone, this.onEvent);

  final String remoteAddress;
  late final int remotePort;

  /// 当 Socket 中有异常发生时，将会调用此回调。
  final TLErrCallback? onError;

  /// 当 Socket 结束时（断开连接或因发生异常而中止），将会调用此回调。
  final TLDoneCallback? onDone;

  /// 当有 Telnet 事件（发送消息或接收到消息）发生时，将会调用此回调。
  ///
  /// 可以在这个回调中侦听或拦截事件，该回调可返回一个 [TLEventHandleMethod] 枚举结果，告诉下一级该如何处理该事件。
  final TLEventCallback? onEvent;

  RawSocket? _socket;
  StreamSubscription? _subscription;
  final _buffer = <int>[];
  _CodeState _state = _CodeState.normal;
  int _tick = 0;

  String? get localAddress => _socket?.address.address;

  int? get localPort => _socket?.port;

  bool get isConnected => _socket != null;

  Future<void> terminate() async {
    await _socket?.close();
    _socket = null;
  }

  void write(TLMsg msg) {
    final res = _socket?.write(msg.bytes);
    if (res != null && res > 0) {
      onEvent?.call(this, TLMsgEvent._(TLMsgEventType.write, msg));
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
      case _CodeState.normal: {
        if (code == TLCmd.iac.code) {
          _outputMsg((data) => TLTextMsg.fromBytes(data));
          _state = _CodeState.iac;
        }
        _buffer.add(code);
      } break;
      case _CodeState.iac: {
        _buffer.add(code);
        if (code == TLCmd.sb.code) {
          _state = _CodeState.subOpt;
        } else if (code == TLCmd.se.code) {
          _outputMsg((data) => TLSubMsg.fromBytes(data));
          _state = _CodeState.normal;
        } else {
          _state = _CodeState.opt;
        }
      } break;
      case _CodeState.opt: {
        _buffer.add(code);
        _outputMsg((data) => TLOptMsg.fromBytes(data));
        _state = _CodeState.normal;
      } break;
      case _CodeState.subOpt: {
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
