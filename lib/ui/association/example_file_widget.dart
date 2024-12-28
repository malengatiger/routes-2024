import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/example_file.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

import '../../library/qr_code_generation.dart';
class ExampleFileWidget extends StatefulWidget {
  const ExampleFileWidget({super.key});

  @override
  ExampleFileWidgetState createState() => ExampleFileWidgetState();
}

class ExampleFileWidgetState extends State<ExampleFileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🎽🎽🎽ExampleFileWidget 🎽';
  List<ExampleFile> examples = [];
  ListApiDog listApi = GetIt.instance<ListApiDog>();
  bool busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getExamples();
  }

  _getExamples() async {
    setState(() {
      busy = false;
    });
    examples = await listApi.getExampleFiles();
    for (var e in examples) {
      if (e.fileName!.contains('user')) {
        userString = await _downloadFile(e);
      }
      if (e.fileName!.contains('vehicle')) {
        vehicleString = await _downloadFile(e);
      }
    }
    var csvUser = convertCsv(userString!);
    for (var m in csvUser) {
      pp('$mm  🍎🍎 row: $m');
      var p = Person(
          userType: m[0],
          firstName: m[1],
          lastName: m[2],
          email: m[3],
          cellphone: m[4]);
      persons.add(p);
    }
    var csvCar = convertCsv(vehicleString!);
    for (var m in csvCar) {
      pp('$mm  🍎🍎 row: $m');
      var c = Car(
          ownerName: m[0],
          vehicleReg: m[1],
          model: m[2],
          make: m[3],
          year: m[4],
          passengerCapacity: m[5]);
      cars.add(c);
    }
    setState(() {
      busy = true;
    });
  }

  List<Car> cars = [];
  List<Person> persons = [];

  String? userString, vehicleString;

  Future<String> _downloadFile(ExampleFile file) async {
    try {
      final response = await http.get(Uri.parse(file.downloadUrl!));

      if (response.statusCode == 200) {
        // The response body is the downloaded content as a string
        var res = response.body;
        pp('$mm res: $res');
        return res;
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      pp('DOWNLOAD ERROR: $e');
      rethrow;
    }
  }

  void saveUserFile() {
    if (kIsWeb) {
      writeStringToFileWeb(userString!, 'users.csv');
    } else {
      writeStringToFileMobile(userString!, 'users.csv');
    }
  }
  void saveVehicleFile() {
    if (kIsWeb) {
      writeStringToFileWeb(vehicleString!, 'vehicles.csv');
    } else {
      writeStringToFileMobile(vehicleString!, 'vehicles.csv');
    }
  }
  void writeStringToFileWeb(String content, String fileName) {
    pp('$mm writeStringToFileWeb: file: $fileName');
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], 'text/plain;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url); // Clean up the URL object
  }

  Future<void> writeStringToFileMobile(String content, String fileName) async {
    pp('$mm writeStringToFileMobile: file: $fileName');

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
      pp('$mm File saved to: ${file.path}');
    } catch (e) {
      pp('Error writing to file: $e');
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Column(
            children: [
              gapH32,
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Association Staff/Users',
                    style: myTextStyle(weight: FontWeight.w900, fontSize: 24),
                  ),
                  gapW32, gapW32,gapW32,
                  IconButton(onPressed: (){
                    pp('$mm download user file tapped');
                    saveUserFile();
                  }, icon: Icon(Icons.download_for_offline_sharp, size: 36, color: Colors.blue,)),
                ],
              ),
              gapH32,
              SizedBox(
                height: 320,
                child: ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: (_, index) {
                    var p = persons[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                            width: 160,
                            child: Text(
                              '${p.userType}',
                              style: myTextStyle(
                                  fontSize: 10,
                                  weight: index == 0
                                      ? FontWeight.w900
                                      : FontWeight.w500),
                            )),
                        SizedBox(
                            width: 80,
                            child: Text(
                              '${p.firstName}',
                              style: myTextStyle(
                                  fontSize: 10,
                                  weight: index == 0
                                      ? FontWeight.w900
                                      : FontWeight.w500),
                            )),
                        SizedBox(
                            width: 100,
                            child: Text(
                              '${p.lastName}',
                              style: myTextStyle(
                                  fontSize: 10,
                                  weight: index == 0
                                      ? FontWeight.w900
                                      : FontWeight.w500),
                            )),
                        SizedBox(
                            width: 186,
                            child: Text(
                              '${p.email}',
                              style: myTextStyle(
                                  fontSize: 10,
                                  weight: index == 0
                                      ? FontWeight.w900
                                      : FontWeight.w500),
                            )),
                        SizedBox(
                            width: 120,
                            child: Text(
                              '${p.cellphone}',
                              style: myTextStyle(
                                  fontSize: 12,
                                  weight: index == 0
                                      ? FontWeight.w900
                                      : FontWeight.w500),
                            )),
                      ],
                    );
                  },
                ),
              ),
              gapH32,
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Association Vehicles',
                    style: myTextStyle(weight: FontWeight.w900, fontSize: 24),
                  ),
                  gapW32, gapW32,gapW32,
                  IconButton(onPressed: (){
                    pp('$mm download car file tapped');
                    saveVehicleFile();
                  }, icon: Icon(Icons.download_for_offline_sharp, size: 36, color: Colors.blue,)),
                ],
              ),
              gapH32,
              Expanded(
                child: ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (_, index) {
                    var p = cars[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                            width: 160,
                            child: Text(
                              '${p.ownerName}',
                              style: myTextStyle(
                                  fontSize: 12,
                                  weight: index == 0
                                      ? FontWeight.w900
                                      : FontWeight.w500),
                            )),
                        SizedBox(
                            width: 120,
                            child: Text(
                              '${p.vehicleReg}',
                              style: myTextStyle(
                                  fontSize: 12,
                                  weight: index == 0
                                      ? FontWeight.w900
                                      : FontWeight.w500),
                            )),
                        SizedBox(
                            width: 100,
                            child: Text(
                              '${p.model}',
                              style: myTextStyle(
                                  fontSize: 12,
                                  weight: index == 0
                                      ? FontWeight.w900
                                      : FontWeight.w500),
                            )),
                        SizedBox(
                            width: 100,
                            child: Text(
                              '${p.make}',
                              style: myTextStyle(
                                  fontSize: 12,
                                  weight: index == 0
                                      ? FontWeight.w900
                                      : FontWeight.w500),
                            )),
                        SizedBox(
                            width: 60,
                            child: Text(
                              '${p.year}',
                              style: myTextStyle(
                                  fontSize: 12,
                                  weight: index == 0
                                      ? FontWeight.w900
                                      : FontWeight.w500),
                            )),
                        SizedBox(
                            width: 148,
                            child: Text(
                              '${p.passengerCapacity}',
                              style: myTextStyle(
                                  fontSize: 12,
                                  weight: index == 0
                                      ? FontWeight.w900
                                      : FontWeight.w500),
                            )),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }
}

class Car {
  /*
  [ownerName, vehicleReg, model, make, year, passengerCapacity]
   */
  String? ownerName, vehicleReg, model, make, year, passengerCapacity;

  Car(
      {required this.ownerName,
      required this.vehicleReg,
      required this.model,
      required this.make,
      required this.year,
      required this.passengerCapacity});
}

class Person {
  String? userType, firstName, lastName, email, cellphone;

  Person(
      {required this.userType,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.cellphone});
}
