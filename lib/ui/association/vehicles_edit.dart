import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';

class VehiclesEdit extends StatefulWidget {
  const VehiclesEdit({super.key});

  @override
  VehiclesEditState createState() => VehiclesEditState();
}

class VehiclesEditState extends State<VehiclesEdit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Association Vehicles',  style: myTextStyleMediumLarge(context, 24), ),
      ),
      body: SafeArea(child: Stack(
        children: [],
      )),
    );
  }
}
