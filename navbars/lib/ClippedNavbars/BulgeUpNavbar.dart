import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as math;

class BulgeUpNavbar extends StatefulWidget {
  final List<IconData> icons;
  final Color bgColor;
  final Color textColor;
  final List<String> names;
  final int selectedIndex;

  final Function tapCallback;

  BulgeUpNavbar(
      {Key key,
      this.bgColor,
      this.icons,
      this.names,
      this.selectedIndex,
      @required this.tapCallback,
      this.textColor})
      : super(key: key);

  @override
  _BulgeUpNavbarState createState() =>
      _BulgeUpNavbarState(selectedIndex: selectedIndex);
}

class _BulgeUpNavbarState extends State<BulgeUpNavbar>
    with SingleTickerProviderStateMixin {
  Size _size;

  int selectedIndex = 0;
  int newIndex = 0;
  final _circleBottomPosition = 50 + kBottomNavigationBarHeight * 0.4;
  final double kCircleSize = 62.0;

  Animation<double> posAnim;
  Animation<double> sinkAnim;
  Animation<double> riseAnim;
  AnimationController controller;

  _BulgeUpNavbarState({this.selectedIndex});

  @override
  void initState() {
    controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    posAnim = new Tween<double>(
            begin: selectedIndex * 1.0, end: (selectedIndex + 1) * 1.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.bounceIn));
    sinkAnim = new Tween<double>(begin: 0.0, end: _circleBottomPosition)
        .animate(CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 0.15, curve: Curves.ease)));
    riseAnim = new Tween<double>(begin: _circleBottomPosition, end: 0.0)
        .animate(CurvedAnimation(
            parent: controller, curve: Interval(0.5, 1.0, curve: Curves.ease)));
    controller.addListener(() => setState(() {}));
    controller.addStatusListener((status) {
      if (controller.isCompleted) {
        selectedIndex = newIndex;
        controller.reset();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<Widget> smallIcons() {
    List<Widget> icons = [];
    for (int i = 0; i < widget.icons.length; i++) {
      var a = Expanded(
        child: Container(
          child: InkResponse(
            onTap: () {
              tapped(i, true);
            },
            child: Opacity(
              opacity: getOpacityForIndex(i),
              child: Container(
                height: kBottomNavigationBarHeight * 1.6,
                width: _size.width / 5,
                child: Icon(
                  widget.icons[i],
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
      icons.add(a);
    }
    return icons;
  }

  //method copied from stackoverflow
  double getOpacityForIndex(int index) {
    if (controller.isAnimating) {
      var dist = (index - posAnim.value).abs();
      if (dist >= 1) {
        return 1;
      } else {
        return dist;
      }
    } else {
      return selectedIndex == index ? 0 : 1;
    }
  }

  // to check and update teh interactions
  void tapped(int index, bool userInteraction) {
    if (userInteraction) {
      widget.tapCallback(index);
    }
    newIndex = index;
    posAnim = Tween<double>(begin: selectedIndex * 1.0, end: index * 1.0)
        .animate(CurvedAnimation(
      parent: controller,
      curve: Curves.ease,
    ));
    controller.forward();
  }

  //function to update the widget
  @override
  void didUpdateWidget(BulgeUpNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex == widget.selectedIndex) {
      return;
    }
    tapped(widget.selectedIndex, false);
    // function to check if the button is tapped
  }

  // to ensure it is at the poistion we want
  double getCircleYPosition() {
    if (!controller.isAnimating) {
      return 0;
    }

    if (controller.value < 0.5) {
      return sinkAnim.value;
    } else {
      return riseAnim.value;
    }
  }

  // get the selected icon
  Icon getMainIcon() {
    IconData icon;
    if (controller.value < 0.5) {
      icon = widget.icons[selectedIndex];
    } else {
      icon = widget.icons[newIndex];
    }
    return Icon(
      icon,
      color: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    final sectionWidth = _size.width / widget.icons.length;
    final circleLeftPadding = (sectionWidth - kCircleSize) / 2;
    return Container(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipBehavior: Clip.antiAlias,
            clipper: NavbarClipper(
                controller.isAnimating ? posAnim.value : selectedIndex * 1.0,
                widget.icons.length),
            child: Container(
              height: kBottomNavigationBarHeight * 1.6,
              width: _size.width,
              child: Material(
                color: Colors.white,
                elevation: 4,
                child: Container(
                  margin:
                      EdgeInsets.only(top: kBottomNavigationBarHeight * 0.4),
                  height: kBottomNavigationBarHeight * 1.2,
                  width: _size.width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: smallIcons(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              left: (controller.isAnimating ? posAnim.value : selectedIndex) *
                  (_size.width / widget.icons.length),
              top: getCircleYPosition(),
              child: Container(
                margin: EdgeInsets.only(left: circleLeftPadding),
                child: SizedBox(
                  height: kCircleSize,
                  width: kCircleSize,
                  child: Material(
                    color: Color(0xfff2a10c),
                    elevation: 2.0,
                    type: MaterialType.circle,
                    clipBehavior: Clip.antiAlias,
                    child: getMainIcon(),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class NavbarClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height / 2);
    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
