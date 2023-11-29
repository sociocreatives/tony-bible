import 'package:flutter/material.dart';

class BlinkingButton extends StatefulWidget {
  final void Function() onTap;
  BlinkingButton(this.onTap);

  @override
  _BlinkingButtonState createState() => _BlinkingButtonState();
}

class _BlinkingButtonState extends State<BlinkingButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    _animationController =
    new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController?.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController!,
      child: MaterialButton(
        onPressed: widget.onTap,
        child: Text('SLIDESHOW', style: TextStyle(color: Colors.yellow,fontSize: 20),),
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }
}