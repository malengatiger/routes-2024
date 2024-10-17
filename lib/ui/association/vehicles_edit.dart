import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:badges/badges.dart' as bd;
import 'package:routes_2024/ui/association/vehicle_list_widget.dart';

class VehiclesEdit extends StatefulWidget {
  const VehiclesEdit({super.key, required this.association, this.vehicle});

  final Association association;
  final Vehicle? vehicle;

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
    _setup();
    _getCars();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController registrationController = TextEditingController();
  TextEditingController makeController = TextEditingController(text: 'Toyota');
  TextEditingController modelController =
      TextEditingController(text: 'Quantum');
  TextEditingController yearController = TextEditingController(text: '2024');
  TextEditingController capacityController = TextEditingController(text: '16');

  TextEditingController ownerNameController =
      TextEditingController(text: 'John Mathebula');
  TextEditingController cellphoneController =
      TextEditingController(text: '+27724457766');

  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  bool busy = false;
  Prefs prefs = GetIt.instance<Prefs>();
  Vehicle? vehicle;
  List<VehiclePhoto> vehiclePhotos = [];
  List<VehicleVideo> vehicleVideos = [];

  void _setup() async {
    if (widget.vehicle != null) {
      registrationController.text = widget.vehicle!.vehicleReg!;
      modelController.text = widget.vehicle!.model!;
      makeController.text = widget.vehicle!.make!;
      yearController.text = widget.vehicle!.year!;
      capacityController.text = '${widget.vehicle!.passengerCapacity}';
      ownerNameController.text = widget.vehicle!.ownerName ?? '';
      cellphoneController.text = widget.vehicle!.ownerCellphone ?? '';
      country = prefs.getCountry();
      setState(() {});
    }
    if (vehicle != null) {
      registrationController.text = vehicle!.vehicleReg!;
      modelController.text = vehicle!.model!;
      makeController.text = vehicle!.make!;
      yearController.text = vehicle!.year!;
      capacityController.text = '${vehicle!.passengerCapacity!}';
      ownerNameController.text = vehicle!.ownerName ?? '';
      cellphoneController.text = vehicle!.ownerCellphone ?? '';
      country = prefs.getCountry();
      setState(() {});
    }
  }

  List<Vehicle> cars = [];
  String? result;

  void _getCars() async {
    cars =
        await listApiDog.getAssociationCars(widget.association.associationId!, false);
    setState(() {});
  }

  _onSubmit() async {
    pp('$mm on submit wanted ...');
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      busy = true;
    });
    if (widget.vehicle == null) {
      vehicle = Vehicle(
          vehicleId: '${DateTime.now().millisecondsSinceEpoch}',
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

      try {
        var res = await dataApiDog.addVehicle(vehicle!);
        _getCars();
        if (mounted) {
          showOKToast(
              message: 'Vehicle registered on KasieTransie', context: context);
        }
      } catch (e, s) {
        pp('$e $s');
        if (mounted) {
          showErrorToast(message: '$e', context: context);
        }
      }
    } else {
      //TODO - update the Vehicle
      pp('$mm  update the Vehicle ...');
    }
    setState(() {
      busy = false;
    });
  }

  PlatformFile? csvFile, vehiclePictureFile;

  void _pickVehicleFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      csvFile = result.files.first; // Assign PlatformFile directly
      pp('$mm csvFile exists: ${csvFile?.bytes!.length} bytes');
      setState(() {});
    } else {
      // Handle file picking on mobile/desktop (using path)
      // Handle case where bytes are null
      pp('$mm Error: File bytes are null');
      if (mounted) {
        showErrorToast(message: 'The file is not cool', context: context);
      }
    }
  }

  Country? country;
  Association? association;

  _sendFile() async {
    pp('$mm  send the Vehicle File ...');
    setState(() {
      busy = true;
    });

    try {
      var addCarsResponse = await dataApiDog.importVehiclesFromCSV(
          csvFile!, widget.association.associationId!);
      _getCars();
      if (mounted) {
        var msg =
            '🌿 Vehicles added: ${addCarsResponse!.cars.length} errors: ${addCarsResponse.errors.length}';
        result = msg;
        showOKToast(message: msg, context: context);
      }
    } catch (e, s) {
      pp('$e $s');
      result = '$e';
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  bool _showEditor = true;

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
                                gapH8,
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
                                gapH8,
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
                                gapH8,
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
                                gapH8,
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
                                gapH8,
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
                                gapH8,
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
                                    : SizedBox(
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
                                      ),
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
              Expanded(
                  child: VehicleListWidget(
                vehicles: cars,
                onVehiclePicked: (car, photos, videos) {
                  pp('$mm car picked: ${car.toJson()}');
                  pp('$mm car photos: ${photos.length}');
                  vehicle = car;
                  _setup();
                  setState(() {
                    vehiclePhotos = photos;
                    vehicleVideos = videos;
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
                Text('Vehicles'),
                gapW32,
                bd.Badge(
                  badgeContent: Text(
                    '${cars.length}',
                    style: TextStyle(color: Colors.white),
                  ),
                  badgeStyle: bd.BadgeStyle(
                    badgeColor: Colors.blue.shade800,
                    elevation: 12,
                    padding: EdgeInsets.all(16),
                  ),
                ),
                gapW32,
                _showEditor
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _showEditor = false;
                          });
                        },
                        icon: Icon(Icons.close))
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            _showEditor = true;
                          });
                        },
                        icon: Icon(Icons.edit)),
              ],
            ),
          )
        ],
      )),
    );
  }
}
