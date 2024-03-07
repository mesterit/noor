import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:Janaty/exports/models.dart' show AthkarCounter, DataModel, Thekr;
import 'package:Janaty/exports/controllers.dart' show AppSettings;
import 'package:Janaty/exports/components.dart'
    show AlmuslimCloseButton, ThekrTitleCard, AthkarCard;
import 'package:Janaty/exports/constants.dart' show viewPadding;

class AthkarList extends StatefulWidget {
  const AthkarList({Key? key, required this.index}) : super(key: key);
  final int index;
  @override
  _AthkarListState createState() => _AthkarListState();
}

class _AthkarListState extends State<AthkarList>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late ItemScrollController controller;
  ItemPositionsListener listener = ItemPositionsListener.create();
  late int pagePosition;

  @override
  get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    pagePosition = widget.index;

    controller = ItemScrollController();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      listener.itemPositions.addListener(changeAppBar);
    });
  }

  changeAppBar() {
    if (pagePosition != listener.itemPositions.value.first.index) {
      setState(() {
        pagePosition = listener.itemPositions.value.first.index;
      });
    }
  }

  onCardTap(int index, AthkarCounter counter) {
    final AppSettings settings = context.read<AppSettings>();

    counter.decrement();

    if (settings.vibrate) {
      if (counter.position > 0) {
        switch (settings.vibrationClick) {
          case 'light':
            HapticFeedback.heavyImpact();
            break;
          case 'strong':
            HapticFeedback.lightImpact();
            break;
        }
      }

      if (counter.position == 0) {
        switch (settings.vibrationDone) {
          case 'light':
            HapticFeedback.heavyImpact();
            break;
          case 'strong':
            HapticFeedback.lightImpact();
            break;
        }
      }
    }

    if (index < context.read<DataModel>().athkar.length &&
        settings.autoJump &&
        counter.position == 0) {
      Future<void>.delayed(const Duration(milliseconds: 500)).then(
        (_) {
          controller.scrollTo(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
              index: index + 1);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(
                  horizontal: viewPadding, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const SizedBox(width: 45),
                  Expanded(
                    child: Consumer<DataModel>(
                      builder: (BuildContext context, DataModel model, _) {
                        return AnimatedSwitcher(
                          child: Text(
                            model.athkar[pagePosition].sectionName,
                            textAlign: TextAlign.center,
                            key: ValueKey<String?>(
                              model.athkar[pagePosition].sectionName,
                            ),
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          duration: const Duration(milliseconds: 250),
                        );
                      },
                    ),
                  ),
                  AlmuslimCloseButton(
                      color: Theme.of(context).colorScheme.secondary),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<DataModel>(
              builder: (_, DataModel model, __) {
                //get only the atkar from the whole list!
                List<Thekr> athkar = model.athkar;

                final List<AthkarCounter> counterList = athkar
                    .map((Thekr thekr) => AthkarCounter(thekr.counter))
                    .toList();

                return Provider<List<AthkarCounter>>(
                  create: (_) => counterList,
                  child: Consumer<List<AthkarCounter>>(
                    builder: (_, List<AthkarCounter> countersList, __) {
                      return ScrollablePositionedList.builder(
                        key: const ValueKey<String>('list'),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemScrollController: controller,
                        itemPositionsListener: listener,
                        itemCount: athkar.length,
                        addAutomaticKeepAlives: true,
                        initialScrollIndex: widget.index,
                        minCacheExtent: 900,
                        padding: const EdgeInsets.only(bottom: 20),
                        itemBuilder: (_, int index) {
                          final Thekr thekr = athkar[index];
                          if (thekr.isTitle) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: ThekrTitleCard(title: thekr.text),
                            );
                          } else {
                            return ChangeNotifierProvider<AthkarCounter>.value(
                              value: countersList[index],
                              child: Consumer<AthkarCounter>(
                                builder: (_, AthkarCounter counter, __) =>
                                    AthkarCard(
                                  key: ValueKey<int>(index),
                                  thekr: thekr,
                                  onTap: () => onCardTap(index, counter),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class PersistedCard extends StatefulWidget {
  const PersistedCard({
    Key? key,
    required this.thekr,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  final Thekr thekr;
  final Function onTap;
  final int index;

  @override
  _PersistedCardState createState() => _PersistedCardState();
}

class _PersistedCardState extends State<PersistedCard>
    with AutomaticKeepAliveClientMixin {
  @override
  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AthkarCard(
      key: PageStorageKey<int?>(widget.index),
      thekr: widget.thekr,
      onTap: widget.onTap,
    );
  }
}
