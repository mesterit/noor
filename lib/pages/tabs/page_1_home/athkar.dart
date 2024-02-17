import 'package:flutter/material.dart';
import 'package:Almuslim/components/card_sliver_app_bar.dart';
import 'package:provider/provider.dart';

import 'package:Almuslim/exports/services.dart' show DBService;
import 'package:Almuslim/exports/controllers.dart' show ThemeModel;
import 'package:Almuslim/exports/constants.dart' show Images;
import 'package:Almuslim/exports/models.dart' show DataModel, Thekr;
import 'package:Almuslim/exports/pages.dart' show AthkarList;
import 'package:Almuslim/exports/components.dart' show ListItem;

class AthkarPage extends StatefulWidget {
  const AthkarPage({Key? key}) : super(key: key);

  @override
  _AthkarPageState createState() => _AthkarPageState();
}

class _AthkarPageState extends State<AthkarPage>
    with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  double maxHeight = 180;

  @override
  initState() {
    super.initState();
    DBService.db.initDB();
  }

  @override
  Widget build(BuildContext context) {
    final Images images = context.read<ThemeModel>().images;
    final DataModel model = Provider.of<DataModel>(context);
    final List<Thekr> athkarTitles = Provider.of<DataModel>(context)
        .athkar
        .where((Thekr thekr) => thekr.isTitle)
        .toList();
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        CardSliverAppBar(cardImagePath: images.athkarCard),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final Thekr title = athkarTitles[index];
              final int position = model.athkar.indexOf(title);

              return title.isTitle
                  ? ListItem(
                      title: title.text,
                      icon: images.athkarTitleIcon,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<AthkarList>(
                            builder: (_) => AthkarList(index: position),
                          ),
                        );
                      },
                    )
                  : Container();
            },
            childCount: athkarTitles.length,
          ),
        )
      ],
    ));
  }
}
