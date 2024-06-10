// Import necessary Dart and Flutter packages
import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../components/info_panel.dart';
import 'package:http/http.dart' as http;

import '../components/point.dart';
import '../components/incidents_options.dart';
import '../components/navBar.dart';
import '../pages/constants.dart';

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

  bool _isInfoPanelVisible = false;
  Point? _selectedPoint;

  void _onMarkerTapped(Point point) {
    setState(() {
      _selectedPoint = point;
      _isInfoPanelVisible = true;
    });
  }

  void _hidePanel() {
    setState(() {
      _isInfoPanelVisible = false;
    });
  }

  void _likePoint() {
    print("Liked ${_selectedPoint?.description}");
  }

  Future<void> _fetchMarkers() async {
    try {
      List<Point> points = await _getMarkersFromBackend();
      List<Future<BitmapDescriptor>> futures = points.map((point) {
        String assetPath = point.category == 'Medium'
            ? "assets/images/_yellow.png"
            : "assets/images/_red.png";
        return BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(100, 100)), assetPath);
      }).toList();
      List<BitmapDescriptor> icons = await Future.wait(futures);
      Set<Marker> newMarkers =
          Set<Marker>.from(points.asMap().entries.map((entry) {
        int index = entry.key;
        Point point = entry.value;
        final timeDifference = DateTime.now().difference(point.timestamp);
        final timeAgo = _formatTimeAgo(timeDifference);
        return Marker(
          markerId: MarkerId(point.id.toString()),
          position: LatLng(
              double.parse(point.latitude), double.parse(point.longitude)),
          icon: icons[index],
          onTap: () => _onMarkerTapped(point),
        );
      }));
      setState(() {
        _markers = newMarkers;
      });
    } catch (e) {
      print('Error fetching markers: $e');
    }
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
      appBar: AppBar(),
      drawer: NavBar(),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: LatLng(44.439663, 26.096306), zoom: 12),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
              if (_mapStyle != null) {
                controller.setMapStyle(_mapStyle);
              }
            },
            onTap: (LatLng position) {
              if (_isInfoPanelVisible) {
                _hidePanel();
              }
            },
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
                backgroundColor: Colors.blue.shade500, // Culoare buton
                foregroundColor: Colors.white,
                elevation: 3,
                //shape: CircleBorder(),
              ),
            ),
          ),
          if (_isInfoPanelVisible && _selectedPoint != null)
            InfoPanel(
              point: _selectedPoint!,
              onClose: _hidePanel,
            ),
        ],
      ),
    );
  }

  void _startFetchingMarkers() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) => _fetchMarkers());
  }

  void _onMapTapped() async {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => OptionsPage()))
        .then((selectedData) async {
      if (selectedData != null) {
        String category = selectedData['category'];
        String description = selectedData['description'];
        String event = selectedData['event'];
        try {
          _getCurrentLocation();
          addPointToUser(_location!.latitude, _location!.longitude, description,
              category, event);
          _fetchMarkers();
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

  Future<void> addPointToUser(double latitude, double longitude,
      String description, String category, String event) async {
    final response = await http.post(
      Uri.parse('${baseURL}/points/add'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "description": description,
        "category": category,
        "event": event,
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
    final response = await http.get(Uri.parse('${baseURL}/points/all'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((pointJson) => Point.fromJson(pointJson))
          .toList();
    } else {
      throw Exception('Failed to load points');
    }
  }
}
