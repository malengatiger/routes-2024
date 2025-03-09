import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:badges/badges.dart' as bd;
import 'package:routes_2024/ui/association/vehicle_photos.dart';

import '../../library/data_api.dart';
import '../../library/qr_code_generation.dart';

class VehicleListWidget extends StatefulWidget {
  const VehicleListWidget(
      {super.key,
      required this.vehicles,
      required this.onVehiclePicked,
      required this.onEditVehicle});

  final List<Vehicle> vehicles;
  final Function(Vehicle) onVehiclePicked;
  final Function onEditVehicle;

  @override
  State<VehicleListWidget> createState() => _VehicleListWidgetState();
}

class _VehicleListWidgetState extends State<VehicleListWidget> {
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  DeviceLocationBloc deviceLocationBloc = GetIt.instance<DeviceLocationBloc>();
  bool busy = false;
  List<VehiclePhoto> photos = [];
  List<VehicleVideo> videos = [];
  SemCache semCache = GetIt.instance<SemCache>();

  static const mm = '🍎🍎🍎🍎🍎 VehicleListWidget';
  PlatformFile? vehiclePictureFile;
  bool _showActions = false;
  int? _showIndex;

  @override
  void initState() {
    super.initState();
    printCars();
  }
void printCars() {
    pp('$mm printing cars ...');
    int cnt = 1;
    for (var c in widget.vehicles) {
      pp('$mm car #$cnt: ${c.toJson()}');
      cnt++;
    }
}
  void _pickVehiclePictureFile(Vehicle vehicle) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      vehiclePictureFile = result.files.first; // Assign PlatformFile directly
      pp('$mm vehiclePictureFile exists: ${vehiclePictureFile?.bytes!.length} bytes');
      _showVehicleDialog(vehiclePictureFile!, vehicle);
    } else {
      // Handle file picking on mobile/desktop (using path)
      // Handle case where bytes are null
      pp('$mm Error: File bytes are null');
      if (mounted) {
        showErrorToast(message: 'The file is not cool', context: context);
      }
    }
  }

  _showVehicleDialog(PlatformFile file, Vehicle car) async {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              '${car.vehicleReg}',
              style: myTextStyle(weight: FontWeight.w900),
            ),
            content: Text('Pick the vehicle picture and upload'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _uploadFile(file, car);
                  },
                  child: Text('Submit')),
            ],
          );
        });
  }

  _uploadFile(PlatformFile file, Vehicle car) async {
    pp('$mm ... .... upload vehicle picture ... ${car.toJson()}');

    setState(() {
      busy = true;
    });
    try {
      var loc = await deviceLocationBloc.getLocation();
      pp('$mm ............. location: ${loc.latitude} ${loc.longitude}');
      await dataApiDog.uploadVehiclePhoto(
          file: file,
          thumb: file,
          vehicleId: car.vehicleId!,
          latitude: loc.latitude,
          longitude: loc.longitude);
      _getCarMedia(car);
      if (mounted) {
        showOKToast(
            message:
                '${car.vehicleReg} - Vehicle photo uploaded successfully 🥬🥬',
            context: context);
      }
    } catch (e, s) {
      pp('$s $s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }

    setState(() {
      busy = false;
    });
  }

  _getCarMedia(Vehicle car) async {
    setState(() {
      busy = true;
    });
    pp('$mm get vehicle photos ...');
    try {
      photos = await listApiDog.getVehiclePhotos(car, false);
      photos.sort((a, b) => b.created!.compareTo(a.created!));
      videos = await listApiDog.getVehicleVideos(car, false);
      videos.sort((a, b) => b.created!.compareTo(a.created!));
      car.photos = photos;
      car.videos = videos;
      await semCache.saveVehicles([car]);
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

  bool isGallery = false;
  Vehicle? selectedCar;

  _showCarPhotos(Vehicle car) {
    pp('$mm _showCarPhotos: setting selected car and state ...');
    selectedCar = car;
    setState(() {
      isGallery = true;
    });
  }

  _takeVehiclePicture(Vehicle vehicle) async {
    pp('$mm take vehicle picture');
  }

  _sendVehicleEmail(Vehicle vehicle) async {
    pp('$mm send vehicle email');
  }

  _updateQRCode(Vehicle vehicle) async {
    pp('$mm _updateQRCode ...');
    try {

      var res = await dataApiDog.updateVehicle(vehicle);
      if (mounted) {
        showOKToast(
            message:
            'Vehicle QRCode updated on KasieTransie: ${vehicle.vehicleReg}',
            context: context);
      }
    } catch (e, s) {
      pp('$e $s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Stack(
      children: [
        GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemCount: widget.vehicles.length,
            itemBuilder: (_, index) {
              var car = widget.vehicles[index];
              var photos = 0;
              if (car.photos != null && car.photos!.isNotEmpty) {
                photos = car.photos!.length;
              }
              var (col, s) = getRandomColor();
              return GestureDetector(
                onTap: () {
                  _showActions = true;
                  _showIndex = index;
                  widget.onVehiclePicked(car);
                  _getCarMedia(car);
                },
                child: Card(
                  elevation: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      bd.Badge(
                          badgeContent: photos == 0
                              ? gapH4
                              : Text(
                                  '$photos',
                                  style: myTextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                          badgeStyle: photos == 0
                              ? bd.BadgeStyle(badgeColor: Colors.transparent)
                              : bd.BadgeStyle(
                                  badgeColor: col,
                                  padding: EdgeInsets.all(8.0),
                                ),
                          child: GestureDetector(
                            onTap: () {
                              pp('$mm car profile picture tapped: ${car.vehicleReg}');
                              _showCarPhotos(car);
                            },
                            child: VehicleProfilePicture(
                              car: car,
                            ),
                          )),
                      gapH16,
                      Text(
                        car.vehicleReg!,
                        style:
                            myTextStyle(fontSize: 16, weight: FontWeight.w900),
                      ),
                      Text('${car.make} ${car.model}',
                          style: myTextStyle(
                            fontSize: 12,
                          )),
                      Text(
                        car.year!,
                        style:
                            myTextStyle(fontSize: 10, weight: FontWeight.w900),
                      ),
                      if (_showActions && _showIndex == index)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Card(
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  kIsWeb
                                      ? gapH4
                                      : IconButton(
                                          onPressed: () {
                                            _takeVehiclePicture(car);
                                          },
                                          tooltip: 'Take photo of vehicle',
                                          icon: Icon(
                                            Icons.camera_alt_outlined,
                                            color: Colors.green,
                                          )),
                                  IconButton(
                                      tooltip: 'Send email to Owner',
                                      onPressed: () {
                                        _sendVehicleEmail(car);
                                      },
                                      icon: Icon(
                                        Icons.email_outlined,
                                        color: Colors.blue,
                                      )),
                                  IconButton(
                                      tooltip: 'Update QR Code',
                                      onPressed: () {
                                        _updateQRCode(car);
                                      },
                                      icon: Icon(
                                        Icons.barcode_reader,
                                        color: Colors.black,
                                      )),
                                  IconButton(
                                      onPressed: () {
                                        _pickVehiclePictureFile(car);
                                      },
                                      tooltip: 'Pick vehicle image file',
                                      icon: Icon(
                                        Icons.upload,
                                        color: Colors.pink,
                                      )),
                                  IconButton(
                                      tooltip: 'Show all vehicle photos',
                                      onPressed: () {
                                        _showCarPhotos(car);
                                      },
                                      icon: Icon(
                                        Icons.list,
                                        color: Colors.amber,
                                      )),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          widget.onEditVehicle();
                                        });
                                      },
                                      tooltip: 'Edit the vehicle details',
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.indigo,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
        busy
            ? Positioned(
                child: Center(
                child: TimerWidget(
                    title: 'Uploading vehicle photo', isSmallSize: true),
              ))
            : gapW32,
        isGallery
            ? Positioned(
                child: Center(
                child: SizedBox(
                  width: width / 2,
                  child: VehiclePhotos(
                    vehicle: selectedCar!,
                    onPhotoPicked: (p) {
                      pp('$mm onPhotoPicked');
                    },
                    onClose: () {
                      setState(() {
                        isGallery = false;
                      });
                    },
                  ),
                ),
              ))
            : gapW32,
      ],
    );
  }
}

class VehicleProfilePicture extends StatelessWidget {
  const VehicleProfilePicture({super.key, required this.car});

  final Vehicle car;

  @override
  Widget build(BuildContext context) {
    if (car.photos == null || car.photos!.isEmpty) {
      return SizedBox(
        width: 36,
        height: 36,
        child: Image.asset(
          'assets/car1.png',
          height: 36,
          width: 36,
          fit: BoxFit.cover,
        ),
      );
    }
    return SizedBox(
        width: 60,
        height: 60,
        child: CircleAvatar(
          backgroundImage: NetworkImage(car.photos!.first.url!),
          radius: 60,
        ));
  }
}
