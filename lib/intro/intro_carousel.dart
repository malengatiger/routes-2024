import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routes_2024/intro/intro_page_one.dart';

class IntroCarousel extends StatefulWidget {
  const IntroCarousel({super.key});

  @override
  State<IntroCarousel> createState() => _IntroCarouselState();
}

class _IntroCarouselState extends State<IntroCarousel> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScreenTypeLayout.builder(
          mobile: (_) {
            return Container(
              color: Colors.red,
            );
          },
          tablet: (_) {
            return Container(color: Colors.teal);
          },
          desktop: (_) {
            return Container(color: Colors.teal);
          },
        )
      ],
    );
  }
}

class BigCarousel extends StatelessWidget {
  const BigCarousel({super.key, required this.items, required this.onPageChanged});
  final Function(int) onPageChanged;
  final List<IntroPage> items;
  @override
  Widget build(BuildContext context) {
    var initialPage = Random().nextInt(9);
    var options= CarouselOptions(
      enlargeCenterPage: true,
      autoPlay: true,
      pauseAutoPlayOnTouch: true,
      initialPage: initialPage,
    );
    // return Column(children: [
    //   Expanded(child: CarouselSlider(items: items, options: options)),
    // ],);
    return PageView(children: items, onPageChanged: (p){
      onPageChanged(p);
    },);

  }
}
