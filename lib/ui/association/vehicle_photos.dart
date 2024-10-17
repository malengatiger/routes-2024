import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:cached_network_image/cached_network_image.dart';
class VehiclePhotos extends StatelessWidget {
  const VehiclePhotos({super.key, required this.vehicle, required this.photos, required this.onPhotoPicked});

  final Vehicle vehicle;
  final List<VehiclePhoto> photos;
  final Function(VehiclePhoto) onPhotoPicked;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
        itemCount: photos.length,
        itemBuilder: (_, index) {
          var car = photos[index];
          return GestureDetector(
            onTap: (){
              onPhotoPicked(car);
            },
            child: Card(
              elevation: 8,
              child: CachedNetworkImage(
                imageUrl: car.url!,
              ),
            ),
          );
        });
  }
}
