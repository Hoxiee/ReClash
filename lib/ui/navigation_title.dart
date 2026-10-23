import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'typography.dart';

class NavigationTitle extends StatelessWidget {
  const NavigationTitle({
    super.key,
    required this.previous,
    required this.title,
    required this.progress,
    required this.previousStyle,
    required this.style,
    this.onSelect,
  });

  final String previous;
  final String title;
  final double progress;
  final TextStyle previousStyle;
  final TextStyle style;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final before = previous.split(' › ');
    final after = title.split(' › ');
    final t = Curves.easeInOutCubicEmphasized.transform(progress);
    final linkStyle = AppTextStyle.headline
        .of(context)
        .copyWith(color: Theme.of(context).colorScheme.primary);
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    TextStyle segmentStyle(List<String> path, int index, TextStyle terminal) =>
        index == path.length - 1 ? terminal : linkStyle;
    double textWidth(String text, TextStyle textStyle) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    final separatorWidth = textWidth('›', style) + 16;
    List<double> offsets(List<String> path, TextStyle terminal) {
      final result = <double>[];
      var offset = 0.0;
      for (var index = 0; index < path.length; index++) {
        result.add(offset);
        offset += textWidth(path[index], segmentStyle(path, index, terminal));
        if (index < path.length - 1) offset += 24 + separatorWidth;
      }
      return [...result, offset];
    }

    final oldOffsets = offsets(before, previousStyle);
    final newOffsets = offsets(after, style);
    var common = 0;
    while (common < math.min(before.length, after.length) &&
        before[common] == after[common]) {
      common++;
    }
    final children = <Widget>[];
    Widget segment(String text, TextStyle textStyle, int? index) =>
        index == null
        ? Text(text, style: textStyle, maxLines: 1, softWrap: false)
        : TextButton(
            onPressed: progress == 1 && onSelect != null
                ? () => onSelect!(index)
                : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 48),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(text, style: textStyle, maxLines: 1, softWrap: false),
          );
    void addPath(
      List<String> path,
      List<double> positions,
      TextStyle terminal, {
      required bool entering,
    }) {
      final opacity = entering ? t : 1 - t;
      if (opacity == 0) return;
      for (var index = common; index < path.length; index++) {
        final ancestor = index < path.length - 1;
        children.add(
          PositionedDirectional(
            start: positions[index],
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: progress != 1 || !entering,
              child: Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, (entering ? 1 - t : -t) * 4),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: segment(
                      path[index],
                      segmentStyle(path, index, terminal),
                      ancestor ? index : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        if (ancestor) {
          children.add(
            PositionedDirectional(
              start: positions[index + 1] - separatorWidth,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: opacity,
                child: Center(child: Text('›', style: style)),
              ),
            ),
          );
        }
      }
    }

    for (var index = 0; index < common; index++) {
      final oldStyle = segmentStyle(before, index, previousStyle);
      final newStyle = segmentStyle(after, index, style);
      final oldLink = index < before.length - 1;
      final newLink = index < after.length - 1;
      final inset = (oldLink ? 12 : 0) * (1 - t) + (newLink ? 12 : 0) * t;
      final start = oldOffsets[index] * (1 - t) + newOffsets[index] * t;
      children.add(
        PositionedDirectional(
          start: start + inset - (newLink ? 12 : 0),
          top: 0,
          bottom: 0,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: segment(
              before[index],
              TextStyle.lerp(oldStyle, newStyle, t)!,
              newLink ? index : null,
            ),
          ),
        ),
      );
      if (oldLink || newLink) {
        children.add(
          PositionedDirectional(
            start:
                oldOffsets[index + 1] * (1 - t) +
                newOffsets[index + 1] * t -
                separatorWidth,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: (oldLink ? 1 : 0) * (1 - t) + (newLink ? 1 : 0) * t,
              child: Center(child: Text('›', style: style)),
            ),
          ),
        );
      }
    }
    addPath(before, oldOffsets, previousStyle, entering: false);
    addPath(after, newOffsets, style, entering: true);
    return LayoutBuilder(
      builder: (_, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: SizedBox(
          width: math.max(
            constraints.maxWidth,
            oldOffsets.last * (1 - t) + newOffsets.last * t,
          ),
          height: math.max(48, scaler.scale(style.fontSize ?? 24) * 1.5),
          child: Stack(clipBehavior: Clip.hardEdge, children: children),
        ),
      ),
    );
  }
}
