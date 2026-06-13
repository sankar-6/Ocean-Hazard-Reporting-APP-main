import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';

class MapPickerScreen extends StatefulWidget {
  final Position? initialPosition;
  final String? initialAddress;

  const MapPickerScreen({super.key, this.initialPosition, this.initialAddress});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  String? _selectedAddress;
  bool _isLoading = false;
  bool _isGettingAddress = false;
  Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  List<Placemark> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchDebounce;
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    // Add a small delay before initializing to let the widget tree stabilize
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    print('🗺️ Starting map initialization...');
    try {
      // Longer delay to allow system to stabilize
      await Future.delayed(const Duration(milliseconds: 2000));
      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 1000));
      }
      print('🗺️ Map initialization delay completed');

      if (widget.initialPosition != null) {
        print(
          '🗺️ Using initial position: ${widget.initialPosition!.latitude}, ${widget.initialPosition!.longitude}',
        );
        _selectedPosition = LatLng(
          widget.initialPosition!.latitude,
          widget.initialPosition!.longitude,
        );
        _selectedAddress = widget.initialAddress;
        _updateMarkers();
      } else {
        print('🗺️ Getting current location...');
        // Get current location as default
        await _getCurrentLocation();
      }
      print('🗺️ Map initialization completed successfully');
    } catch (e) {
      print('❌ Map initialization error: $e');
      if (mounted) {
        // Check if it's a billing error
        if (e.toString().contains('BillingNotEnabledMapError')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Google Maps requires billing to be enabled. Please enable billing in Google Cloud Console or use a different API key.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to initialize map: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
      });
      _updateMarkers();
      await _getAddressFromPosition(_selectedPosition!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get current location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getAddressFromPosition(LatLng position) async {
    if (!mounted) return;

    setState(() => _isGettingAddress = true);

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = _formatAddress(placemark);

        if (mounted) {
          setState(() => _selectedAddress = address);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _selectedAddress = 'Address not available');
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingAddress = false);
      }
    }
  }

  String _formatAddress(Placemark placemark) {
    final parts = <String>[];

    // Street address (house number + street name)
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }

    // City/Locality
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }

    // State/Province
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }

    // Postal code
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      parts.add(placemark.postalCode!);
    }

    // Country
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      parts.add(placemark.country!);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Address not available';
  }

  void _updateMarkers() {
    if (_selectedPosition != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: _selectedPosition!,
            infoWindow: InfoWindow(
              title: 'Selected Location',
              snippet: _selectedAddress ?? 'Getting address...',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        };
      });
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _updateMarkers();
    _getAddressFromPosition(position);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapInitialized = true;
    print('🗺️ Map controller created successfully');
  }

  Future<void> _centerOnSelectedLocation() async {
    if (_mapController != null && _selectedPosition != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLng(_selectedPosition!),
      );
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
      return;
    }

    if (!mounted) return;

    setState(() => _isSearching = true);

    try {
      final locations = await locationFromAddress(query);

      if (!mounted) return;

      if (locations.isNotEmpty) {
        final placemarks = await placemarkFromCoordinates(
          locations.first.latitude,
          locations.first.longitude,
        );

        if (!mounted) return;

        setState(() {
          _searchResults = placemarks;
        });

        // Move camera to the first result
        final location = locations.first;
        final newPosition = LatLng(location.latitude, location.longitude);

        setState(() {
          _selectedPosition = newPosition;
        });

        _updateMarkers();
        await _getAddressFromPosition(newPosition);

        if (_mapController != null && mounted) {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(newPosition, 15.0),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _searchResults = [];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location not found. Please try a different search term.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _selectSearchResult(Placemark placemark) async {
    if (!mounted) return;

    // Get coordinates from the placemark
    final locations = await locationFromAddress(_formatAddress(placemark));

    if (!mounted) return;

    if (locations.isNotEmpty) {
      final location = locations.first;
      setState(() {
        _selectedPosition = LatLng(location.latitude, location.longitude);
        _selectedAddress = _formatAddress(placemark);
        _searchResults = [];
      });

      _updateMarkers();

      if (_mapController != null && mounted) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedPosition!, 15.0),
        );
      }
    }
  }

  void _confirmSelection() {
    if (_selectedPosition != null) {
      final position = Position(
        latitude: _selectedPosition!.latitude,
        longitude: _selectedPosition!.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      Navigator.of(
        context,
      ).pop({'position': position, 'address': _selectedAddress});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailAppBar(
        title: 'Select Location',
        actions: [
          if (_isLoading || _isGettingAddress || _isSearching)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target:
                  _selectedPosition ??
                  const LatLng(37.7749, -122.4194), // San Francisco as default
              zoom: 15.0,
            ),
            onTap: _onMapTap,
            markers: _markers,
            myLocationEnabled: false, // Disable to reduce buffer usage
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            mapType: MapType.normal,
            buildingsEnabled: false, // Disable to reduce buffer usage
            compassEnabled: false, // Disable to reduce buffer usage
            liteModeEnabled: false,
            // Remove minMaxZoomPreference to reduce complexity
            onCameraMove: (CameraPosition position) {
              // Optional: Update selection as user moves the map
            },
          ),

          // Search bar
          Positioned(
            top: 16,
            left: 16,
            right: 80,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a location...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                onSubmitted: _searchLocation,
                onChanged: (value) {
                  if (value.trim().isEmpty) {
                    setState(() {
                      _searchResults = [];
                    });
                  } else {
                    // Debounce search to avoid too many API calls
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(
                      const Duration(milliseconds: 500),
                      () {
                        if (mounted) {
                          _searchLocation(value);
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ),

          // Current location button
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "map_picker_current_location",
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.my_location),
            ),
          ),

          // Search results dropdown
          if (_searchResults.isNotEmpty)
            Positioned(
              top: 80,
              left: 16,
              right: 80,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Search Results',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_searchResults.length} found',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._searchResults
                        .take(5)
                        .map(
                          (placemark) => ListTile(
                            leading: const Icon(
                              Icons.place,
                              color: Colors.grey,
                            ),
                            title: Text(
                              _formatAddress(placemark),
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: FutureBuilder<Location>(
                              future: locationFromAddress(
                                _formatAddress(placemark),
                              ).then((locations) => locations.first),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    '${snapshot.data!.latitude.toStringAsFixed(4)}, ${snapshot.data!.longitude.toStringAsFixed(4)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                }
                                return const Text(
                                  'Loading coordinates...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                            onTap: () => _selectSearchResult(placemark),
                            dense: true,
                          ),
                        ),
                  ],
                ),
              ),
            ),

          // Center on selection button
          Positioned(
            top: 80,
            right: 16,
            child: FloatingActionButton(
              heroTag: "map_picker_center",
              onPressed: _centerOnSelectedLocation,
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.center_focus_strong),
            ),
          ),

          // Selected location info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location info
                  if (_selectedPosition != null) ...[
                    // Address
                    Row(
                      children: [
                        Icon(
                          Icons.place,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedAddress ?? 'Getting address...',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                        ),
                        if (_isGettingAddress)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Coordinates
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.gps_fixed,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Coordinates',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_selectedPosition!.latitude.toStringAsFixed(6)}, ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey[700],
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Tap on the map to select a location',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedPosition != null
                              ? _confirmSelection
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Confirm Location'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading || !_mapInitialized)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading map...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
