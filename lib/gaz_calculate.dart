import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

import 'calculate_distance.dart'; // Add this import at the top of the file

class GazCalculate extends StatefulWidget {
  const GazCalculate({super.key});

  @override
  GazCalculateState createState() => GazCalculateState();
}

class GazCalculateState extends State<GazCalculate> {
  final locController = TextEditingController();
  final cities = <Map<String, dynamic>>[].obs;
  final addLocation = false.obs;
  final getLocations = false.obs;

  @override
  void initState() {
    super.initState();
    locController.addListener(_updateAddLocationState);
  }

  @override
  void dispose() {
    locController.removeListener(_updateAddLocationState);
    locController.dispose();
    super.dispose();
  }

  void _updateAddLocationState() {
    addLocation.value = locController.text.isNotEmpty;
  }

  Future<void> addLocationWithCoordinates() async {
    if (locController.text.isNotEmpty) {
      try {
        List<Location> locations =
            await locationFromAddress(locController.text);
        if (locations.isNotEmpty) {
          _addCityToList(locations.first);
        } else {
          _handleGeocodingError('No locations found');
        }
      } catch (e) {
        developer.log('Geocoding error: $e');
        _handleGeocodingError(e.toString());
      }
    }
  }

  void _handleGeocodingError(String errorMessage) {
    Get.snackbar(
      'Error',
      'Unable to find location. Please check your input and try again.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void _addCityToList(Location location) {
    cities.add({
      'name': locController.text,
      'lat': location.latitude,
      'lng': location.longitude,
    });
    locController.clear();
    addLocation.value = false;
    Get.snackbar('Success',
        'Location added: ${location.latitude}, ${location.longitude}');
  }

  void navigateToLocationsList() {
    if (cities.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LocationsListPage(locations: cities)),
      );
    }
  }

  void navigateToCalculateDistance() {
    if (cities.isNotEmpty) {
      Get.to(() => CalculateDistance(locations: cities));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('City List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: locController,
              decoration: const InputDecoration(
                labelText: 'Enter location',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Obx(() {
            return ElevatedButton.icon(
              onPressed: addLocation.value ? addLocationWithCoordinates : null,
              icon: const Icon(Icons.add),
              label: const Text('Add Location'),
            );
          }),
          const SizedBox(
            height: 20,
          ),
          Obx(() {
            return ElevatedButton.icon(
                onPressed: cities.isNotEmpty || getLocations.value
                    ? navigateToLocationsList
                    : null,
                icon: const Icon(Icons.location_on_sharp),
                label: const Text('Get Locations'));
          }),
          const SizedBox(
            height: 20,
          ),
          Obx(() {
            return ElevatedButton.icon(
                onPressed:
                    cities.isNotEmpty ? navigateToCalculateDistance : null,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Distances'));
          }),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: cities.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(cities[index]['name']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => cities.removeAt(index),
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}

class LocationsListPage extends StatelessWidget {
  final List<Map<String, dynamic>> locations;

  const LocationsListPage({Key? key, required this.locations})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Locations List')),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(locations[index]['name']),
            subtitle: Text(
                'Lat: ${locations[index]['lat']}, Lng: ${locations[index]['lng']}'),
          );
        },
      ),
    );
  }
}
