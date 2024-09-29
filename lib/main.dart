import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MapController mapController;

  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();

  final TextEditingController textController1 = TextEditingController();
  final TextEditingController textController2 = TextEditingController();

  GeoPoint? lastPoint1;
  GeoPoint? lastPoint2;

  FocusNode? lastActiveFocusNode;

  double textFieldHeight = 48.0; // Default height for the TextField

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
    mapController = MapController(
      initPosition: GeoPoint(latitude: 50.0496833, longitude: 19.944544),
    );

    mapController.listenerMapSingleTapping.addListener(() {
      if (mapController.listenerMapSingleTapping.value != null) {
        var data = mapController.listenerMapSingleTapping.value!;

        if (lastActiveFocusNode == focusNode1) {
          if (lastPoint1 == null) {
            mapController.addMarker(
              data,
              markerIcon: const MarkerIcon(
                icon: Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 50.0,
                ),
              ),
            );
          } else {
            mapController.changeLocationMarker(oldLocation: lastPoint1!, newLocation: data);
          }
          inputDataToLastActiveField("${data.latitude} ${data.longitude}");
          lastPoint1 = data;
        } else if (lastActiveFocusNode == focusNode2) {
          if (lastPoint2 == null) {
            mapController.addMarker(
              data,
              markerIcon: const MarkerIcon(
                icon: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 50.0,
                ),
              ),
            );
          } else {
            mapController.changeLocationMarker(oldLocation: lastPoint2!, newLocation: data);
          }
          inputDataToLastActiveField("${data.latitude} ${data.longitude}");
          lastPoint2 = data;
        }
      }
    });
  }

  @override
  void dispose() {
    textController1.dispose();
    textController2.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CycloSafe Navigator',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CycloSafe Navigator'),
        ),
        body: Stack(
          children: [
            Row(
              children: [
                // First column taking 20% of the space
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextField(
                          focusNode: focusNode1,
                          controller: textController1,
                          onTap: () {
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
                // Second column taking 80% of the space
                Expanded(
                  flex: 8,
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
            // Positioned SVG in the bottom left corner with dynamic scaling
            Positioned(
              left: MediaQuery.of(context).size.width * 0, // Scale padding based on screen width
              bottom: MediaQuery.of(context).size.height * 0, // Scale padding based on screen height
              child: Builder(
                builder: (context) {
                  // Calculate the size and total space required for the SVG
                  double svgSize = MediaQuery.of(context).size.width * 0.2;
                  double bottomPadding = MediaQuery.of(context).size.height * 0.01;
                  double svgTotalHeight = svgSize + bottomPadding;

                  // Determine if the SVG can fit without covering the text fields or button
                  bool shouldDisplaySvg = MediaQuery.of(context).size.height - svgTotalHeight > 200;

                  return Visibility(
                    visible: shouldDisplaySvg,
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
                      child: SvgPicture.asset(
                        'assets/logo2_final.svg',
                        width: svgSize,
                        height: svgSize,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
