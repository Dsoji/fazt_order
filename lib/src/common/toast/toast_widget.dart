import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../res/app_assets.dart';
import 'toast.dart';

class ToastWidget extends StatefulWidget {
  final NotificationType type;
  final ToastStyle style;
  final String message;
  final VoidCallback? onCloce;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  const ToastWidget({
    super.key,
    required this.message,
    this.onCloce,
    this.onTap,
    this.onDoubleTap,
    required this.type,
    required this.style,
  });

  @override
  ToastWidgetState createState() => ToastWidgetState();
}

class ToastWidgetState extends State<ToastWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  double _positionX = 0.0;
  bool _isDragging = false;
  late Size _screenSize;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _positionX += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_positionX.abs() > 100) {
      _delete(_positionX);
      //widget.onCloce?.call();
    } else {
      setState(() {
        _isDragging = false;
        _positionX = 0.0;
      });
    }
  }

  String _getToastIcon() {
    switch (widget.style) {
      case ToastStyle.style1:
        return SvgAssets.verify;
      case ToastStyle.style2:
        return SvgAssets.info;
      case ToastStyle.style3:
        return SvgAssets.failure;
    }
  }

  void _onHorizontalDragStart() {
    setState(() {
      _isDragging = true;
    });
  }

  void _delete(double dx) async {
    if (dx > 0) {
      setState(() {
        _positionX -= _screenSize.width * 2;
      });
    } else {
      setState(() {
        _positionX += _screenSize.width * 2;
      });
    }
    await Future.delayed(const Duration(milliseconds: 200));
    widget.onCloce?.call();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _screenSize = MediaQuery.of(context).size;
      },
    );
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, -1), // Start below the screen
      end: const Offset(0, 0), // End of animation at final position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // Smooth animation
    ));

    _controller.forward(); // Run animation when the widget appears
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Transform.translate(
        offset: Offset(_positionX, 0),
        child: GestureDetector(
          onPanUpdate: (details) {},
          onHorizontalDragStart: (details) {
            _onHorizontalDragStart();
          },
          onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details),
          onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details),
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              curve: Curves.easeInOut,
              transform: Matrix4.identity()..translate(_positionX, 0),
              duration: _isDragging
                  ? Duration.zero
                  : const Duration(milliseconds: 400),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: widget.style.decoration(widget.type.color),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onCloce,
                    child: SvgPicture.asset(
                      _getToastIcon(),
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      // overflow: TextOverflow.ellipsis,
                      widget.message,
                      style: TextStyle(
                        color: widget.style == ToastStyle.style1 ||
                                widget.style == ToastStyle.style2
                            ? black
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
