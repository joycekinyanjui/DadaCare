import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../service.dart';

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({super.key});

  @override
  State<NearbyHospitalsScreen> createState() => _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen>
    with SingleTickerProviderStateMixin {
  late GoogleMapController mapController;
  LatLng? _userLocation;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _hospitals = [];
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    Position pos = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _userLocation = LatLng(pos.latitude, pos.longitude);
    });
    fetchNearby();
  }

  Future<void> fetchNearby() async {
    if (_userLocation == null) return;
    final service = GoogleMapsService();
    final results = await service.searchNearbyHospitals(
      _userLocation!.latitude,
      _userLocation!.longitude,
    );

    List<Map<String, dynamic>> hospitalsWithDistance = [];
    Set<Marker> loadedMarkers = {};

    for (var place in results) {
      final lat = place['geometry']['location']['lat'];
      final lng = place['geometry']['location']['lng'];
      final name = place['name'];
      final rating = place['rating']?.toString() ?? "N/A";

      final distanceInfo = await service.getDistanceAndTime(
        _userLocation!.latitude,
        _userLocation!.longitude,
        lat,
        lng,
      );

      hospitalsWithDistance.add({
        'name': name,
        'lat': lat,
        'lng': lng,
        'distance': distanceInfo['distance'],
        'duration': distanceInfo['duration'],
        'place_id': place['place_id'],
        'rating': rating,
      });

      loadedMarkers.add(
        Marker(
          markerId: MarkerId(place['place_id']),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: name,
            snippet:
                "Distance: ${distanceInfo['distance']}, Time: ${distanceInfo['duration']}",
          ),
        ),
      );
    }

    hospitalsWithDistance.sort((a, b) {
      double distA =
          double.tryParse(a['distance'].replaceAll(RegExp(r'[^0-9.]'), '')) ??
          0;
      double distB =
          double.tryParse(b['distance'].replaceAll(RegExp(r'[^0-9.]'), '')) ??
          0;
      return distA.compareTo(distB);
    });

    setState(() {
      _hospitals = hospitalsWithDistance;
      _markers = loadedMarkers;
    });

    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Hospitals & Clinics"),
        backgroundColor: const Color.fromARGB(255, 128, 178, 235),
      ),
      body:
          _userLocation == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: _userLocation!,
                        zoom: 13,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return ListView.builder(
                          itemCount: _hospitals.length,
                          itemBuilder: (context, index) {
                            final hospital = _hospitals[index];
                            return FadeTransition(
                              opacity: _animController,
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.local_hospital,
                                    color: Color.fromARGB(255, 58, 102, 183),
                                  ),
                                  title: Text(
                                    hospital['name'],
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Rating: ${hospital['rating']}",
                                        style: GoogleFonts.montserrat(),
                                      ),
                                      Text(
                                        "${hospital['distance']} - ${hospital['duration']}",
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    mapController.animateCamera(
                                      CameraUpdate.newLatLng(
                                        LatLng(
                                          hospital['lat'],
                                          hospital['lng'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
