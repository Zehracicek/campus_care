import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/services/location_service.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerWidget extends StatefulWidget {
  final LocationData? initialLocation;
  final Function(LocationData) onLocationSelected;

  const LocationPickerWidget({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  bool _isLoading = false;
  String? _selectedAddress;

  // Default location (Turkey - Ankara)
  static const LatLng _defaultLocation = LatLng(39.9334, 32.8597);

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedPosition = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _selectedAddress = widget.initialLocation!.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Konum Seç',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_selectedPosition != null)
                    TextButton(
                      onPressed: _confirmLocation,
                      child: const Text(
                        'ONAYLA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Map
          Expanded(
            child: Stack(
              children: [
                // OpenStreetMap
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedPosition ?? _defaultLocation,
                    initialZoom: 15.0,
                    onTap: (tapPosition, point) => _onMapTap(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.campus_care',
                      maxNativeZoom: 19,
                      maxZoom: 19,
                    ),
                    MarkerLayer(
                      markers: _selectedPosition != null
                          ? [
                              Marker(
                                point: _selectedPosition!,
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.location_on,
                                  color: AppTheme.primaryColor,
                                  size: 50,
                                ),
                              ),
                            ]
                          : [],
                    ),
                  ],
                ),

                // Address card at top
                if (_selectedAddress != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedAddress!,
                                style: context.textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Current location button
                Positioned(
                  bottom: 80,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _getCurrentLocation,
                    backgroundColor: Colors.white,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.my_location, color: AppTheme.primaryColor),
                  ),
                ),

                // Instructions card at bottom
                if (_selectedPosition == null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Harita üzerinde bir konum seçin veya mevcut konumunuzu kullanın',
                                style: context.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onMapTap(LatLng position) async {
    setState(() {
      _selectedPosition = position;
      _selectedAddress = null; // Clear while loading
    });

    // Get address for the selected position
    try {
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _selectedAddress = address ?? 'Adres bulunamadı';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedAddress =
              'Koordinat: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final location = await _locationService.getCurrentLocation();

      if (mounted) {
        setState(() {
          _selectedPosition = LatLng(location.latitude, location.longitude);
          _selectedAddress = location.address ?? 'Mevcut konumunuz';
          _isLoading = false;
        });

        // Move camera to current location
        _mapController.move(
          LatLng(location.latitude, location.longitude),
          15.0,
        );

        context.showSuccessToast('Konum alındı');
      }
    } on LocationServiceException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.showErrorToast(e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.showErrorToast('Konum alınırken hata oluştu: $e');
      }
    }
  }

  void _confirmLocation() {
    if (_selectedPosition != null) {
      final locationData = LocationData(
        latitude: _selectedPosition!.latitude,
        longitude: _selectedPosition!.longitude,
        address: _selectedAddress,
      );
      widget.onLocationSelected(locationData);
    }
  }
}
