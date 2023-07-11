

import 'dart:async';

import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Size size = Size.zero;
  EdgeInsets padding = EdgeInsets.zero;
  final ScrollController _controller = ScrollController();
  List<int> topData = [];
  List<int> bottomData = [];
  int bottomPage = 1;
  int topPage = 1;

  bool topLoading = false;
  bool topFinished = false;

  bool bottomLoading = false;
  bool bottomFinished = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchForTheBottom();
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (!isTop){
          if(!bottomLoading && !bottomFinished){
            bottomLoading = true;
            fetchForTheBottom();
          }
        }else{
          if(!topLoading && !topFinished){
            topLoading = true;
            fetchForTheTop();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    padding = MediaQuery.of(context).padding;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: size.height - padding.top,
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            // physics: PositionRetainedScrollPhysics(shouldRetain: true),
            controller: _controller,
            child: Column(
              children: [
                if(topLoading)Container(
                  padding: EdgeInsets.symmetric(vertical: size.height*0.02),
                  child: const Icon(
                      Icons.downloading
                  ),
                ),
                ListView.builder(
                    itemCount: topData.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    reverse: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context,index){
                      return InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: (){
                          final double old = _controller.offset;
                          final double oldMax = _controller.position.maxScrollExtent;
                          setState(() {
                            topData.add(200);
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (old > 0.0) {
                              final diff = _controller.position.maxScrollExtent - oldMax;
                              _controller.jumpTo(old + diff);
                            }
                          });
                        },
                        child: Container(
                          // color: Colors.orange.withOpacity(0.1),
                          margin: EdgeInsets.symmetric(vertical: size.height*0.002),
                          padding: EdgeInsets.symmetric(vertical: size.height*0.03),
                          child: (index != 1)?Text(
                            "Item ${topData[index]}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: size.height*0.015
                            ),
                          ):Image(
                            image: NetworkImage("https://images.unsplash.com/photo-1575936123452-b67c3203c357?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW1hZ2V8ZW58MHx8MHx8fDA%3D&w=1000&q=80"),
                            height: size.height*0.2,
                          ),
                        ),
                      );
                    }
                ),
                ListView.builder(
                    itemCount: bottomData.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context,index){
                      return Container(
                        // color: Colors.orange.withOpacity(0.1),
                        margin: EdgeInsets.symmetric(vertical: size.height*0.002),
                        padding: EdgeInsets.symmetric(vertical: size.height*0.03),
                        child: Text(
                          "Item ${bottomData[index]}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: size.height*0.015
                          ),
                        ),
                      );
                    }
                ),
                if(bottomLoading)Container(
                  padding: EdgeInsets.symmetric(vertical: size.height*0.02),
                  child: const Icon(
                      Icons.downloading
                  ),
                )
              ],
            ),
          )
        ),
      )
    );
  }

  fetchForTheBottom() async {
    await Future.delayed(const Duration(seconds: 2));
    for(int i = (bottomPage - 1)* 20; i < bottomPage * 20; i++){
      bottomData.add(i);
    }
    bottomPage++;
    setState(() {
      bottomLoading = false;
    });
    if(bottomPage == 2){
      fetchForTheTop();
    }
  }

  Future<void> fetchForTheTop() async {
    final double oldMax = _controller.position.maxScrollExtent;

    await Future.delayed(const Duration(seconds: 2));
    List<int> list = [];
    for(int i = (topPage - 1)* 20; i < topPage * 20; i++){
      list.add(i);
    }
    final double old = _controller.offset;

    topData.addAll(list);
    topLoading = false;
    setState(() {});
    if(topPage == 1) {
      final diff = _controller.position.maxScrollExtent - oldMax;
      _controller.jumpTo(diff + (size.height - padding.top - padding.bottom));
    }else{
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final diff = _controller.position.maxScrollExtent - oldMax;
        _controller.jumpTo(old + diff);
      });
    }
    topPage++;
  }
}

class PositionRetainedScrollPhysics extends ScrollPhysics {
  final bool shouldRetain;
  const PositionRetainedScrollPhysics({super.parent, this.shouldRetain = true});

  @override
  PositionRetainedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PositionRetainedScrollPhysics(
      parent: buildParent(ancestor),
      shouldRetain: shouldRetain,
    );
  }

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    final position = super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );

    final diff = newPosition.maxScrollExtent - oldPosition.maxScrollExtent;

    if (oldPosition.pixels > oldPosition.minScrollExtent &&
        diff > 0 &&
        shouldRetain) {
      return position + diff;
    } else {
      return position;
    }
  }
}