import 'package:flutter/material.dart';

class VisualComponent extends StatefulWidget {
  final int duration;
  final Color color;
  final double width;

  const VisualComponent({super.key, required this.color, required this.duration,required this.width});
  @override
  _VisualComponentState createState() => _VisualComponentState();
}

class _VisualComponentState extends State<VisualComponent> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animController;

  @override
  void initState() {
    super.initState();
    
    animController = AnimationController(
      vsync: this, 
      duration: Duration(milliseconds: widget.duration),
    );
    
    final curvedAnimation = CurvedAnimation(
      parent: animController, 
      curve: Curves.slowMiddle
      //curve: Curves.slowMiddle,
    );
    
    animation = Tween<double>(begin: 0, end: 80).animate(curvedAnimation)
      ..addListener(() {
        setState(() {});
      });
    
    animController.repeat(reverse: true);
  }

  @override
  void dispose() {
    animController.dispose(); // Ensure to dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width, // Animating the width
      height: animation.value,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
