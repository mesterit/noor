import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Janaty/exports/pages.dart' show Ad3yahList, MyAd3yah;
import 'package:Janaty/exports/constants.dart' show Titles, JanatyCategory;
import 'package:Janaty/exports/components.dart' show CardSliverAppBar, ListItem;
import 'package:Janaty/exports/controllers.dart' show ThemeModel;

class Ad3yah extends StatefulWidget {
  const Ad3yah({Key? key}) : super(key: key);
  @override
  _Ad3yahState createState() => _Ad3yahState();
}

class _Ad3yahState extends State<Ad3yah> with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  int index = 0;
  double maxHeight = 180;

  @override
  Widget build(BuildContext context) {
    final ThemeModel theme = context.watch<ThemeModel>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CardSliverAppBar(cardImagePath: theme.images.ad3yahCard),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Ad3yahTitleCard(
                  title: Titles.quraan,
                  icon: theme.images.quraanTitleIcon,
                  category: JanatyCategory.quraan,
                ),
                Ad3yahTitleCard(
                  title: Titles.sunnah,
                  icon: theme.images.sunnahTitleIcon,
                  category: JanatyCategory.sunnah,
                ),
                Ad3yahTitleCard(
                  title: Titles.ruqya,
                  icon: theme.images.ruqyaTitleIcon,
                  category: JanatyCategory.ruqiya,
                ),
                Ad3yahTitleCard(
                  title: Titles.myAd3yah,
                  icon: theme.images.myAd3yahTitleIcon,
                  category: JanatyCategory.myad3yah,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Ad3yahTitleCard extends StatelessWidget {
  const Ad3yahTitleCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.category,
  }) : super(key: key);

  final String icon;
  final String title;
  final JanatyCategory category;

  @override
  Widget build(BuildContext context) {
    return ListItem(
      icon: icon,
      title: title,
      onTap: () {
        if (category == JanatyCategory.myad3yah) {
          Navigator.of(context).push(
            MaterialPageRoute<MyAd3yah>(
              builder: (_) => const MyAd3yah(),
              fullscreenDialog: true,
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute<Ad3yahList>(
              builder: (_) => Ad3yahList(category: category),
              fullscreenDialog: true,
            ),
          );
        }
      },
    );
  }
}
