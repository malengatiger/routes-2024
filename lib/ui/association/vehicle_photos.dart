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
    pp('vehiclePhotos build .... photos car: ${vehicle.photos!.length}');
    return SizedBox(
      height: 1200,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    onClose();
                  },
                  icon: Icon(Icons.close))
            ],
          ),
          gapH32,
          Expanded(
            child: Card(
              elevation: 12,
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemCount: vehicle.photos!.length,
                    itemBuilder: (_, index) {
                      var car = vehicle.photos![index];
                      return GestureDetector(
                        onTap: () {
                          onPhotoPicked(car);
                        },
                        child: Card(
                          elevation: 8,
                          child: CachedNetworkImage(
                            imageUrl: car.url!, fit: BoxFit.cover,
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
