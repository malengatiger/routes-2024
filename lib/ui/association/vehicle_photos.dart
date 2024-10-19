import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kasie_transie_library/utils/functions.dart';

class VehiclePhotos extends StatelessWidget {
  const VehiclePhotos(
      {super.key,
      required this.vehicle,
      required this.onPhotoPicked,
      required this.onClose});

  final Vehicle vehicle;
  final Function(VehiclePhoto) onPhotoPicked;
  final Function onClose;

  @override
  Widget build(BuildContext context) {
    pp('vehiclePhotos build .... photos photo: ${vehicle.photos!.length}');
    var height = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: height / 1.2,
      child: Column(
        children: [
          Container(
            color: Colors.black54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    tooltip: 'Close Vehicle Photos',
                    onPressed: () {
                      onClose();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).primaryColor,
                    ))
              ],
            ),
          ),
          gapH32,
          Expanded(
            child: vehicle.photos!.length == 1
                ? Card(
                    elevation: 8,
                    child: CachedNetworkImage(
                      imageUrl: vehicle.photos![0].url!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Card(
                    elevation: 12,
                    color: Colors.black54,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemCount: vehicle.photos!.length,
                          itemBuilder: (_, index) {
                            var photo = vehicle.photos![index];
                            var df = getFormattedDateLong(photo.created!);
                            return GestureDetector(
                              onTap: () {
                                onPhotoPicked(photo);
                              },
                              child: Card(
                                elevation: 8,
                                child: Column(
                                  children: [
                                    gapH8,
                                    Text(
                                      '${photo.vehicleReg} - $df',
                                      style: myTextStyle(
                                          fontSize: 12,
                                          weight: FontWeight.w900),
                                    ),
                                    gapH8,
                                    Expanded(
                                      child: CachedNetworkImage(
                                        imageUrl: photo.url!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
