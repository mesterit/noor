import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Janaty/exports/controllers.dart' show ThemeModel;
import 'package:provider/provider.dart';

class AlmuslimLogo extends StatelessWidget {
  const   AlmuslimLogo({Key? key, required this.size}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size(size, size),
      child: SvgPicture.asset(
        context.watch<ThemeModel>().images.logo,
      ),
    );
  }
}
