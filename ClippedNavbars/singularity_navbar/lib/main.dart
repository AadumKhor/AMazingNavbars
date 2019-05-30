import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as math;
 
void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Home()
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin{
 List<Color> colors = [Colors.blue ,Colors.red , Colors.orange , Colors.yellow];

  AnimationController controller;
  int selectedIndex = 0;

  @override
  void initState() {
    controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(color: colors[selectedIndex],),
      bottomNavigationBar: NavBar(
        selectedIndex: selectedIndex,
        bgColor: colors[selectedIndex],
        touchCallback: (int index) {
          controller.reset();
          controller.forward();
          selectedIndex = index;
        },
        names: ['Home' , 'Card' , 'Lock' , 'Profile'],
        icons: [
          Icons.home,
          Icons.shopping_cart,
          Icons.lock_outline,
          Icons.person_add
        ],
      ),
    );
  }
}

class NavBar extends StatefulWidget {
  final List<IconData>
      icons; //icons taht it will contain we can add text as well
  final int selectedIndex; // which icon is selected
  final Color bgColor; //color of the navbar that can be varied by the user
  final List<String> names;

  final Function touchCallback; //callback to check if navbar is clicked

  NavBar(
      {Key key,
      this.icons = const [],
      this.names = const [],
      this.bgColor = Colors.black,
      this.selectedIndex = 0,
      @required this.touchCallback})
      : super(key: key);

  @override
  _NavBarState createState() => _NavBarState(selectedIndex: selectedIndex);
}

class _NavBarState extends State<NavBar> with SingleTickerProviderStateMixin {
  int selectedIndex = 0; // which is selected
  int newIndex = 0; // new one that is to be selected
  final _circleBottomPosition = 50 + kBottomNavigationBarHeight * 0.4;
  final double kCircleSize = 62.0;

  Animation<double> positionAnim; // when it is positioned
  Animation<double> riseAnim; // when it rises  to place
  Animation<double> sinkAnim; // when it falls to place
  AnimationController controller; // controller as usual

  Size _size; // to determine the size of the circle

  _NavBarState({this.selectedIndex}); // need to access this to update state

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
                child: Column(
                  children: <Widget>[
                    Icon(
                      widget.icons[i],
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      getNameOfIcon(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0),
                    )
                  ],
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
      widget.touchCallback(index);
    }
    newIndex = index;
    positionAnim = Tween<double>(begin: selectedIndex * 1.0, end: index * 1.0)
        .animate(CurvedAnimation(
      parent: controller,
      curve: Curves.ease,
    ));

    controller.forward();
  }

  //function to update the widget
  @override
  void didUpdateWidget(NavBar oldWidget) {
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
      color: widget.bgColor,
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipBehavior: Clip.antiAlias,
            clipper: NavBarClipper(
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

class NavBarClipper extends CustomClipper<Path> {
  final numberOfIcons; // number of icons in the navbar
  final iconHeight = 52.0; // height of icons
  final topPaddingFactor = 0.2; //space to be left from the main page

  final double animatedIndex; // index of animation

  NavBarClipper(this.animatedIndex, this.numberOfIcons);

  @override
  Path getClip(Size size) {
    final sectionWidth = size.width / numberOfIcons;
    var path = new Path();
    path.moveTo(0.0, 0.0);

    // Draw notch

    final curveControlOffset = sectionWidth * 0.45;

    final topPadding = topPaddingFactor * size.height;

    path.lineTo((animatedIndex * sectionWidth) - curveControlOffset, 0);

    final firstControlPoint = Offset((animatedIndex * sectionWidth), 0);

    final secondControlPoint =
        Offset((animatedIndex * sectionWidth), iconHeight);
    final secondEndPoint =
        Offset((animatedIndex * sectionWidth) + curveControlOffset, iconHeight);

    path.cubicTo(
        firstControlPoint.dx,
        firstControlPoint.dy,
        secondControlPoint.dx,
        secondControlPoint.dy,
        secondEndPoint.dx,
        secondEndPoint.dy);

    path.lineTo(
        ((animatedIndex + 1) * sectionWidth) - curveControlOffset, iconHeight);
    final thirdControlPoint =
        Offset(((animatedIndex + 1) * sectionWidth), iconHeight);

    final fourthControlPoint = Offset(((animatedIndex + 1) * sectionWidth), 0);
    final fourthEndPoint =
        Offset(((animatedIndex + 1) * sectionWidth) + curveControlOffset, 0);

    path.cubicTo(
        thirdControlPoint.dx,
        thirdControlPoint.dy,
        fourthControlPoint.dx,
        fourthControlPoint.dy,
        fourthEndPoint.dx,
        fourthEndPoint.dy);
    path.lineTo(size.width, 0);

    path = path
        .transform(Matrix4.translation(math.Vector3(0, topPadding, 0)).storage);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return (oldClipper as NavBarClipper).animatedIndex != animatedIndex;
  }
}
