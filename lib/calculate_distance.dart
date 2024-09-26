import 'package:flutter/material.dart';
import 'dart:math';

class CalculateDistance extends StatelessWidget {
  final List<Map<String, dynamic>> locations;

  const CalculateDistance({Key? key, required this.locations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<int> shortestRoute = calculateShortestRoute(locations);
    double totalDistance = calculateTotalDistance(locations, shortestRoute);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shortest Route',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 5,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: shortestRoute.length,
              itemBuilder: (context, index) {
                int cityIndex = shortestRoute[index];
                return ListTile(
                  title: Text(locations[cityIndex]['name']),
                  subtitle: Text('Lat: ${locations[cityIndex]['lat']}, Lon: ${locations[cityIndex]['lon']}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Total Distance: ${totalDistance.toStringAsFixed(2)} km'),
          ),
        ],
      ),
    );
  }

  List<int> calculateShortestRoute(List<Map<String, dynamic>> cities) {
    List<int> indices = List.generate(cities.length, (index) => index);
    List<int> shortestRoute = [];
    double shortestDistance = double.infinity;

    void permute(List<int> arr, int start) {
      if (start == arr.length - 1) {
        double distance = calculateTotalDistance(cities, arr);
        if (distance < shortestDistance) {
          shortestDistance = distance;
          shortestRoute = List.from(arr);
        }
        return;
      }

      for (int i = start; i < arr.length; i++) {
        List<int> newArr = List.from(arr);
        newArr[start] = arr[i];
        newArr[i] = arr[start];
        permute(newArr, start + 1);
      }
    }

    permute(indices, 0);
    return shortestRoute;
  }

  double calculateTotalDistance(List<Map<String, dynamic>> cities, List<int> route) {
    double totalDistance = 0;
    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += calculateDistance(
        cities[route[i]]['lat'],
        cities[route[i]]['lon'],
        cities[route[i + 1]]['lat'],
        cities[route[i + 1]]['lon'],
      );
    }
    return totalDistance;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // in kilometers
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}