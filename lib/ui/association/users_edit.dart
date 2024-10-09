import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';

class UsersEdit extends StatefulWidget {
  const UsersEdit({super.key});

  @override
  UsersEditState createState() => UsersEditState();
}

class UsersEditState extends State<UsersEdit>
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
        title:  Text('Association Users', style: myTextStyleMediumLarge(context, 24), ),
      ),
      body: SafeArea(child: Stack(
        children: [],
      )),
    );
  }
}
