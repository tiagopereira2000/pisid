import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


import 'New folder/readings3.dart';


class Home extends StatelessWidget{
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Home Page';

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
  String? selectedItem ;
  bool isExperienceInitialized = false;
  Map<String, String> itemMap = {}; //lista vazia onde vão ser inseridas as experiências do Investigador
  bool isButtonEnabled = false;
  String? username ;
  String? password ;
  String? ip ;
  String? port;

  @override
  void initState() {
    // TODO: implement initState
    fetchExperimentNames();
    super.initState();
  }

  Future<void> fetchExperimentNames() async {
    final prefs = await SharedPreferences.getInstance();
    selectedItem = prefs.getString('experienceID');
    isExperienceInitialized = prefs.getBool('isExperienceActive') ?? false;
    username = prefs.getString('username');
    password = prefs.getString('password');
    ip = prefs.getString('ip');
    port = prefs.getString('port');
    String readingsURL = "http://" + ip! + ":" + port! + "/scripts/getExperimentsFromUser.php";
    var response = await http.post(Uri.parse(readingsURL), body: {'username': username, 'password': password});
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      var data = jsonData["experiments"];

      setState(() {
        if (data != null && data.length > 0) {
          for (var reading in data) {
            itemMap[reading["IDexperiencia"].toString()] = reading["Descricao"].toString();
          }
        }
      });
    }

  }

  Future<void> initializeExperiment() async {
    // Add your code here to initialize the selected experiment
    String readingsURL = "http://" + ip! + ":" + port! + "/scripts/initializeExperiment.php";

    var response = await http.post(Uri.parse(readingsURL), body: {
      'username': username,
      'password': password,
      'Experience_ID': selectedItem,
    });

    print('Initializing experiment: $selectedItem');

    setState(() {
      isExperienceInitialized = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('experienceID', selectedItem!);
    await prefs.setBool('isExperienceActive', true);
  }

  Future<void> finalizeExperiment() async {

    // Add your code here to initialize the selected experiment
    String readingsURL = "http://" + ip! + ":" + port! + "/scripts/finalizeExperiment.php";

    var response = await http.post(Uri.parse(readingsURL), body: {
      'username': username,
      'password': password,
      'Experience_ID': selectedItem,
    });

    print('Finalizing experiment: $selectedItem');

    setState(() {
      isExperienceInitialized = false;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('experienceID', '');
    await prefs.setBool('isExperienceActive', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isExperienceInitialized ? _buildInitializedView() : _buildListView(),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          child: const Text('Alerts'),
        ),
      ),

    );
    // TODO: implement build
    throw UnimplementedError();
  }

  Widget _buildInitializedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Experience Initialized'),
          // Add any other widgets specific to the initialized view
          Center(
            child: ElevatedButton(
              onPressed: () {
                finalizeExperiment();
              },
              child: Text(
                'Terminar Experiência',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Your list widgets here
        Expanded(
          child: ListView.builder(
            itemCount: itemMap.length,
            itemBuilder: (context, index) {
              String itemId = itemMap.keys.elementAt(index);
              String itemDescription = itemMap[itemId]!;
              return ListTile(
                title: Text(itemDescription),
                onTap: () {
                  setState(() {
                    selectedItem = itemId;
                    isButtonEnabled = true;
                  });
                },
                tileColor: selectedItem == itemId ? Colors.grey[300] : null,
              );
            },
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: isButtonEnabled ? () {
              // Use the selectedItemId to initialize the experiment
              initializeExperiment();
            }
                : null,
            child: Text(
              'Começar Experiência',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}
