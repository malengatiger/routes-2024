import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:badges/badges.dart' as bd;
import 'package:kasie_transie_library/widgets/scanners/gen_code.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:routes_2024/ui/association/vehicle_list_widget.dart';
import 'package:uuid/uuid.dart';

class VehiclesEdit extends StatefulWidget {
  const VehiclesEdit({super.key, required this.association});

  final Association association;

  @override
  VehiclesEditState createState() => VehiclesEditState();
}

class VehiclesEditState extends State<VehiclesEdit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = ' 🌎🌎 🌎🌎 VehiclesEdit  🌎';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getCars(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController registrationController = TextEditingController();
  TextEditingController makeController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController capacityController = TextEditingController();

  TextEditingController ownerNameController = TextEditingController();
  TextEditingController cellphoneController = TextEditingController();

  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  bool busy = false;
  Prefs prefs = GetIt.instance<Prefs>();
  Vehicle? vehicle;
  List<VehiclePhoto> vehiclePhotos = [];
  List<VehicleVideo> vehicleVideos = [];

  void _setup(Vehicle vehicle) async {
    pp('$mm ... setUp ... vehicle: $vehicle');
    registrationController.text = vehicle.vehicleReg!;
    modelController.text = vehicle.model!;
    makeController.text = vehicle.make!;
    yearController.text = vehicle.year!;
    capacityController.text = '${vehicle.passengerCapacity!}';
    ownerNameController.text = vehicle.ownerName ?? '';
    cellphoneController.text = vehicle.ownerCellphone ?? '';
    country = prefs.getCountry();
    setState(() {});
  }

  List<Vehicle> cars = [];
  String? result;

  void _getCars(bool refresh) async {
    setState(() {
      busy = true;
    });
    try {
      cars = await listApiDog.getAssociationCars(
          widget.association.associationId!, refresh);
      cars.sort((a, b) => a.vehicleReg!.compareTo(b.vehicleReg!));
    } catch (e, s) {
      pp('$e $s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  _onSubmit() async {
    pp('$mm on submit wanted ...');
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      busy = true;
    });
    if (vehicle != null) {
      vehicle!.vehicleReg = registrationController.text;
      vehicle!.make = makeController.text;
      vehicle!.model = modelController.text;
      vehicle!.ownerCellphone = cellphoneController.text;
      vehicle!.ownerName = ownerNameController.text;
      vehicle!.year = yearController.text;
    } else {
      vehicle = Vehicle(
          vehicleId: Uuid().v4(),
          associationId: widget.association.associationId!,
          associationName: widget.association.associationName,
          vehicleReg: registrationController.text,
          countryId: widget.association.countryId,
          created: DateTime.now().toUtc().toIso8601String(),
          make: makeController.text,
          model: modelController.text,
          passengerCapacity: int.parse(capacityController.text),
          year: yearController.text,
          ownerName: ownerNameController.text,
          ownerCellphone: cellphoneController.text);
    }
    try {
      var bytes = await generateQrCode(vehicle!.toJson());
      var url = await dataApiDog.uploadQRCodeFile(imageBytes: bytes,
          associationId: widget.association.associationId!);
      vehicle!.qrCodeUrl = url;
      var res = await dataApiDog.addVehicle(vehicle!);
      cars.insert(0, res);
      if (mounted) {
        showOKToast(
            message:
                'Vehicle registered on KasieTransie: ${vehicle!.vehicleReg}',
            context: context);
      }
    } catch (e, s) {
      pp('$e $s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }

    setState(() {
      busy = false;
    });
  }

  PlatformFile? csvFile, vehiclePictureFile;
  String? csvString;
  void _pickVehicleFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      csvFile = result.files.first;
      pp('$mm csvFile exists: ${csvFile?.bytes!.length} bytes');

      // Read the CSV file as a string
      csvString = utf8.decode(csvFile!.bytes!);

      setState(() {});
    } else {
      // Handle file picking cancellation
      pp('$mm Error: File picking cancelled');
      if (mounted) {
        showErrorToast(message: 'File picking cancelled', context: context);
      }
    }
  }

  Country? country;
  Association? association;

  AddCarsResponse addCarsResponse = AddCarsResponse([], []);
  bool _showErrors = false;
  bool _showSubmit = true;
  List<Vehicle> errorCars = [];

  _sendFile() async {
    pp('\n\n$mm ..... send the Vehicle File to upload ...');
    setState(() {
      _showSubmit = false;
      busy = true;
    });
    addCarsResponse = AddCarsResponse([], []);
    try {
      var cars = getVehiclesFromCsv(
          csv: csvString!, countryId: widget.association.countryId!,
          associationId: widget.association.associationId!,
          associationName: widget.association.associationName!);

      for (var car in cars) {
        registrationController.text = car.vehicleReg!;
        makeController.text = car.make!;
        modelController.text = car.model!;
        yearController.text = car.year!;
        ownerNameController.text = car.ownerName!;
        setState(() {

        });
        try {
          var bytes = await generateQrCode(car.toJson());
          var url = await dataApiDog.uploadQRCodeFile(imageBytes: bytes,
                      associationId: widget.association.associationId!);
          car.qrCodeUrl = url;
          var res = await dataApiDog.addVehicle(car);
          addCarsResponse.cars.add(res);
        } catch (e,s) {
          pp('$e\n$e');
          addCarsResponse.errors.add(car);
        }
      }
      registrationController.text = '';
      makeController.text = '';
      modelController.text = '';
      cellphoneController.text = '';
      yearController.text = '';
      ownerNameController.text = '';

      pp('$mm  cars registered: 🍎 ${addCarsResponse.cars.length}');
      pp('$mm  cars fucked up: 🍎 ${addCarsResponse.errors.length}');
      if (mounted) {
        if (addCarsResponse.errors.isNotEmpty) {
          showErrorToast(
              message: 'Upload encountered ${addCarsResponse.errors.length} errors',
              context: context);
        } else {
          var msg =
              '🌿 Vehicles uploaded OK: ${addCarsResponse.cars
              .length}';
          result = msg;
          showOKToast(message: msg, context: context);
        }
      }
      _getCars(true);
    } catch (e, s) {
      pp('$e $s');
      result = '$e';
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
      _showSubmit = true;
    });
  }

  bool _showEditor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Column(
            children: [
              _showEditor
                  ? Center(
                      child: SizedBox(
                        width: 500,
                        child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                gapH32,
                                gapH32,
                                Text(
                                  'Pick the Vehicles CSV File',
                                  style: myTextStyleMediumLarge(context, 20),
                                ),
                                gapH16,
                                SizedBox(
                                  width: 300,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          elevation: WidgetStatePropertyAll(8),
                                          padding: WidgetStatePropertyAll(
                                              EdgeInsets.all(16)),
                                          textStyle: WidgetStatePropertyAll(
                                              myTextStyleMediumLargeWithColor(
                                                  context, Colors.pink, 16))),
                                      onPressed: () {
                                        _pickVehicleFile();
                                      },
                                      child: Text('Get File')),
                                ),
                                gapH32,
                                csvFile == null
                                    ? gapH32
                                    : SizedBox(
                                        width: 400,
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                                // backgroundColor: WidgetStatePropertyAll(
                                                //     Colors.blue.shade800),
                                                backgroundColor:
                                                    WidgetStateProperty.all<
                                                        Color>(Colors.blue),
                                                // Change button color
                                                foregroundColor:
                                                    WidgetStateProperty.all<
                                                        Color>(Colors.white),
                                                elevation:
                                                    WidgetStatePropertyAll(8),
                                                padding: WidgetStatePropertyAll(
                                                    EdgeInsets.all(24)),
                                                textStyle: WidgetStatePropertyAll(
                                                    myTextStyleMediumLargeWithColor(
                                                        context,
                                                        Colors.blue,
                                                        18))),
                                            onPressed: () {
                                              _sendFile();
                                            },
                                            child: Text('Send Vehicles File')),
                                      ),
                                csvFile == null
                                    ? gapH8
                                    : SizedBox(
                                        height: 64,
                                      ),
                                TextFormField(
                                  controller: registrationController,
                                  keyboardType: TextInputType.name,
                                  style: myTextStyleMediumLargeWithSize(
                                      context, 20),
                                  decoration: InputDecoration(
                                    label: Text('Registration'),
                                    hintText: 'Registration',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Registration';
                                    }
                                    return null;
                                  },
                                ),
                                gapH32,
                                TextFormField(
                                  controller: makeController,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    label: Text('Make'),
                                    hintText: 'Enter Vehicle Make',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Vehicle Make';
                                    }
                                    return null;
                                  },
                                ),
                                gapH32,
                                TextFormField(
                                  controller: modelController,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    label: Text('Model'),
                                    hintText: 'Enter Model',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Model';
                                    }
                                    return null;
                                  },
                                ),
                                gapH32,
                                TextFormField(
                                  controller: yearController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    label: Text('Year'),
                                    hintText: 'Enter Year',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Vehicle Year';
                                    }
                                    return null;
                                  },
                                ),
                                gapH32,
                                TextFormField(
                                  controller: capacityController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    label: Text('Passenger Capacity'),
                                    hintText: 'Enter Passenger Capacity',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Passenger Capacity';
                                    }
                                    return null;
                                  },
                                ),
                                gapH32,
                                TextFormField(
                                  controller: ownerNameController,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    label: Text('Owner Name'),
                                    hintText: 'Enter Owner Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  // validator: (value) {
                                  //   if (value == null || value.isEmpty) {
                                  //     return 'Please enter Owner Name';
                                  //   }
                                  //   return null;
                                  // },
                                ),
                                gapH32,
                                TextFormField(
                                  controller: cellphoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    label: Text('Owner Cellphone'),
                                    hintText: 'Enter Owner Cellphone',
                                    border: OutlineInputBorder(),
                                  ),
                                  // validator: (value) {
                                  //   if (value == null || value.isEmpty) {
                                  //     return 'Please enter Owner Cellphone';
                                  //   }
                                  //   return null;
                                  // },
                                ),
                                gapH8,
                                gapH32,
                                busy
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 8,
                                          backgroundColor: Colors.pink,
                                        ),
                                      )
                                    : _showSubmit? SizedBox(
                                        width: 400,
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                              elevation:
                                                  WidgetStatePropertyAll(8),
                                            ),
                                            onPressed: () {
                                              _onSubmit();
                                            },
                                            child: Padding(
                                                padding: EdgeInsets.all(20),
                                                child: Text(
                                                  'Submit',
                                                  style:
                                                      myTextStyleMediumLargeWithSize(
                                                          context, 20),
                                                ))),
                                      ): gapH32,
                                result == null
                                    ? gapW32
                                    : SizedBox(
                                        height: 32,
                                        child: Center(
                                          child: Text('$result'),
                                        ),
                                      )
                              ],
                            )),
                      ),
                    )
                  : gapH32,
              gapH32,
              _showEditor ? gapH4 : gapH32,
              Expanded(
                  child: VehicleListWidget(
                vehicles: cars,
                onVehiclePicked: (car) {
                  pp('$mm .... car picked: ${car.toJson()}');
                  vehicle = car;
                  _setup(car);
                },
                onEditVehicle: () {
                  setState(() {
                    _showEditor = true;
                  });
                },
              ))
            ],
          ),
          Positioned(
            right: 24,
            top: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Vehicles',
                  style: myTextStyle(fontSize: 18, weight: FontWeight.w900),
                ),
                gapW32,
                GestureDetector(
                  onTap: () {
                    pp('$mm ... refresh cars ...');
                    _getCars(true);
                  },
                  child: bd.Badge(
                    badgeContent: Text(
                      '${cars.length}',
                      style: TextStyle(color: Colors.white),
                    ),
                    badgeStyle: bd.BadgeStyle(
                      badgeColor: Colors.blue.shade800,
                      elevation: 8,
                      padding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                gapW32,
                gapW32,
                _showEditor
                    ? IconButton(
                        tooltip: 'Close Vehicle Editor',
                        onPressed: () {
                          setState(() {
                            _showEditor = false;
                          });
                        },
                        icon: Icon(Icons.close))
                    : IconButton(
                        tooltip: 'Open Vehicle Editor',
                        onPressed: () {
                          setState(() {
                            _showEditor = true;
                          });
                        },
                        icon: Icon(Icons.edit)),
              ],
            ),
          ),
          _showErrors
              ? Positioned(
                  child: Center(
                  child: Container(
                    color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CarErrors(
                        cars: errorCars,
                        onClose: () {
                          setState(() {
                            _showErrors = false;
                          });
                        },
                      ),
                    ),
                  ),
                ))
              : gapW32,
          busy
              ? Positioned(
                  child: Center(
                      child: TimerWidget(
                          title: 'Uploading vehicle file', isSmallSize: true)))
              : gapW32,
        ],
      )),
    );
  }
}

class CarErrors extends StatelessWidget {
  const CarErrors({super.key, required this.cars, required this.onClose});

  final List<Vehicle> cars;
  final Function onClose;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.sizeOf(context).height;
    var width = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: height / 2,
      width: width / 2,
      child: Column(
        children: [
          gapH32,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              gapW32,
              Text(
                'Vehicle Upload Errors',
                style: myTextStyle(fontSize: 20, weight: FontWeight.w900),
              ),
              IconButton(
                  onPressed: () {
                    onClose();
                  },
                  icon: Icon(Icons.close)),
            ],
          ),
          gapH32,
          Text(
              'The vehicles listed below were not created. They may have been created previously'),
          gapH32,
          Expanded(
            child: SizedBox(
              height: (height / 2) - 100,
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6),
                      itemCount: cars.length,
                      itemBuilder: (_, index) {
                        var car = cars[index];
                        return Card(
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${car.vehicleReg}',
                                  style: myTextStyle(
                                      color: Colors.amber.shade900,
                                      fontSize: 16),
                                ),
                                Text(
                                  '${car.make}',
                                  style: myTextStyle(fontSize: 10),
                                ),
                                Text(
                                  '${car.model}',
                                  style: myTextStyle(fontSize: 10),
                                ),
                                Text(
                                  '${car.year}',
                                  style: myTextStyle(
                                      fontSize: 12, weight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
