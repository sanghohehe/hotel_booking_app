import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class MapLocationPicker extends StatefulWidget {
  const MapLocationPicker({super.key});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  LatLng _pickedLocation = const LatLng(10.762622, 106.660172);
  String _address = "Chạm vào bản đồ để chọn vị trí";

  Future<void> _getAddress(LatLng loc) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        loc.latitude,
        loc.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address =
              "${place.street}, ${place.subAdministrativeArea}, ${place.administrativeArea}";
        });
      }
    } catch (e) {
      setState(
        () =>
            _address =
                "Tọa độ: ${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chọn vị trí (OSM)")),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _pickedLocation,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() => _pickedLocation = point);
                _getAddress(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.booking_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickedLocation,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _address,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed:
                          () => Navigator.pop(context, {
                            'loc': _pickedLocation,
                            'addr': _address,
                          }),
                      child: const Text("XÁC NHẬN VỊ TRÍ"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
