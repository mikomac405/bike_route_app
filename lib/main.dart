import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;

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
  final FocusNode focusNodeLong1 = FocusNode();
  final FocusNode focusNodeLat1 = FocusNode();
  final FocusNode focusNodeLong2 = FocusNode();
  final FocusNode focusNodeLat2 = FocusNode();

  // Controllers for text fields to modify text programmatically
  final TextEditingController textControllerLong1 = TextEditingController();
  final TextEditingController textControllerLat1 = TextEditingController();
  final TextEditingController textControllerLong2 = TextEditingController();
  final TextEditingController textControllerLat2 = TextEditingController();

  GeoPoint? lastPoint1;
  GeoPoint? lastPoint2;

  // Variable to track the last active TextField
  FocusNode? lastActiveFocusNode;

  String? lastKey;

  // Method to input data into the last active TextField
  void inputDataToLastActiveField(String lat, String long) {
    if (lastActiveFocusNode == focusNodeLong1 || lastActiveFocusNode == focusNodeLat1) {
      textControllerLong1.text = long;
      textControllerLat1.text = lat;
    } else if (lastActiveFocusNode == focusNodeLong2 || lastActiveFocusNode == focusNodeLat2) {
      textControllerLong2.text = long;
      textControllerLat2.text = lat;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the mapController in initState
    mapController = MapController(
      initPosition: GeoPoint(latitude: 50.0496833, longitude: 19.944544),
    );

    mapController.listenerMapSingleTapping.addListener(() {
      if (mapController.listenerMapSingleTapping.value != null) {
        var data = mapController.listenerMapSingleTapping.value!;

        if(lastKey != null){
          mapController.removeRoad(roadKey: lastKey!);
        }

        if (lastActiveFocusNode == focusNodeLong1 || lastActiveFocusNode == focusNodeLat1) {
          if (lastPoint1 == null) {
            mapController.addMarker(data,
                markerIcon: const MarkerIcon(
                  icon: Icon(
                    Icons.location_on, // Use the built-in location icon
                    color: Colors.blue, // Set the color to red
                    size: 50.0, // Adjust the size as needed
                  ),
                ));
          } else {
            mapController.changeLocationMarker(
                oldLocation: lastPoint1!, newLocation: data);
          }
          inputDataToLastActiveField(data.latitude.toString(), data.longitude.toString());
          lastPoint1 = data;
        } else if (lastActiveFocusNode == focusNodeLong2 || lastActiveFocusNode == focusNodeLat2) {
          if (lastPoint2 == null) {
            mapController.addMarker(data,
                markerIcon: const MarkerIcon(
                  icon: Icon(
                    Icons.location_on, // Use the built-in location icon
                    color: Colors.red, // Set the color to red
                    size: 50.0, // Adjust the size as needed
                  ),
                ));
          } else {
            mapController.changeLocationMarker(
                oldLocation: lastPoint2!, newLocation: data);
          }
          inputDataToLastActiveField(data.latitude.toString(), data.longitude.toString());
          lastPoint2 = data;
        }
      }
    });
  }

  @override
  void dispose() {
    // Dispose of the controllers and focus nodes when no longer needed
    textControllerLong1.dispose();
    textControllerLat1.dispose();
    textControllerLong2.dispose();
    textControllerLat2.dispose();
    focusNodeLong1.dispose();
    focusNodeLat1.dispose();
    focusNodeLong2.dispose();
    focusNodeLat2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CycloSafe Navigator'),
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
                      const Text("Origin"),
                      const SizedBox(height: 5),
                      // First Text Input
                      TextField(
                        focusNode: focusNodeLat1,
                        controller: textControllerLat1,
                        onTap: () {
                          // Set this TextField as the last active one when tapped
                          setState(() {
                            lastActiveFocusNode = focusNodeLat1;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                        ),
                      ),const SizedBox(height: 5),TextField(
                        focusNode: focusNodeLong1,
                        controller: textControllerLong1,
                        onTap: () {
                          // Set this TextField as the last active one when tapped
                          setState(() {
                            lastActiveFocusNode = focusNodeLong1;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                        ),
                      )
                      ,
                      const SizedBox(height: 16), // Space between inputs
                      // Second Text Input
                      const Text("Destination"),
                      const SizedBox(height: 5),
                      TextField(
                        focusNode: focusNodeLat2,
                        controller: textControllerLat2,
                        onTap: () {
                          // Set this TextField as the last active one when tapped
                          setState(() {
                            lastActiveFocusNode = focusNodeLat2;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                        ),
                      ),const SizedBox(height: 5),TextField(
                        focusNode: focusNodeLong2,
                        controller: textControllerLong2,
                        onTap: () {
                          // Set this TextField as the last active one when tapped
                          setState(() {
                            lastActiveFocusNode = focusNodeLong2;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16), // Space before button
                      // Button
                      ElevatedButton(
                        onPressed: () async {
                          if(lastKey != null){
                            mapController.removeRoad(roadKey: lastKey!);
                          }

                          var client = http.Client();
                          try {
                            var response = await client.post(
                                Uri.https('470d-89-171-58-3.ngrok-free.app',
                                    'get_path'),
                                headers: {"Content-Type": "application/json"},
                                body: jsonEncode({
                                  "origin_lat":
                                      textControllerLat1.text,
                                  "origin_lon":
                                      textControllerLong1.text,
                                  "dest_lat":
                                      textControllerLat2.text,
                                  "dest_lon": textControllerLong2.text
                                }));

                            var decodedResponse =
                                jsonDecode(utf8.decode(response.bodyBytes))
                                    as Map;

                            // Safely casting the "path" from JSON to List<dynamic> and converting to List<GeoPoint>
                            List<GeoPoint> road =
                                (decodedResponse["path"] as List<dynamic>)
                                    .map((coords) {
                              var latLng = coords as List<
                                  dynamic>; // Explicitly cast each coordinate pair to List<dynamic>
                              return GeoPoint(
                                  latitude: latLng[0], longitude: latLng[1]);
                            }).toList();
                            
                            print(road);
                            lastKey = await mapController.drawRoadManually(road, const RoadOption(roadColor: Colors.green));
                          } finally {
                            client.close();
                          }
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
                    initZoom: 13,
                    minZoomLevel: 13,
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
