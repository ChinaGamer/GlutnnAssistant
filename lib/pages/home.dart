import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glutnnbox/common/get.dart';
import 'package:glutnnbox/common/init.dart';
import 'package:glutnnbox/pages/schedule.dart';
import 'package:glutnnbox/widget/bars.dart';
import 'package:glutnnbox/widget/cards.dart';
import 'package:glutnnbox/widget/icons.dart';
import 'package:glutnnbox/widget/lists.dart';

import '../data.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  final ScrollController _scrollController = ScrollController();
  GlobalKey<RefreshIconWidgetDynamicState> iconKey = GlobalKey();
  bool _timeOutBool = true;
  double offset_ = 0.0;
  late AnimationController _animationControllerForHomeCards1;
  late AnimationController _animationControllerForHomeCards2;
  late AnimationController _animationControllerForHomeCards3;
  late Animation _animationForHomeCards1;
  late Animation _animationForHomeCards2;
  late Animation _animationForHomeCards3;
  ColorTween homeCardsColorTween = ColorTween(
      begin: const Color.fromARGB(42, 199, 229, 253),
      end: const Color.fromARGB(110, 199, 229, 253));
  int _goTopInitCount = 0;
  bool _bk = true;
  Timer? _time;

  @override
  void initState() {
    super.initState();
    // _getCode();
    _animationControllerForHomeCards1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });
    _animationControllerForHomeCards2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });
    _animationControllerForHomeCards3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });

    _animationForHomeCards1 = homeCardsColorTween.animate(_animationControllerForHomeCards1);
    _animationForHomeCards2 = homeCardsColorTween.animate(_animationControllerForHomeCards2);
    _animationForHomeCards3 = homeCardsColorTween.animate(_animationControllerForHomeCards3);

    _scrollController.addListener(_scrollControllerListener);
  }

  void _scrollControllerListener() {
    if (_timeOutBool) {
      int _offset = _scrollController.position.pixels.toInt();
      _offset < 0 ? iconKey.currentState!.onPressed((_offset / 25.0).abs() + offset_) : "";
      if (_offset < 0) {
        if ((_offset / 25.0).abs() >= 6.0) {
          final double __offset = (_offset / 25.0).abs();
          if (__offset == (_offset / 25.0).abs() || __offset + 0.25 < (_offset / 25.0).abs()) {
            Future.delayed(
              const Duration(milliseconds: 200),
              () {
                if (_timeOutBool) {
                  offset_ = (_offset / 25.0).abs();
                  _goTop();
                }
                _timeOutBool = false;
              },
            );
          }
        }
      }
    }
  }

  void _goTop() {
    print(_goTopInitCount);
    if (_goTopInitCount < 8) {
      print("刷新${DateTime.now()}");
      _goTopInitCount++;
      if (_goTopInitCount == 7) {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, "你这也太快了吧..."));
      } else if (_goTopInitCount == 1) {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(true, "开始刷新..."));
      }
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
      _time?.cancel();
      print(_time);
      _time = Timer(const Duration(seconds: 5), () {
        print("init");
        getWeek();
        initTodaySchedule();
        initTomorrowSchedule();
        todayCourseListKey.currentState!.reSate();
        tomorrowCourseListKey.currentState!.reSate();
        _timeOutBool = true;
        _goTopInitCount = 0;
      });

      int _count = 0;
      const period = Duration(milliseconds: 10);
      Timer.periodic(period, (timer) {
        _count++;
        offset_ += 0.15;
        iconKey.currentState!.onPressed(offset_);
        if (_count >= randomInt(100, 200)) {
          timer.cancel();
        }
      });
    } else {
      if (_bk) {
        _bk = false;
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, "你好快啊,求求你给我休息会吧..."));
        _time?.cancel();
        print(_time);
        _time = Timer(const Duration(seconds: 5), () {
          Future.delayed(const Duration(seconds: 5), () {
            _timeOutBool = true;
            _bk = true;
            _goTopInitCount = 0;
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  TextStyle _tomorrowAndTodayTextStyle() {
    return const TextStyle(fontSize: 14, color: Colors.black, decoration: TextDecoration.none);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          const HomeTopBar(),
          SliverToBoxAdapter(
              child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              textDirection: TextDirection.ltr,
              children: [
                InkWell(
                  onTap: () {
                    pageBus.fire(SetPageIndex(1));
                    pageBus.fire(ReState(1));
                  },
                  child: const HomeCard(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    GestureDetector(
                      onTapCancel: () {
                        _animationControllerForHomeCards1.reverse();
                      },
                      onTapUp: (d) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _goTop();
                          _animationControllerForHomeCards1.reverse();
                        });
                      },
                      onTapDown: (d) {
                        _animationControllerForHomeCards1.forward();
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 8, 4, 16),
                        height: 100,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                            color: _animationForHomeCards1.value),
                        child: Stack(
                          children: [
                            Align(
                              child: Container(
                                margin: HomeCardsState.iconMargin,
                                child: RefreshIconWidgetDynamic(key: iconKey),
                              ),
                            ),
                            Align(
                              child: Container(
                                margin: HomeCardsState.textMargin,
                                child: Text(
                                  HomeCardsState.iconTexts[0],
                                  style: HomeCardsState.textStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTapCancel: () {
                        _animationControllerForHomeCards2.reverse();
                      },
                      onTapUp: (d) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _animationControllerForHomeCards2.reverse();
                        });
                      },
                      onTapDown: (d) {
                        _animationControllerForHomeCards2.forward();
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                        height: 100,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                            color: _animationForHomeCards2.value),
                        child: homeCard2,
                      ),
                    ),
                    GestureDetector(
                      onTapCancel: () {
                        _animationControllerForHomeCards3.reverse();
                      },
                      onTapUp: (d) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _animationControllerForHomeCards3.reverse();
                        });
                      },
                      onTapDown: (d) {
                        _animationControllerForHomeCards3.forward();
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(4, 8, 0, 16),
                        height: 100,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                            color: _animationForHomeCards3.value),
                        child: homeCard3,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(todayScheduleTitle, style: _tomorrowAndTodayTextStyle()),
                ),
              ],
            ),
          )),
          TodayCourseList(
            key: todayCourseListKey,
          ),
          SliverToBoxAdapter(
              child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(tomorrowScheduleTitle, style: _tomorrowAndTodayTextStyle())),
          )),
          TomorrowCourseList(
            key: tomorrowCourseListKey,
          ),
        ],
      ),
    );
  }
}
