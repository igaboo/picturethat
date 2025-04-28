import 'package:flutter/material.dart';
import 'package:picturethat/utils/preference_utils.dart';

class CustomTooltip extends StatefulWidget {
  final String tooltipId;
  final String title;
  final String message;

  const CustomTooltip({
    required this.tooltipId,
    required this.title,
    required this.message,
    super.key,
  });

  @override
  State<CustomTooltip> createState() => _CustomTooltipState();
}

class _CustomTooltipState extends State<CustomTooltip> {
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    _checkTooltipVisibility();
  }

  void _checkTooltipVisibility() async {
    final bool isTooltipVisible = await getBool(widget.tooltipId);
    if (!isTooltipVisible) setState(() => isVisible = true);
  }

  void _hideTooltip() {
    setState(() => isVisible = false);
    setBool(widget.tooltipId, true);
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: isVisible,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(widget.message),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextButton(
                      onPressed: _hideTooltip,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(5.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text("Got it"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
