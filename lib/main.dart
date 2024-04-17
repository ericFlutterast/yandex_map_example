import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: MapScreeen(),
        ),
      ),
    );
  }
}

class MapScreeen extends StatefulWidget {
  const MapScreeen({super.key});

  @override
  State<MapScreeen> createState() => _MapScreeenState();
}

class _MapScreeenState extends State<MapScreeen> {
  late final LocationService _locationService;
  late final Completer<YandexMapController> _mapControllerCompliter;

  @override
  void initState() {
    super.initState();

    _locationService = LocationService();
    _mapControllerCompliter = Completer<YandexMapController>();

    _initPermission().ignore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current geolocation'),
      ),
      body: YandexMap(
        onMapCreated: (controller) {
          _mapControllerCompliter.complete(controller);
        },
      ),
    );
  }

  Future<void> _initPermission() async {
    if (!await _locationService.checkPermission()) {
      await _locationService.requestPermission();
    }

    await _fechCurrentLocation();
  }

  Future<void> _fechCurrentLocation() async {
    late AppLatLong location;
    final defLocation = _locationService.defaultLocation;

    try {
      location = await LocationService().getCurrentLocation();
    } catch (_) {
      location = defLocation;
    }
    _moveToCurrentLocation(location: location);
  }

  Future<void> _moveToCurrentLocation({required final AppLatLong location}) async {
    //Достаем из компилера контроллер
    final mapContorller = await _mapControllerCompliter.future;

    //вызываем движение камеры
    mapContorller.moveCamera(
      //Анимация карты
      animation: const MapAnimation(
        type: MapAnimationType.linear,
        duration: 1,
      ),
      //Перемещение камеры
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: location.lat,
            longitude: location.long,
          ),
          zoom: 12,
        ),
      ),
    );
  }
}

//Модель координат
class AppLatLong {
  const AppLatLong({
    required this.lat,
    required this.long,
  });

  final double lat;
  final double long;
}

final class MoscowLocation extends AppLatLong {
  MoscowLocation({
    super.lat = 55.7522200,
    super.long = 37.6155600,
  });
}

abstract interface class AppLocation {
  Future<AppLatLong> getCurrentLocation();

  Future<bool> requestPermission();

  Future<bool> checkPermission();
}

final class LocationService implements AppLocation {
  LocationService() : _defaultLocation = MoscowLocation();

  final AppLatLong _defaultLocation;

  AppLatLong get defaultLocation => _defaultLocation;

  ///проверяет, разрешил ли пользователь доступ к геопозиции устройства
  @override
  Future<bool> checkPermission() async {
    final permission = await Geolocator.checkPermission();

    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  ///для определения текущей геопозиции (широта и долгота)
  @override
  Future<AppLatLong> getCurrentLocation() async {
    try {
      final currentPosition = await Geolocator.getCurrentPosition();
      return AppLatLong(
        lat: currentPosition.latitude,
        long: currentPosition.longitude,
      );
    } catch (_) {
      return defaultLocation;
    }
  }

  ///для запроса на разрешение использования сервиса местоположения
  @override
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();

    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }
}
