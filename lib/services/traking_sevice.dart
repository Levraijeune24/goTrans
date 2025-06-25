import 'dart:async';
import 'package:geolocator/geolocator.dart';

class TrackingService {
  static StreamSubscription<Position>? _subscription;
  static Position? _lastPosition;

  static void startTracking({
    required String idLivraison,
    required Function(double longitude, double latitude) onUpdate,
  }) {
    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).listen((Position position) {
      if (_lastPosition == null ||
          Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          ) >= 1) {
        onUpdate(position.longitude, position.latitude);
        _lastPosition = position;
      }
    });
  }

  static Future<void> stopTracking() async {
    await _subscription?.cancel();
    _subscription = null;
    _lastPosition = null;
  }

  static bool get isTracking => _subscription != null;
}
