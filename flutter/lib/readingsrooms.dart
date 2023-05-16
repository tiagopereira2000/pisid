import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:io';

/*
Fields:

showingTooltip: An integer representing the index of the currently selected bar on the chart.
timer: An instance of Timer used to periodically fetch readings.
readingsValues: A list of double values representing the readings for each bar.
readingsTimes: A list of double values representing the corresponding times for each bar.
minY: A double value representing the minimum y-axis value on the chart.
maxY: A double value representing the maximum y-axis value on the chart.

Objectives:

Display bar chart readings for a specific context.
Fetch and update readings periodically.
Allow interaction with the chart to show tooltips.
Methods:

initState: An overridden method called when the stateful widget is created. It initializes the timer to periodically fetch readings.

generateGroupData: A method that generates a BarChartGroupData object representing a single bar on the chart.

build: An overridden method that builds the UI for the widget.
 It displays a bar chart using the fl_chart library and updates the chart with fetched readings.

getReadings: An asynchronous method that retrieves readings from a server and updates the chart's data accordingly.

dispose: An overridden method that cancels the timer when the stateful widget is disposed.

In summary, this code builds a page in a Flutter application that displays bar chart readings for a specific context.
 It periodically fetches new readings, updates the chart accordingly,
 and allows interaction with the chart by showing tooltips for each bar.
*/


class readingsrooms extends StatelessWidget {
  const readingsrooms({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Mouses  / Room';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(appTitle),
      ),
      body: const ReadingsMain(),
    );
  }
}


class ReadingsMain extends StatefulWidget {
  const ReadingsMain({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ReadingsMain> {
  late int showingTooltip;
  late Timer timer;

  @override
  void initState() {
    showingTooltip = -1;
    const interval = Duration(seconds:1);
    timer = Timer.periodic(interval, (Timer t) => getReadings());
    super.initState();
  }
  var readingsMouses = <int>[];
  var readingsRoom = <int>[];
  var minY = 0;
  var maxY = 25;



  BarChartGroupData generateGroupData(int x, int y) {
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: showingTooltip == x ? [0] : [],
      barRods: [
        BarChartRodData(toY: y.toDouble()),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    //getReadings();  // lê os primeiros 8 valores de movimentos.
    //sleep(const Duration(seconds:1));
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AspectRatio(
            aspectRatio: 2,
            child: BarChart(
              BarChartData(
                barGroups: [
                  generateGroupData(readingsRoom[0].toInt(),readingsMouses[0].toInt()),
                  generateGroupData(readingsRoom[1].toInt(),readingsMouses[1].toInt()),
                  // generateGroupData(readingsRoom[2].toInt(),readingsMouses[2].toInt()),
                  // generateGroupData(readingsRoom[3].toInt(),readingsMouses[3].toInt()),
                  // generateGroupData(readingsRoom[4].toInt(),readingsMouses[4].toInt()),
                  // generateGroupData(readingsRoom[5].toInt(),readingsMouses[5].toInt()),
                  // generateGroupData(readingsRoom[6].toInt(),readingsMouses[6].toInt()),
                  // generateGroupData(readingsRoom[7].toInt(),readingsMouses[7].toInt()),
                  // generateGroupData(readingsRoom[8].toInt(),readingsMouses[8].toInt()),
                ],
                barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: false,
                    touchCallback: (event, response) {
                      if (response != null && response.spot != null && event is FlTapUpEvent) {
                        setState(() {
                          final x = response.spot!.touchedBarGroup.x;
                          final isShowing = showingTooltip == x;
                          if (isShowing) {
                            showingTooltip = -1;
                          } else {
                            showingTooltip = x;
                          }
                        });
                      }
                    },
                    mouseCursorResolver: (event, response) {
                      return response == null || response.spot == null
                          ? MouseCursor.defer
                          : SystemMouseCursors.click;
                    }
                ),
              ),
            ),
          ),
        ),
      ),
        bottomNavigationBar: BottomAppBar(
          child: ElevatedButton(
            onPressed: () {
              readingsRoom.clear();
              readingsMouses.clear();
              minY = 0;
              maxY = 25;
              Navigator.pop(context);
            },
            child: const Text('Alerts'),
          ),
        ));

  }
  getReadings() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    String? ip = prefs.getString('ip');
    String? port = prefs.getString('port');
    String readingsURL = "http://" + ip! + ":" + port! + "/scripts/getMousesRoom.php";
    var response = await http.post(Uri.parse(readingsURL), body: {'username': username, 'password': password});

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      var data = jsonData["readings"];

      setState(() {
        readingsMouses.clear();
        readingsRoom.clear();
        minY = 0;
        maxY = 25;

        if (data != null && data.length > 0) {
          for (var reading in data) {
            //double readingTime = double.parse(reading["Room"].toString());
            //var value = double.parse(reading["TotalMouses"].toString());
            var room = int.parse(reading["Room"].toString());
            var numRatos = int.parse(reading["TotalMouses"].toString());
            //print("VALUE: " + value.toString());
            // readingsTimes.add(readingTime);
            // readingsValues.add(value);
            readingsRoom.add(room);
            readingsMouses.add(numRatos);
          }
          if (readingsMouses.isNotEmpty) {
            minY = readingsMouses.reduce(min)-1;
            maxY = readingsMouses.reduce(max)+1;
          }
        }// fi
      }); //setState
    }
  } //getReadings
}