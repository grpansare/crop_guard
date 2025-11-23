import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:crop_disease_app/models/agri_store.dart';
import 'package:crop_disease_app/services/agri_store_service.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class FarmerAgriStoresMapScreen extends StatefulWidget {
  const FarmerAgriStoresMapScreen({super.key});

  @override
  State<FarmerAgriStoresMapScreen> createState() =>
      _FarmerAgriStoresMapScreenState();
}

class _FarmerAgriStoresMapScreenState extends State<FarmerAgriStoresMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  List<AgriStore> _nearbyStores = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String _errorMessage = '';
  double _radiusKm = 10.0;
  AgriStore? _selectedStore;

  // Default location (India center)
  final LatLng _defaultLocation = const LatLng(20.5937, 78.9629);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them.';
          _isLoading = false;
        });
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permissions are permanently denied. Please enable them in settings.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Move camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14,
        ),
      );

      // Load nearby stores
      await _loadNearbyStores();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNearbyStores() async {
    if (_currentPosition == null) {
      setState(() {
        _errorMessage = 'Location not available';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final stores = await AgriStoreService.getNearbyStores(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _radiusKm,
        token,
      );

      setState(() {
        _nearbyStores = stores;
        _updateMarkers();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load stores: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    // Add markers for each store
    for (var store in _nearbyStores) {
      markers.add(
        Marker(
          markerId: MarkerId('store_${store.id}'),
          position: LatLng(store.latitude, store.longitude),
          icon: _getMarkerIcon(store.storeType),
          infoWindow: InfoWindow(
            title: store.name,
            snippet: '${store.storeTypeDisplay} • ${store.distanceDisplay}',
            onTap: () => _showStoreDetails(store),
          ),
          onTap: () => _showStoreDetails(store),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  BitmapDescriptor _getMarkerIcon(String storeType) {
    // In a real app, you would use custom icons for different store types
    // For now, using default marker
    return BitmapDescriptor.defaultMarkerWithHue(
      _getMarkerColor(storeType),
    );
  }

  double _getMarkerColor(String storeType) {
    switch (storeType) {
      case 'SEEDS':
        return BitmapDescriptor.hueGreen;
      case 'FERTILIZERS':
        return BitmapDescriptor.hueOrange;
      case 'PESTICIDES':
        return BitmapDescriptor.hueRed;
      case 'EQUIPMENT':
        return BitmapDescriptor.hueBlue;
      default:
        return BitmapDescriptor.hueViolet;
    }
  }

  void _showStoreDetails(AgriStore store) {
    setState(() {
      _selectedStore = store;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildStoreDetailsSheet(store),
    );
  }

  Widget _buildStoreDetailsSheet(AgriStore store) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name and Type
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Colors.deepPurple,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              store.storeTypeDisplay,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Distance
                  if (store.distance != null)
                    _buildInfoRow(
                      Icons.location_on,
                      'Distance',
                      store.distanceDisplay,
                      Colors.blue,
                    ),

                  // Address
                  _buildInfoRow(
                    Icons.map,
                    'Address',
                    store.address,
                    Colors.green,
                  ),

                  // Contact
                  if (store.contactNumber != null)
                    _buildInfoRow(
                      Icons.phone,
                      'Contact',
                      store.contactNumber!,
                      Colors.orange,
                    ),

                  // Owner
                  if (store.ownerName != null)
                    _buildInfoRow(
                      Icons.person,
                      'Owner',
                      store.ownerName!,
                      Colors.purple,
                    ),

                  // Description
                  if (store.description != null &&
                      store.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      store.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Get Directions Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openGoogleMaps(store),
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGoogleMaps(AgriStore store) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${store.latitude},${store.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Agri Stores'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _initializeLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    )
                  : _defaultLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            circles: _currentPosition != null
                ? {
                    Circle(
                      circleId: const CircleId('search_radius'),
                      center: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      radius: _radiusKm * 1000, // Convert km to meters
                      fillColor: Colors.deepPurple.withOpacity(0.1),
                      strokeColor: Colors.deepPurple,
                      strokeWidth: 2,
                    ),
                  }
                : {},
          ),

          // Loading Indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Error Message
          if (_errorMessage.isNotEmpty && !_isLoading)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _errorMessage = '';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Radius Slider
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Search Radius: ${_radiusKm.toStringAsFixed(0)} km',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_nearbyStores.length} stores',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _radiusKm,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: '${_radiusKm.toStringAsFixed(0)} km',
                      activeColor: Colors.deepPurple,
                      onChanged: (value) {
                        setState(() {
                          _radiusKm = value;
                        });
                      },
                      onChangeEnd: (value) {
                        _loadNearbyStores();
                      },
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
