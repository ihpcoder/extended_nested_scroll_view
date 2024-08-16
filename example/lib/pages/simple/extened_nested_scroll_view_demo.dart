import 'package:example/common/common.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

@FFRoute(
  name: 'fluttercandies://nestedscrollview',
  routeName: 'NestedScrollview',
  description: 'fix pinned header and inner scrollables sync issues.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 0,
  },
)
class ExtendedNestedScrollViewDemo extends StatefulWidget {
  @override
  _ExtendedNestedScrollViewDemoState createState() =>
      _ExtendedNestedScrollViewDemoState();
}

class _ExtendedNestedScrollViewDemoState
    extends State<ExtendedNestedScrollViewDemo> with TickerProviderStateMixin {
  late final TabController primaryTC;
  late final TabController secondaryTC;
  ScrollController scrollController = ScrollController(debugLabel: 'custom');

  @override
  void initState() {
    super.initState();
    primaryTC = TabController(length: 2, vsync: this);
    secondaryTC = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    primaryTC.dispose();
    secondaryTC.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildScaffoldBody());
  }

  Widget _buildScaffoldBody() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double pinnedHeaderHeight =
    //statusBar height
    statusBarHeight +
        //pinned SliverAppBar height in header
        kToolbarHeight;
    return ExtendedNestedScrollView(
      controller: scrollController,
      headerSliverBuilder: (BuildContext c, bool f) {
        return buildSliverHeader().take(2).toList();
      },
      //1.[pinned sliver header issue](https://github.com/flutter/flutter/issues/22393)
      pinnedHeaderSliverHeightBuilder: () {
        return pinnedHeaderHeight;
      },
      //2.[inner scrollables in tabview sync issue](https://github.com/flutter/flutter/issues/21868)
      onlyOneScrollInBody: true,
      // physics: NeverScrollableScrollPhysics(),
      body: Column(
        children: <Widget>[
          TabBar(
            controller: primaryTC,
            labelColor: Colors.blue,
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2.0,
            isScrollable: false,
            unselectedLabelColor: Colors.grey,
            tabs: const <Tab>[Tab(text: 'Tab0'), Tab(text: 'Tab1')],
          ),
          Expanded(
            child: TabBarView(
              controller: primaryTC,
              children: <Widget>[
                SecondaryTabView('Tab0', secondaryTC),
                GlowNotificationWidget(
                  ExtendedVisibilityDetector(
                    uniqueKey: const Key('Tab1'),
                    child: ExtendedNestedScrollView(
                        onlyOneScrollInBody: true,
                        headerSliverBuilder: (ctx,inner){
                         var list = buildSliverHeader();
                         return [list[1],list[3]];
                        },
                        body: ListView.builder(
                            primary: true,
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: 100,
                            itemExtent: 100,
                            itemBuilder:(ctx,index)=> Container(
                              height: 100,
                              color: index % 2 == 0 ? Colors.red : Colors.blue,
                              alignment: Alignment.center,
                              child: Text(index.toString()),
                            ))
                    ),
                  ),
                  showGlowLeading: false,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
