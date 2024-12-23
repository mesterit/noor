import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:Janaty/library/Globals.dart' as globals;
import 'package:Janaty/widget/SliderAlert.dart';
//import 'package:Janaty/widget/screen.dart';

import 'package:Janaty/entity/Surah.dart';
import 'package:Janaty/builder/SurahListBuilder.dart';
import 'package:Janaty/builder/SurahViewBuilder.dart';

class Quran extends StatefulWidget {
  @override
  _QuranState createState() => _QuranState();
}

class _QuranState extends State<Quran> {
  /// Used for Bottom Navigation
  int _selectedQuran = 0;

  /// Get Screen Brightness
  void getScreenBrightness() async {
    //globals.brightnessLevel = await Screen.brightness;
  }

  /// Navigation event handler
  _onItemTapped(int Quran) {
    setState(() {
      _selectedQuran = Quran;
    });

    /// Go to Bookmarked page
    if (Quran == 0) {
      setState(() {
        /// in case Bookmarked page is null (Bookmarked page initialized in splash screen)
        if (globals.bookmarkedPage == null) {
          globals.bookmarkedPage = globals.DEFAULT_BOOKMARKED_PAGE;
        }
      });
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  SurahViewBuilder(pages: globals.bookmarkedPage - 1)),
              (Route<dynamic> route) => false);

      /// Continue reading
    } else if (Quran == 1) {
      if (globals.lastViewedPage != null) {
        /// Push to Quran view ([int pages] represent surah page(reversed Quran))
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SurahViewBuilder(pages: globals.lastViewedPage - 1)));
      }

      /// Customize Screen Brightness
    } else if (Quran == 2) {
      if (globals.brightnessLevel == null) {
        getScreenBrightness();
      }
      showDialog(context: this.context, builder: (context) => SliderAlert());
    }
  }

  void redirectToLastVisitedSurahView() {
    print("redirectTo:${globals.lastViewedPage}");
    if (globals.lastViewedPage != null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  SurahViewBuilder(pages: globals.lastViewedPage)),
              (Route<dynamic> route) => false);
    }
  }

  @override
  void initState() {
    /// set saved Brightness level
    //Screen.setBrightness(globals.brightnessLevel);
    //Screen.keepOn(true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          /*leading: IconButton(
            icon: Icon(
              Icons.tune,
              color: Colors.white,
            ),
            onPressed: (){
              showDialog(context: this.context,
                  builder:(context)=>SliderAlert());
            },
          ),*/
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                  padding: const EdgeInsets.all(8.0), child: Text('الفهرس')),
              Icon(
                Icons.format_list_numbered_rtl,
                color: Colors.white,
              ),
            ],
          ),
        ),
        body: Container(
          child: Directionality(
            textDirection: TextDirection.rtl,

            /// Use future builder and DefaultAssetBundle to load the local JSON file
            child: new FutureBuilder(
                future: DefaultAssetBundle.of(context)
                    .loadString('assets/json/surah.json'),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Surah> surahList = parseJson(snapshot.data.toString());
                    return surahList.isNotEmpty
                        ? new SurahListBuilder(surah: surahList)
                        : new Center(child: new CircularProgressIndicator());
                  } else {
                    return new Center(child: new CircularProgressIndicator());
                  }
                }),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'الإنتقال إلى العلامة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chrome_reader_mode),
              label: 'مواصلة القراءة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.highlight),
              label: 'إضاءة الشاشة',
            ),
          ],
          currentQuran: _selectedQuran,
          selectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          onTap: (Quran) => _onItemTapped(Quran),
        ),
      ),
    );
  }

  List<Surah> parseJson(String response) {
    if (response == null) {
      return [];
    }
    final parsed =
    json.decode(response.toString()).cast<Map<String, dynamic>>();
    return parsed.map<Surah>((json) => new Surah.fromJson(json)).toList();
  }
}