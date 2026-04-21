import 'dart:async';
import 'dart:io';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onStatusChange;
  void dispose();
}

class NetworkMonitor implements NetworkInfo {
  // 1. استخدام كلاس InternetConnection الخاص بالحزمة الجديدة
  final InternetConnection _checker;

  // StreamController من نوع Broadcast ليسمح لأكثر من مكان بالاستماع
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  // 2. تحديث النوع إلى InternetStatus بدلاً من InternetConnectionStatus
  StreamSubscription<InternetStatus>? _subscription;
  Timer? _debounceTimer;

  // 3. يفضل استخدام بورت 443 (HTTPS) لأنه لا يتم حظره مثل بورت 53 (DNS)
  static const int _port = 443;
  static const List<String> _reliableHosts = [
    '8.8.8.8', // Google
    '1.1.1.1', // Cloudflare
  ];

  // 4. تحديث الـ Constructor ليتوافق مع الحزمة
  NetworkMonitor({InternetConnection? checker})
    : _checker = checker ?? InternetConnection() {
    _initStream();
  }

  void _initStream() {
    _subscription = _checker.onStatusChange.listen((status) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
        if (_controller.isClosed) return;

        final hasInternet = await _verifyConnection(status);

        if (!_controller.isClosed) {
          _controller.add(hasInternet);
        }
      });
    });
  }

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  bool get isClosed => _controller.isClosed;

  @override
  Future<bool> get isConnected async {
    // Fail-Safe
    if (_controller.isClosed) return false;

    bool hasInternetAccess = false;
    try {
      // 5. التحديث إلى hasInternetAccess بدلاً من hasConnection
      hasInternetAccess = await _checker.hasInternetAccess;
    } catch (e) {
      return false;
    }

    if (!hasInternetAccess) return false;

    // تحقق عميق
    return await _hasRealInternet();
  }

  Future<bool> _hasRealInternet() async {
    try {
      // 6. استخدام Future.wait لتجنب الفشل السريع وإعطاء فرصة لكل السيرفرات (حل المشكلة السابقة)
      final results = await Future.wait(
        _reliableHosts.map(
          (host) =>
              Socket.connect(host, _port, timeout: const Duration(seconds: 2))
                  .then((socket) {
                    socket.destroy();
                    return true;
                  })
                  .catchError((_) => false),
        ),
      );

      // إذا نجح أي اتصال، نعيد true
      return results.any((isConnected) => isConnected == true);
    } catch (_) {
      return false;
    }
  }

  // 7. تحديث النوع هنا أيضاً إلى InternetStatus
  Future<bool> _verifyConnection(InternetStatus status) async {
    if (status == InternetStatus.disconnected) return false;
    return await _hasRealInternet();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}
