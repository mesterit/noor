import 'package:flutter/material.dart';

import 'package:Janaty/exports/pages.dart' show RootHome;
import 'package:Janaty/exports/components.dart' show JanatyLogo;
import 'package:Janaty/models/theme.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double logoOpacity = 0.0;
  @override
  void initState() {
    Future<void>.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        logoOpacity = 1.0;
      });
    });
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    final images = Provider.of<ThemeModel>(context, listen: false).images;
    precacheImage(AssetImage(images.homeHeader), context);
    precacheImage(AssetImage(images.athkarCard), context);
    precacheImage(AssetImage(images.ad3yahCard), context);
    precacheImage(AssetImage(images.allahNamesCard), context);

    await Future<void>.delayed(const Duration(milliseconds: 800));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<RootHome>(
        builder: (_) => const RootHome(),
      ),
    );

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: logoOpacity,
          child:
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                width: 200,
                "assets/images/logo-white.png",
                fit: BoxFit.cover,

                gaplessPlayback: true,
              ),
          Text(
            "جَنَّتِي",
            key: ValueKey<String>("جَنَّتِي"),
            textAlign: TextAlign.center,
            style:  TextStyle(
              color: Colors.white,
              fontSize: 40,
              height: 3.5,
              fontWeight: FontWeight.bold
            ),
          ),])
        ),
      ),
    );
  }
}
