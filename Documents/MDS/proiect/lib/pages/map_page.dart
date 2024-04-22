import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'incidents_list.dart';
import 'package:flutter_demo/components/navBar.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> markers = {}; // Set pentru a stoca toți markerii

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Obțineți locația actuală la inițializare
  }

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
            target:  LatLng(44.439663, 26.096306),
            zoom: 13,
          ),
          markers: markers,
          onTap: _onMapTapped, // Adăugați un listener pentru evenimentul de click pe hartă
        ),
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
          // Adăugați un marker la locația unde a fost făcut clic
          markers.add(
            Marker(
              markerId: MarkerId(location.toString()),
              position: location,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                category == 'Medium' ? BitmapDescriptor.hueYellow : BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(title: description), // Utilizați descrierea ca titlu al ferestrei de informații
            ),
          );
        });
      }
    });
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high); // Obțineți locația actuală

      setState(() {
        // Adăugați un marker la locația actuală
        markers.add(
          Marker(
            markerId: MarkerId("current_position"),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Iconița pentru locația actuală
            infoWindow: InfoWindow(title: "Your Location"), // Fereastră de informații pentru marker
          ),
        );
      });
    } catch (e) {
      print("Error: $e");
    }
  }
}
