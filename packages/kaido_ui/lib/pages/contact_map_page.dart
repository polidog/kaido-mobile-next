import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Fallback camera location when no initial location is provided (Tokyo
/// Station).
const LatLng _fallbackLocation = LatLng(35.6812, 139.7671);

/// Size of the center pin icon.
const double _pinSize = 48;

/// Contact location picker screen (`/contact/map`).
///
/// A pin is fixed at the center of the screen; the user pans the map to
/// place the pin on the desired location and confirms with the check
/// button.
class ContactMapPage extends StatefulWidget {
  /// Creates a [ContactMapPage].
  const ContactMapPage({this.initialLocation, super.key});

  /// The previously selected location, if any.
  final LatLng? initialLocation;

  @override
  State<ContactMapPage> createState() => _ContactMapPageState();
}

class _ContactMapPageState extends State<ContactMapPage> {
  late LatLng _center;

  @override
  void initState() {
    super.initState();
    _center = widget.initialLocation ?? _fallbackLocation;
  }

  void _handleCameraMove(CameraPosition position) {
    _center = position.target;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('位置選択')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 14),
            onCameraMove: _handleCameraMove,
          ),
          // Center pin: translated up by half its height so the pin tip
          // points at the exact center of the map.
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: _pinSize),
                child: Icon(
                  Icons.location_on,
                  size: _pinSize,
                  color: Colors.red,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pop(_center),
        child: const Icon(Icons.check),
      ),
    );
  }
}
