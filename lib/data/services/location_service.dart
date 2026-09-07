import 'package:geolocator/geolocator.dart';

/// Thin wrapper around geolocator for current device coordinates.
class LocationService {
  LocationService({
    this.checkPermissionFn,
    this.requestPermissionFn,
    this.isLocationServiceEnabledFn,
    this.getCurrentPositionFn,
  });

  final Future<LocationPermission> Function()? checkPermissionFn;
  final Future<LocationPermission> Function()? requestPermissionFn;
  final Future<bool> Function()? isLocationServiceEnabledFn;
  final Future<Position> Function()? getCurrentPositionFn;

  /// Requests when-in-use location if needed.
  /// Throws [LocationUnavailableException] when denied / services off.
  Future<({double latitude, double longitude})> getCurrentLatLon({
    bool requestIfDenied = true,
  }) async {
    final serviceEnabled =
        await (isLocationServiceEnabledFn ?? Geolocator.isLocationServiceEnabled)();
    if (!serviceEnabled) {
      throw const LocationUnavailableException(
        'Location services are disabled',
        kind: LocationFailureKind.serviceDisabled,
      );
    }

    var permission =
        await (checkPermissionFn ?? Geolocator.checkPermission)();
    if (permission == LocationPermission.denied && requestIfDenied) {
      permission =
          await (requestPermissionFn ?? Geolocator.requestPermission)();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationUnavailableException(
        'Location permission denied',
        kind: LocationFailureKind.permissionDenied,
      );
    }

    final position = await (getCurrentPositionFn ??
        () => Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium,
              ),
            ))();

    return (latitude: position.latitude, longitude: position.longitude);
  }
}

enum LocationFailureKind {
  permissionDenied,
  serviceDisabled,
  unknown,
}

class LocationUnavailableException implements Exception {
  const LocationUnavailableException(
    this.message, {
    this.kind = LocationFailureKind.unknown,
  });

  final String message;
  final LocationFailureKind kind;

  @override
  String toString() => 'LocationUnavailableException: $message';
}
