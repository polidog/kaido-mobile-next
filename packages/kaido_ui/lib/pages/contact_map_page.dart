import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Fallback camera location when no initial location is provided (Tokyo
/// Station).
const LatLng _fallbackLocation = LatLng(35.6812, 139.7671);

/// Contact location picker screen (`/contact/map`).
class ContactMapPage extends StatefulWidget {
  /// Creates a [ContactMapPage].
  const ContactMapPage({this.initialLocation, super.key});

  /// The previously selected location, if any.
  final LatLng? initialLocation;

  @override
  State<ContactMapPage> createState() => _ContactMapPageState();
}

class _ContactMapPageState extends State<ContactMapPage> {
  LatLng? _selectedLatLng;

  @override
  void initState() {
    super.initState();
    _selectedLatLng = widget.initialLocation;
  }

  void _handleTap(LatLng latLng) {
    setState(() => _selectedLatLng = latLng);
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = widget.initialLocation ?? _fallbackLocation;
    return Scaffold(
      appBar: AppBar(title: const Text('位置選択')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialTarget,
          zoom: 14,
        ),
        onTap: _handleTap,
        markers: {
          if (_selectedLatLng != null)
            Marker(
              markerId: const MarkerId('selected'),
              position: _selectedLatLng!,
            ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedLatLng == null
            ? null
            : () => context.pop(_selectedLatLng),
        child: const Icon(Icons.check),
      ),
    );
  }
}
