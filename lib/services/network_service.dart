import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  late StreamSubscription _internetConnection;
  bool isConnected = false;

  factory NetworkService() {
    return _instance;
  }

  NetworkService._internal() {
    _internetConnection = InternetConnection().onStatusChange.listen((event) {
      switch (event) {
        case InternetStatus.connected:
          isConnected = true;
          break;
        case InternetStatus.disconnected:
          isConnected = false;
          break;
        default:
          isConnected = false;
          break;
      }
    });
  }

  void dispose() {
    _internetConnection.cancel();
  }

  bool get connectionStatus => isConnected;
}
