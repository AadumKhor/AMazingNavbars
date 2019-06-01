import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class ClipOvalNavbar extends StatefulWidget {
  final List<IconData> icons;
  final List<String> names;
  final List<Color> colors;
  final Color bgColor;
  final Color textColor;
  final Color iconColor;
  final int selectedIndex;

  final Function tapCallback;

  ClipOvalNavbar(
      {Key key,
      this.bgColor,
      this.colors,
      this.iconColor,
      this.icons,
      this.names,
      this.selectedIndex,
      @required this.tapCallback,
      this.textColor})
      : super(key: key);
  @override
  _ClipOvalNavbarState createState() =>
      _ClipOvalNavbarState(selectedIndex: selectedIndex);
}

class _ClipOvalNavbarState extends State<ClipOvalNavbar>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  int newIndex = 0;

  final _circleBottomPosition = 50 + kBottomNavigationBarHeight * 0.4;
  final double kCircleSize = 62.0;

  Animation<double> positionAnim; // when it is positioned
  Animation<double> riseAnim; // when it rises  to place
  Animation<double> sinkAnim; // when it falls to place
  AnimationController controller; // controller as usual

  Size _size; // to determine the size of the circle

  _ClipOvalNavbarState(
      {this.selectedIndex}); // need to access this to update state

  @override
  void initState() {
    controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    positionAnim = new Tween<double>(
            begin: (selectedIndex) * 1.0, end: (selectedIndex + 1) * 1.0)
        .animate(CurvedAnimation(curve: Curves.bounceIn, parent: controller));
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

  // when the icons are in natural state they would be according
  // to this list.
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
      var dist = (index - positionAnim.value).abs();
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
    positionAnim = Tween<double>(begin: selectedIndex * 1.0, end: index * 1.0)
        .animate(CurvedAnimation(
      parent: controller,
      curve: Curves.ease,
    ));
    // colorAnim = new Tween<Color>(
    //         begin: widget.colors[selectedIndex], end: widget.colors[newIndex])
    //     .animate(CurvedAnimation(curve: Curves.bounceIn, parent: controller));

    controller.forward();
  }

  //function to update the widget
  @override
  void didUpdateWidget(ClipOvalNavbar oldWidget) {
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

  String getNameOfIcon() {
    String name;
    if (controller.value < 0.5) {
      name = widget.names[selectedIndex];
    } else {
      name = widget.names[newIndex];
    }
    return name;
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
                controller.isAnimating
                    ? positionAnim.value
                    : selectedIndex * 1.0,
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
              left: (controller.isAnimating
                      ? positionAnim.value
                      : selectedIndex) *
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

class NavbarClipper extends CustomClipper<Path> {
  final numberOfIcons;
  final iconHeight = 52.0;
  final topPaddingFactor = 0.2;

  double animatedIndex;

  NavbarClipper(this.animatedIndex, this.numberOfIcons);

  @override
  Path getClip(Size size) {
    final sectionWidth = size.width / numberOfIcons;
    var path = new Path();
    path.moveTo(0.0, 0.0);
    final curveControlOffset = sectionWidth * 0.45;

    final topPadding = topPaddingFactor * size.height;

    path.lineTo((animatedIndex * sectionWidth) - curveControlOffset, 0);

    final firstControlPoint = Offset((animatedIndex * sectionWidth), 0);

    final secondControlPoint =
        Offset((animatedIndex * sectionWidth), iconHeight);
    final secondEndPoint =
        Offset((animatedIndex * sectionWidth) + curveControlOffset, iconHeight);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(
        ((animatedIndex + 1) * sectionWidth) - curveControlOffset, iconHeight);
    final thirdControlPoint =
        Offset(((animatedIndex + 1) * sectionWidth), iconHeight);

    final fourthControlPoint = Offset(((animatedIndex + 1) * sectionWidth), 0);
    final fourthEndPoint =
        Offset(((animatedIndex + 1) * sectionWidth) + curveControlOffset, 0);

    path.quadraticBezierTo(fourthControlPoint.dx, fourthControlPoint.dy,
        fourthEndPoint.dx, fourthEndPoint.dy);
    path.lineTo(size.width, 0);
    path = path.transform(
        Matrix4.translation(math.Vector3(0, topPadding - 8, 0)).storage);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return (oldClipper as NavbarClipper).animatedIndex != animatedIndex;
  }
}
