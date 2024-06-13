import 'dart:async';
import 'dart:convert';
import 'dart:math';

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
import '../pages/map_page.dart';

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
  String? _userName = '';
  String? _userLevel = '';
  bool _isLikedByUser = false;

  @override
  void initState() {
    super.initState();
    _voteCount = widget.point.votes;
    _fetchCurrentVotes();
    _fetchCurrentUserId();
    _fetchUserName();
    _fetchUserLevel();
    _pointLikedByUser();
  }

  Future<void> _fetchCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }
  
  Future<void> _fetchUserName() async {
    try {
      final response = await http.get(
        Uri.parse('${baseURL}/users/${widget.point.userId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _userName =
              response.body; 
        });
      } else {
        throw Exception('Failed to load user name');
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  Future<void> _fetchUserLevel() async {
    try {
      final response = await http.get(
        Uri.parse('${baseURL}/users/level/${widget.point.userId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _userLevel = response
              .body; // Assuming the response body is just the user level
        });
      } else {
        throw Exception('Failed to load user level');
      }
    } catch (e) {
      print('Error fetching user level: $e');
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

  Future<void> _fetchCurrentVotes() async {
    try {
      final response = await http.get(
        Uri.parse('${baseURL}/points/votes/${widget.point.id}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        // print(data[_voteCount].toString() + "\n\n\n\n\n");
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
    _isLikedByUser = true;
    try {
      final response = await http.post(
        Uri.parse(
            '$baseURL/points/incrementVotes/${widget.point.id}/${_currentUserId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        _incrementRewardPoints();
        _fetchCurrentVotes();
      } else {
        throw Exception(
            'Failed to increment votes and reward points: ${response.body}');
      }
    } catch (e) {
      print('Error incrementing votes: $e');
    }
  }

  // Increment reward Points for the User
  Future<void> _incrementRewardPoints() async {
    try {
      final response = await http.put(
        Uri.parse('$baseURL/users/incrementPoints/${widget.point.userId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('Reward points incremented successfully.');
        _fetchCurrentVotes(); // Assuming you want to fetch votes again after incrementing reward points
      } else {
        throw Exception('Failed to increment reward points: ${response.body}');
      }
    } catch (e) {
      print('Error incrementing reward points: $e');
    }
  }

  Future<void> _pointLikedByUser() async {
  
    try {
      final response = await http.get(
        Uri.parse('$baseURL/points/liked-by/${widget.point.id}/${_currentUserId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print(response.body);
        _isLikedByUser = response.body == 'true' ? true : false;
      }
    } catch( e) {
      print(e.toString());
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

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

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
              Text(
                "${widget.point.event} - trust factor $_userLevel/5",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: textColor,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                _formatTimeAgo(widget.point),
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Description: " + widget.point.description,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Likes: $_voteCount",
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              SizedBox(height: 12),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Visibility(
                      visible: !isCurrentUserPoint, // Schimbă la true pentru a face butonul vizibil
                      child: AbsorbPointer(
                        absorbing: isCurrentUserPoint, // Impiedică interacțiunea utilizatorului
                        child: ElevatedButton(
                          onPressed: _incrementVotes,
                          child: Text(
                            _isLikedByUser ? 'Liked' : 'Like',
                            style: TextStyle(
                              color: Colors.white, // Culoare albă
                              fontWeight: FontWeight.bold, // Text îngroșat
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: 
                             _isLikedByUser ? Colors.green : Colors.grey, // Culoare verde
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
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
                  ])
            ],
          ),
        ),
      ),
    );
  }
}
