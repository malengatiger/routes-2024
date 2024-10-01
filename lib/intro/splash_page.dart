import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({super.key});

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  static const mm = '💠💠💠💠💠💠💠💠 SplashWidget';

  @override
  void initState() {
    super.initState();
    _performSetup();
  }

  String? message;

  void _performSetup() async {

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: AnimatedContainer(
        width: 400, height: 400,
        curve: Curves.easeInOutCirc,
        duration: const Duration(milliseconds: 3000),
        child: Card(
          elevation: 8.0,
          child: Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/ktlogo_red.png',
                    height: 200,
                    width: 200,
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message == null ? 'We help you see more!' : message!,
                    style: myTextStyleSmall(context),
                  ),

                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
