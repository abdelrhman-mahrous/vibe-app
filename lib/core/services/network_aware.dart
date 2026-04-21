import 'package:vibe/core/services/network_info.dart';

mixin NetworkAware {
  NetworkInfo get _networkInfo => NetworkMonitor();

  Future<bool> get isConnected => _networkInfo.isConnected;
}
