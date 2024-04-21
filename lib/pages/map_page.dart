import 'package:flutter/material.dart';
import 'package:flutter_demo/components/navBar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Page'),
        // Buton de tip meniu pentru a activa harta
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              // Implementați aici deschiderea hărții Google Maps
            },
          ),
        ],
      ),
      drawer: NavBar(), // Adăugați bara de navigare în meniu
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _pGooglePlex,
            zoom: 13,
          ),
        ),
      ),
    );
  }
}
