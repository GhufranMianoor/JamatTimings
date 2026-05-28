import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final isOnlineProvider = StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return ConnectivityNotifier(service);
});

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      return result != ConnectivityResult.none;
    });
  }

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

class ConnectivityNotifier extends StateNotifier<bool> {
  final ConnectivityService _service;
  late StreamSubscription<bool> _subscription;

  ConnectivityNotifier(this._service) : super(true) {
    _init();
  }

  void _init() {
    _service.isConnected.then((connected) {
      state = connected;
    });

    _subscription = _service.onConnectivityChanged.listen((connected) {
      state = connected;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
