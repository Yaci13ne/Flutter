import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const CampusLostFoundApp());
}

class CampusLostFoundApp extends StatelessWidget {
  const CampusLostFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Lost & Found',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          surface: const Color(0xFF0F0F23),
          primary: const Color(0xFF3B82F6),
        ),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

// ─── Data Model ──────────────────────────────────────────────────────────────

class LostFoundItem {
  final int id;
  final LatLng coords;
  final String status;
  final String label;
  final String category;
  final String description;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final DateTime timestamp;
  final String zone;

  const LostFoundItem({
    required this.id,
    required this.coords,
    required this.status,
    required this.label,
    required this.category,
    required this.description,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    required this.timestamp,
    required this.zone,
  });

  factory LostFoundItem.fromJson(Map<String, dynamic> json) {
    final c = (json['coords'] as List).cast<double>();
    return LostFoundItem(
      id: json['id'] as int,
      coords: LatLng(c[0], c[1]),
      status: json['status'] as String,
      label: json['label'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      contactName: json['contactName'] as String,
      contactPhone: json['contactPhone'] as String,
      contactEmail: json['contactEmail'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      zone: json['zone'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'coords': [coords.latitude, coords.longitude],
    'status': status,
    'label': label,
    'category': category,
    'description': description,
    'contactName': contactName,
    'contactPhone': contactPhone,
    'contactEmail': contactEmail,
    'timestamp': timestamp.toIso8601String(),
    'zone': zone,
  };

  String get emoji => label.split(' ').first;

  Color get statusColor {
    switch (status) {
      case 'lost':
        return const Color(0xFFE94560);
      case 'claimed':
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF3B82F6);
    }
  }
}

// ─── Custom Pin Model ─────────────────────────────────────────────────────────

class CustomPin {
  final int id;
  final LatLng coords;
  final String placeName; // auto-fetched from Nominatim

  const CustomPin({
    required this.id,
    required this.coords,
    required this.placeName,
  });
}

// ─── Nominatim Reverse Geocoding ─────────────────────────────────────────────

Future<String> reverseGeocode(LatLng coords) async {
  final uri = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse'
    '?format=jsonv2'
    '&lat=${coords.latitude}'
    '&lon=${coords.longitude}'
    '&zoom=18'
    '&addressdetails=1',
  );

  try {
    final res = await http.get(
      uri,
      headers: {'User-Agent': 'CampusLostFound/1.0'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>? ?? {};

      // Pick the most specific, human-readable name available
      final candidates = [
        data['name'],
        address['amenity'],
        address['building'],
        address['shop'],
        address['office'],
        address['tourism'],
        address['leisure'],
        address['road'],
        data['display_name'],
      ];
      final name = candidates
          .whereType<String>()
          .map((s) => s.trim())
          .firstWhere((s) => s.isNotEmpty, orElse: () => '');

      if (name.isNotEmpty) return name;
    }
  } catch (_) {}
  // Fallback: show coordinates like Google Maps
return _toDMS(coords.latitude, coords.longitude);
}
String _toDMS(double lat, double lng) {
  String _format(double value, String posDir, String negDir) {
    final dir = value >= 0 ? posDir : negDir;
    final abs = value.abs();
    final deg = abs.truncate();
    final minFull = (abs - deg) * 60;
    final min = minFull.truncate();
    final sec = (minFull - min) * 60;
    return "$deg°${min.toString().padLeft(2, '0')}'${sec.toStringAsFixed(1).padLeft(4, '0')}\"$dir";
  }

  return '${_format(lat, 'N', 'S')} ${_format(lng, 'E', 'W')}';
}

// ─── Map Screen ──────────────────────────────────────────────────────────────

class MapScreen extends StatefulWidget {
  /// When true, dropping a pin pops the route and returns the place name.
  final bool returnResult;
  const MapScreen({super.key, this.returnResult = false});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LostFoundItem> _items = [];
  List<CustomPin> _customPins = [];
  bool _pinModeActive = false;
  bool _isLoading = false;
  int _pinIdCounter = 1000;

  static const LatLng _campusCenter = LatLng(34.8970, -1.3510);
  static final LatLngBounds _campusBounds = LatLngBounds(
    const LatLng(34.8940, -1.3540),
    const LatLng(34.9000, -1.3480),
  );

  // ── Tap handler ──────────────────────────────────────────────────────────────

  Future<void> _onMapTap(TapPosition tapPos, LatLng latlng) async {
    if (!_pinModeActive) return;

    // Immediately lock pin mode so no more taps register
    setState(() {
      _pinModeActive = false;
      _isLoading = true;
    });

    final name = await reverseGeocode(latlng);

    if (widget.returnResult) {
      // Return the place name to the calling screen
      if (mounted) Navigator.of(context).pop(name);
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = false;
      // Replace any existing pin — only one pin at a time
      _customPins = [
        CustomPin(id: _pinIdCounter++, coords: latlng, placeName: name),
      ];
    });
  }

  // ── Pin detail bottom sheet ───────────────────────────────────────────────────

  void _showPinDetail(CustomPin pin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_pin,
                    color: Color(0xFFFFD700),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pin.placeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white38,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(
                        () => _customPins.removeWhere((p) => p.id == pin.id),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${pin.coords.latitude.toStringAsFixed(5)}, ${pin.coords.longitude.toStringAsFixed(5)}',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _campusCenter,
              initialZoom: 17,
              minZoom: 16,
              maxZoom: 19,
              cameraConstraint: CameraConstraint.containCenter(
                bounds: _campusBounds,
              ),
              onTap: _onMapTap,
            ),
            children: [
        TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.campus.lostfound',
                additionalOptions: const {
                  'User-Agent': 'CampusLostFound/1.0 (your@email.com)',
                },
              ),
              MarkerLayer(markers: _items.map(_buildMarker).toList()),
              MarkerLayer(
                markers: _customPins.map(_buildCustomPinMarker).toList(),
              ),
            ],
          ),

          // ── Instruction banner ────────────────────────────────────────────
          if (_pinModeActive)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.touch_app,
                        color: Color(0xFFFFD700),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Tap a building or place to pin it',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _pinModeActive = false),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFFFFD700),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Loading overlay while reverse geocoding ───────────────────────
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFFFD700)),
                    SizedBox(height: 12),
                    Text(
                      'Reading place name…',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

          // ── FAB ──────────────────────────────────────────────────────────
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () => setState(() => _pinModeActive = !_pinModeActive),
              backgroundColor: _pinModeActive
                  ? const Color(0xFFFFD700)
                  : const Color(0xFF3B82F6),
              foregroundColor: _pinModeActive ? Colors.black : Colors.white,
              icon: Icon(_pinModeActive ? Icons.close : Icons.push_pin),
              label: Text(_pinModeActive ? 'Cancel' : 'Pin Place'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Marker builders ───────────────────────────────────────────────────────────

  Marker _buildMarker(LostFoundItem item) {
    return Marker(
      point: item.coords,
      width: 36,
      height: 36,
      child: GestureDetector(
        onTap: () => _showPopup(item),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            boxShadow: [
              BoxShadow(
                color: item.statusColor.withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(item.emoji, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  /// Gold pin with the place name written directly below it on the map.
  Marker _buildCustomPinMarker(CustomPin pin) {
    return Marker(
      point: pin.coords,
      width: 150,
      height: 80,
      alignment: const Alignment(0, 1), // anchor tip of pin at the tapped point
      child: GestureDetector(
        onTap: () => _showPinDetail(pin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Place name label sits above the pin icon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withOpacity(0.93),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                pin.placeName,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            // Gold location pin pointing down to the exact spot
            const Icon(Icons.location_pin, color: Color(0xFFFFD700), size: 32),
          ],
        ),
      ),
    );
  }

  void _showPopup(LostFoundItem item) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemPopup(item: item, formatter: fmt),
    );
  }
}

// ─── Item Popup ──────────────────────────────────────────────────────────────

class _ItemPopup extends StatelessWidget {
  const _ItemPopup({required this.item, required this.formatter});

  final LostFoundItem item;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.statusColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: item.statusColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label.replaceFirst('${item.emoji} ', ''),
                        style: TextStyle(
                          color: item.statusColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.zone,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: item.statusColor.withOpacity(0.6),
                    ),
                  ),
                  child: Text(
                    _capitalize(item.status),
                    style: TextStyle(
                      color: item.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
