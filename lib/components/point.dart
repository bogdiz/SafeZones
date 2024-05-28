class Point {
  final int id;
  final String latitude;
  final String longitude;
  final String description;
  final String category; // Assuming category is also a part of the JSON response
  final DateTime timestamp;

  Point({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.category,
    required this.timestamp
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      id: json['id'] ?? 0, // Default value or handle null appropriately
      latitude: json['latitude'] ?? '', // Default value or handle null appropriately
      longitude: json['longitude'] ?? '', // Default value or handle null appropriately
      description: json['description'] ?? '', // Default value or handle null appropriately
      category: json['category'] ?? '', // Default value or handle null appropriately
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
