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

class VehicleListWidget extends StatefulWidget {
  const VehicleListWidget(
      {super.key, required this.vehicles, required this.onVehiclePicked});

  final List<Vehicle> vehicles;
  final Function(Vehicle, List<VehiclePhoto>, List<VehicleVideo>)
      onVehiclePicked;

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
      await dataApiDog.importVehicleProfile(
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
      photos = await listApiDog.getVehiclePhotos(car.vehicleId!, true);
      photos.sort((a, b) => b.created!.compareTo(a.created!));
      videos = await listApiDog.getVehicleVideos(car.vehicleId!, true);
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

  _showConfirmDialog(Vehicle car) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text(
                'Do you want to fetch any existing photos and videos of ${car.vehicleReg}'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _getCarMedia(car);
                  },
                  child: Text('Get Media')),
            ],
          );
        });
  }

  _takeVehiclePicture(Vehicle vehicle) async {
    pp('$mm take vehicle picture');
  }

  _sendVehicleEmail(Vehicle vehicle) async {
    pp('$mm send vehicle email');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
            itemCount: widget.vehicles.length,
            itemBuilder: (_, index) {
              var car = widget.vehicles[index];
              var photos = 0;
              if (car.photos != null && car.photos!.isNotEmpty) {
                photos = car.photos!.length;
              }
              return GestureDetector(
                onTap: () {
                  _showActions = true;
                  _showIndex = index;
                  _getCarMedia(car);
                },
                child: Card(
                  elevation: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      bd.Badge(
                          badgeContent: photos == 0? gapH4: Text('$photos',
                            style: myTextStyle(color: Colors.white, fontSize: 10),),
                          badgeStyle: photos == 0? bd.BadgeStyle(
                            badgeColor: Colors.transparent
                          ): bd.BadgeStyle(
                            badgeColor: Colors.red, padding: EdgeInsets.all(8.0),
                          ),
                          child: VehicleProfilePicture(
                            car: car,
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
                        Card(
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                               kIsWeb? gapH4: IconButton(
                                    onPressed: () {
                                      _takeVehiclePicture(car);
                                    },
                                    icon: Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.green,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      _sendVehicleEmail(car);
                                    },
                                    icon: Icon(
                                      Icons.email_outlined,
                                      color: Colors.blue,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      _pickVehiclePictureFile(car);
                                    },
                                    icon: Icon(
                                      Icons.folder,
                                      color: Colors.pink,
                                    )),
                              ],
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
        width: 48,
        height: 48,
        child: Image.asset(
          'assets/car1.png',
          height: 48,
          width: 48,
          fit: BoxFit.cover,
        ),
      );
    }
    return SizedBox(
        width: 72,
        height: 72,
        child: CircleAvatar(
          backgroundImage: NetworkImage(car.photos!.first.url!),
          radius: 72,
        ));
  }
}
