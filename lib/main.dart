import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

void main() {
  runApp(MyApp());
}

// Make MyApp a StatefulWidget
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // MapController should be in the State class to manage it properly
  late MapController mapController;
  
  // Focus nodes to manage focus between text fields
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();

  // Controllers for text fields to modify text programmatically
  final TextEditingController textController1 = TextEditingController();
  final TextEditingController textController2 = TextEditingController();

  // Variable to track the last active TextField
  FocusNode? lastActiveFocusNode;

  // Method to input data into the last active TextField
  void inputDataToLastActiveField(String data) {
    if (lastActiveFocusNode == focusNode1) {
      textController1.text = data;
    } else if (lastActiveFocusNode == focusNode2) {
      textController2.text = data;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the mapController in initState
    mapController = MapController(
      initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
      areaLimit: const BoundingBox(
        east: 10.4922941,
        north: 47.8084648,
        south: 45.817995,
        west: 5.9559113,
      ),
    );
    mapController.listenerMapSingleTapping.addListener(() {
      if (mapController.listenerMapSingleTapping.value != null) {
        var data = mapController.listenerMapSingleTapping.value!;
        inputDataToLastActiveField("${data.latitude} ${data.longitude}");
      }
    });
  }

  @override
  void dispose() {
    // Dispose of the controllers and focus nodes when no longer needed
    textController1.dispose();
    textController2.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XD',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Daj kurwie miodu'),
        ),
        body: Row(
          children: [
            // First column taking 20% of the space
            Flexible(
              flex: 2, // 2 parts out of 10 (20%)
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      // First Text Input
                      TextField(
                        focusNode: focusNode1,
                        controller: textController1,
                        onTap: () {
                          // Set this TextField as the last active one when tapped
                          setState(() {
                            lastActiveFocusNode = focusNode1;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Input 1',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16), // Space between inputs
                      // Second Text Input
                      TextField(
                        focusNode: focusNode2,
                        controller: textController2,
                        onTap: () {
                          // Set this TextField as the last active one when tapped
                          setState(() {
                            lastActiveFocusNode = focusNode2;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Input 2',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16), // Space before button
                      // Button
                      ElevatedButton(
                        onPressed: () {
                          // Add your button logic here
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Second column taking 80% of the space
            Expanded(
              flex: 8, // 8 parts out of 10 (80%)
              child: OSMFlutter(
                controller: mapController,
                osmOption: OSMOption(
                  userTrackingOption: const UserTrackingOption(
                    enableTracking: true,
                    unFollowUser: false,
                  ),
                  zoomOption: const ZoomOption(
                    initZoom: 8,
                    minZoomLevel: 3,
                    maxZoomLevel: 19,
                    stepZoom: 1.0,
                  ),
                  userLocationMarker: UserLocationMaker(
                    personMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.location_history_rounded,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    directionArrowMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.double_arrow,
                        size: 48,
                      ),
                    ),
                  ),
                  roadConfiguration: const RoadOption(
                    roadColor: Colors.yellowAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
