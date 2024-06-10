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

class InfoPanel extends StatefulWidget {
  final Point point;
  final VoidCallback onClose;

  InfoPanel({Key? key, required this.point, required this.onClose})
      : super(key: key);

  @override
  _InfoPanelState createState() => _InfoPanelState();
}

class _InfoPanelState extends State<InfoPanel> {
  int _voteCount = 0;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _voteCount = widget.point.votes;
    _fetchCurrentVotes();
    _fetchCurrentUserId();
  }

  Future<void> _fetchCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  Future<void> _fetchCurrentVotes() async {
    try {
      final response = await http.get(
        Uri.parse('${baseURL}/points/votes/${widget.point.id}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _voteCount = int.parse(response
              .body); // Assuming the body directly contains the vote count
        });
      } else {
        throw Exception('Failed to load votes');
      }
    } catch (e) {
      print('Error fetching votes: $e');
    }
  }

  Future<void> _incrementVotes() async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseURL/points/incrementVotes/${widget.point.id}/${_currentUserId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        _fetchCurrentVotes(); // Refresh the vote count after incrementing
      } else {
        throw Exception('Failed to increment votes: ${response.body}');
      }
    } catch (e) {
      print('Error incrementing votes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentUserPoint = _currentUserId == widget.point.userId;

    return Positioned(
      bottom: 50,
      left: 10,
      right: 10,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(widget.point.event,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 5),
              Text(widget.point.description),
              Text("Likes: $_voteCount"),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (!isCurrentUserPoint)
                    ElevatedButton(
                      onPressed: _incrementVotes,
                      child: Text('Like'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 151, 151, 151),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: widget.onClose,
                    child: Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
