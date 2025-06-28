import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<String> knownHospitalsWithPrices = []; // from Flask
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
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _userLocation = LatLng(pos.latitude, pos.longitude);
    });
    await fetchKnownHospitals(); // get from Flask
    fetchNearby();
  }

  Future<void> fetchKnownHospitals() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.92.41:5000/hospitals"),
      ); // adapt to emulator if needed
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          knownHospitalsWithPrices = List<String>.from(data);
        });
      }
    } catch (e) {
      debugPrint("Error fetching from Flask: $e");
    }
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

      // check if in knownHospitalsWithPrices from Flask
      bool hasPrices = knownHospitalsWithPrices.contains(name);

      loadedMarkers.add(
        Marker(
          markerId: MarkerId(place['place_id']),
          position: LatLng(lat, lng),
          icon:
              hasPrices
                  ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  )
                  : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
          infoWindow: InfoWindow(
            title: name,
            snippet:
                "Distance: ${distanceInfo['distance']}, Time: ${distanceInfo['duration']}",
            onTap: () {
              if (hasPrices) {
                // route to prices page (to do)
              }
            },
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
        backgroundColor: const Color.fromARGB(255, 126, 169, 235),
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
                            bool hasPrices = knownHospitalsWithPrices.contains(
                              hospital['name'],
                            );
                            return FadeTransition(
                              opacity: _animController,
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                color:
                                    hasPrices ? Colors.blue[50] : Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.local_hospital,
                                    color: hasPrices ? Colors.blue : Colors.red,
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
                                    if (hasPrices) {
                                      // route to pricing page later
                                    } else {
                                      mapController.animateCamera(
                                        CameraUpdate.newLatLng(
                                          LatLng(
                                            hospital['lat'],
                                            hospital['lng'],
                                          ),
                                        ),
                                      );
                                    }
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
