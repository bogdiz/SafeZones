import 'package:flutter/material.dart';
import 'package:flutter_demo/components/incidents_options.dart';
import 'package:flutter_demo/components/navBar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Map Page'),
        // Buton de tip meniu pentru a activa harta
      ),
      drawer: NavBar(),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(44.439663, 26.096306),
              zoom: 13,
            ),
            markers: markers,
            onTap: _onMapTapped,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  // Acțiuni când este apăsat butonul
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.blue, // Culoare buton
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapTapped(LatLng location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OptionsPage(),
      ),
    ).then((selectedData) {
      if (selectedData != null) {
        String category = selectedData['category'];
        String description = selectedData['description'];

        setState(() {
          markers.add(
            Marker(
              markerId: MarkerId(location.toString()),
              position: location,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                category == 'Medium' ? BitmapDescriptor.hueYellow : BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(title: description),
            ),
          );
        });
      }
    });
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId("current_position"),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(title: "Your Location"),
          ),
        );
      });
    } catch (e) {
      print("Error: $e");
    }
  }
}
