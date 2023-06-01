import 'package:flutter/material.dart';

class Toggle extends StatefulWidget {
  const Toggle({
    super.key,
    this.enabledColor = Colors.black12,
    this.disabledColor = Colors.transparent,
    this.borderRadius = 35,
    this.height,
    this.width,
    required this.onToggle,
    required this.toggleValue,
    required this.child,
  });

  final Color enabledColor;
  final Color disabledColor;
  final double borderRadius;
  final Widget child;
  final double? height;
  final double? width;
  final Function() onToggle;
  final bool Function() toggleValue;

  @override
  State<StatefulWidget> createState() => _ToggleState();
}

class _ToggleState extends State<Toggle> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => widget.onToggle(),
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: widget.toggleValue()
                ? widget.enabledColor
                : widget.disabledColor,
            borderRadius: BorderRadius.all(
              Radius.circular(widget.borderRadius),
            ),
            border: Border.all(
              color: widget.enabledColor,
              width: 0.25,
            ),
          ),
          child: Wrap(
            clipBehavior: Clip.hardEdge,
            textDirection: TextDirection.ltr,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            direction: Axis.vertical,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: widget.child,
                ),
              ),
              Center(
                child: Icon(
                  widget.toggleValue() ? Icons.check : Icons.clear,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
