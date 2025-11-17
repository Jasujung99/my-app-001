// lib/widgets/interactive_card.dart

import 'package:flutter/material.dart';

/// A reusable card wrapper that adds a subtle press animation and shadow lift.
class InteractiveCard extends StatefulWidget {
  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.backgroundColor,
    this.borderRadius = 20,
    this.shadowColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double borderRadius;
  final Color? shadowColor;

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final shadowColor = widget.shadowColor ?? Colors.black.withOpacity(0.06);

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: widget.margin,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: widget.onTap == null
              ? null
              : [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: _pressed ? 10 : 16,
                    offset: Offset(0, _pressed ? 4 : 10),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
