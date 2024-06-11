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
  // final String timeAgo;

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

  // Fetch current user ID
  Future<void> _fetchCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  String _formatTimeAgo(Point point) {
    final duration = DateTime.now().difference(point.timestamp);

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

  // Fetch current votes for the point
  Future<void> _fetchCurrentVotes() async {
    try {
      final response = await http.get(
        Uri.parse('${baseURL}/points/votes/${widget.point.id}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _voteCount = int.parse(response.body);
        });
      } else {
        throw Exception('Failed to load votes');
      }
    } catch (e) {
      print('Error fetching votes: $e');
    }
  }

  // Increment votes for the point
  Future<void> _incrementVotes() async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseURL/points/incrementVotes/${widget.point.id}/${_currentUserId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        _fetchCurrentVotes();
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
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.point.event,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              Text(
                _formatTimeAgo(widget.point),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "Description: " + widget.point.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          
              Text(
                "Likes: $_voteCount",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
            if (!isCurrentUserPoint)
            ElevatedButton(
              onPressed: _incrementVotes,
              child: Text(
                'Like',
                style: TextStyle(
                  color: Colors.white, // Culoare albă
                  fontWeight: FontWeight.bold, // Text îngroșat
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Culoare verde
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
              ElevatedButton(
                onPressed: widget.onClose,
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ]
          )

        ],
      ),
    ),
  ),
);

  }
}