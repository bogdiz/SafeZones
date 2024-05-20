//import 'dart:html';

import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/components/incidents_options.dart';
import 'package:flutter_demo/components/navBar.dart';
import 'package:flutter_demo/pages/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../components/point.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> _markers = {};
  Position? _location;
  Timer? _timer;
  String? _mapStyle;
  final Completer<GoogleMapController> _mapController = Completer();
  
  Future<void> _fetchMarkers() async {
      // Fetch markers from backend
      List<Point> points = await _getMarkersFromBackend();

      List<Future<BitmapDescriptor>> futures = points.map((point) {
        String assetPath = point.category == 'Medium' ? "assets/images/_yellow.png" : "assets/images/_red.png";
        return BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(100, 100)), assetPath);
      }).toList();

      // Așteaptă finalizarea tuturor viitorilor
      List<BitmapDescriptor> icons = await Future.wait(futures);

      // Creează un set de markere folosind imaginile obținute
      Set<Marker> newMarkers = Set<Marker>.from(points.asMap().entries.map((entry) {
        int index = entry.key;
        Point point = entry.value;

        final timeDifference = DateTime.now().difference(point.timestamp);
        final timeAgo = _formatTimeAgo(timeDifference);

        return Marker(
            markerId: MarkerId(point.id.toString()),
            position: LatLng(double.parse(point.latitude), double.parse(point.longitude)),
            icon: icons[index],
            infoWindow: InfoWindow(
              title: '${point.description}',
              snippet: "\n$timeAgo",
            ),
);
      }));

      // Actualizează starea cu noile markere
      setState(() {
        _markers = newMarkers;
      });
}

String _formatTimeAgo(Duration duration) {
  if (duration.inDays > 0) {
    return 'Placed ${duration.inDays} days ago';
  } else if (duration.inHours > 0) {
    return 'Placed ${duration.inHours} hours ago';
  } else if (duration.inMinutes > 0) {
    return 'Placed ${duration.inMinutes} minutes ago';
  } else {
    return 'Placed just now';
  }
}


  @override
  void initState() {
    super.initState();
    _fetchMarkers();
    _getCurrentLocation();
    _startFetchingMarkers();
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
                zoom: 1,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
                if (_mapStyle != null) {
                controller.setMapStyle(_mapStyle);
              }
              },
              //onTap: loadPoints(context),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: FloatingActionButton(
                  onPressed: () {
                    _onMapTapped();
                    // Acțiuni când este apăsat butonul
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Color.fromARGB(255, 233, 63, 63), // Culoare buton
                  foregroundColor: Colors.white,
                  elevation: 3,
                  //shape: CircleBorder(),
                  
                ),
              ),
            ),
          ],
        ),
      );
  }

  void _startFetchingMarkers() {
  _timer = Timer.periodic(Duration(seconds: 2), (timer) {
    _fetchMarkers();
  });
}
  void _onMapTapped() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OptionsPage(),
      ),
    ).then((selectedData) async {
      if (selectedData != null) {
        String category = selectedData['category'];
        String description = selectedData['description'];

        try {
          _getCurrentLocation();
          addPointToUser(_location!.latitude, _location!.longitude, description, category);
          _fetchMarkers();
          
          /*setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId("current_position"),
                position: LatLng(_location!.latitude, _location!.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  category == 'Medium' ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueRed,
                ),
                infoWindow: InfoWindow(title: description),
              ),
            );
          });
          */
          
        } catch (e) {
          print("Error: $e");
        }
      }
    });
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _location = position;
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> addPointToUser(double latitude, double longitude, String description, String category) async {
  // print("${category}");
  final response = await http.post(
    Uri.parse('$baseURL/points/add'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "description": description,
      "category": category,
      "userId": FirebaseAuth.instance.currentUser!.uid,
    }),
  );

  if (response.statusCode == 200) {
    print('Point added successfully');
  } else {
    print('Failed to add point');
  }
}

   Future<List<Point>> _getMarkersFromBackend() async {
  final response = await http.get(Uri.parse('$baseURL/points/all'));

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);

    return jsonResponse.map((pointJson) {
      // Ensure that the json map has all required keys
      return Point.fromJson(pointJson as Map<String, dynamic>);
    }).toList();
  } else {
    throw Exception('Failed to load points');
  }
}

   
}
