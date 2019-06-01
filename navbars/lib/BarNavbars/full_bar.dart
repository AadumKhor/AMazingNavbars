import 'package:flutter/material.dart';

class BarNavbar extends StatefulWidget {
  final List<IconData> icons;
  final List<String> names;
  final List<Color> colors;
  final Color bgColor;
  final Color textColor;
  final int selectedIndex;

  final Function tapCallback;

  BarNavbar(
      {Key key,
      this.bgColor = Colors.black,
      this.icons = const [],
      this.colors = const [],
      this.names = const [],
      this.selectedIndex = 0,
      @required this.tapCallback,
      this.textColor = Colors.black});
  @override
  _BarNavbarState createState() => _BarNavbarState(selectedIndex);
}

class _BarNavbarState extends State<BarNavbar>
    with SingleTickerProviderStateMixin {
  Size _size;

  double squeezLength = 80.0; //squeezLength of the bar
  double fullLength = 137.0; // full Length of the bar
  int selectedIndex = 0; // selected currently
  int newIndex = 0; // new one that has to be updated

  Animation<double> posAnim; //animation of the selected bar
  Animation<Color> colorAnim;
  //color change** for the time being double but I think color would be better
  Animation<double> squeezAnim; //squeez to add a good touch
  Animation<double>
      stretchAnim; //coz every action has equal and opposite reaction
  Animation<double> textAnim; //coz I wanna move the text as well

  AnimationController controller; //much needed

  _BarNavbarState(this.selectedIndex);

  @override
  void initState() {
    controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    posAnim = new Tween<double>(
            begin: selectedIndex * 1.0, end: (selectedIndex + 1) * 1.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.bounceIn));
    colorAnim = new Tween<Color>(
            begin: widget.colors[selectedIndex],
            end: widget.colors[(selectedIndex + 1)])
        .animate(CurvedAnimation(parent: controller, curve: Curves.bounceIn));
    squeezAnim = new Tween(begin: fullLength, end: squeezLength)
        .animate(CurvedAnimation(parent: controller, curve: Curves.ease));
    stretchAnim = new Tween(begin: squeezLength, end: fullLength)
        .animate(CurvedAnimation(parent: controller, curve: Curves.ease));
    controller.addListener(() => setState(() {}));
    controller.addStatusListener((status) {
      if (controller.isCompleted) {
        selectedIndex = newIndex;
        controller.reset();
      }
    });
    super.initState();
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
                  color: Colors.grey,
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

  // to check and update the interactions
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
    textAnim = Tween<double>(begin: selectedIndex * 1.0, end: index * 1.0)
        .animate(CurvedAnimation(
      parent: controller,
      curve: Curves.ease,
    ));
    squeezAnim = Tween<double>(begin: fullLength, end: squeezLength)
        .animate(CurvedAnimation(
      parent: controller,
      curve: Curves.ease,
    ));

    // stretchAnim = Tween<double>(begin: squeezLength, end: fullLength)
    //     .animate(CurvedAnimation(
    //   parent: controller,
    //   curve: Curves.ease,
    // ));

    controller.forward();
  }

  //function to update the widget
  @override
  void didUpdateWidget(BarNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex == widget.selectedIndex) {
      return;
    }
    tapped(widget.selectedIndex, false);
    // function to check if the button is tapped
  }

  Color getColor() {
    Color color;
    if (controller.value < 0.5) {
      color = widget.colors[selectedIndex];
    } else {
      color = widget.colors[newIndex];
    }
    return color;
  }

  // get the selected icon
  Icon getMainIcon() {
    IconData icon;
    Color color;
    if (controller.value < 0.5) {
      icon = widget.icons[selectedIndex];
      color = widget.colors[selectedIndex];
    } else {
      icon = widget.icons[newIndex];
      color = widget.colors[newIndex];
    }
    return Icon(
      icon,
      size: 30.0,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    //just to ensure that the bar stays within the limits
    final sectionWidth = _size.width / widget.icons.length;
    return Container(
      color: widget.bgColor,
      child: Stack(
        children: <Widget>[
          Container(
            height: kBottomNavigationBarHeight * 1.2,
            width: double.infinity,
            child: Material(
              color: Colors.black,
              elevation: 4,
              child: Container(
                margin: EdgeInsets.only(top: kBottomNavigationBarHeight * 0.4),
                height: kBottomNavigationBarHeight * 1.2,
                width: _size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: smallIcons(),
                ),
              ),
            ),
          ),
          //the bar that moves
          Positioned(
              left: (controller.isAnimating ? posAnim.value : selectedIndex) *
                  (_size.width / widget.icons.length),
              child: Container(
                margin: EdgeInsets.only(left: sectionWidth / 10),
                child: SizedBox(
                  height: 4.0,
                  width: squeezAnim.isCompleted
                      ? fullLength
                      : (squeezAnim.value) * sectionWidth/3,
                  child: Material(
                    color: getColor(),
                    clipBehavior: Clip.antiAlias,
                  ),
                ),
              )),
          Positioned(
              left: (controller.isAnimating ? textAnim.value : selectedIndex) *
                  (_size.width / widget.icons.length),
              top: _size.height / 30,
              child: Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: sectionWidth / 6),
                child: SizedBox(
                  height: 30.0,
                  width: sectionWidth,
                  child: Material(
                    color: Colors.black,
                    clipBehavior: Clip.antiAlias,
                    // elevation: 2.0,
                    child: getMainIcon(),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
