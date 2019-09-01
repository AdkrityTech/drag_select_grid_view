import 'package:drag_select_grid_view/src/auto_scroller/auto_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';

import 'test_utils.dart';

void main() {
  final dragSelectFinder = find.byType(DragSelectGridView);

  Widget widget;
  DragSelectGridViewState dragSelectState;

  Widget createWidget() {
    return MaterialApp(
      home: DragSelectGridView(
        grid: GridView.extent(
          maxCrossAxisExtent: 1,
          children: [],
          controller: ScrollController(),
        ),
      ),
    );
  }

  /// Notice that this is not a call to the the native [setUp] function.
  /// I could not use it because I need [WidgetTester] as a parameter to avoid
  /// creating the widget at every single [testWidgets].
  /// I get access to [WidgetTester], but in counterpart I have to call [setUp]
  /// manually at the initialization of every [testWidgets].
  Future<void> setUp(WidgetTester tester) async {
    widget = createWidget();
    await tester.pumpWidget(widget);
    dragSelectState = tester.state(dragSelectFinder);
  }

  testWidgets(
    'An AssertionError is throw '
    'when creating a DragSelectGridView with null `grid`.',
    (WidgetTester tester) async {
      expect(
        () => DragSelectGridView(grid: null),
        throwsAssertionError,
      );
    },
  );

  testWidgets(
    'An AssertionError is throw '
    'when creating a DragSelectGridView with a `grid` which delegate is not a '
    'SliverGridDelegateWithMaxCrossAxisExtent.',
    (WidgetTester tester) async {
      expect(
        () => MaterialApp(
          home: DragSelectGridView(
            grid: GridView.count(crossAxisCount: 3),
          ),
        ),
        throwsAssertionError,
      );
    },
  );

  testWidgets(
    '`isInDragSelectMode` is correctly changed '
    'when DragSelectGridView is long-pressed.',
    (WidgetTester tester) async {
      await setUp(tester);

      // Initially, isInDragSelectMode is false.
      expect(dragSelectState.isInDragSelectMode, isFalse);

      // On long-press down, isInDragSelectMode is true.
      final gesture = await longPressDown(
        tester: tester,
        finder: dragSelectFinder,
      );
      await tester.pump();
      expect(dragSelectState.isInDragSelectMode, isTrue);

      // On long-press up, isInDragSelectMode is false.
      await gesture.up();
      await tester.pump();
      expect(dragSelectState.isInDragSelectMode, isFalse);
    },
  );

  testWidgets(
    'Auto-scroll is enabled when dragging to upper-hotspot.',
    (WidgetTester tester) async {
      await setUp(tester);

      // Initially, autoScroll is stopped.
      expect(dragSelectState.autoScroll, AutoScroll.stopped());

      // Auto-scroll is enabled when dragging to upper hotspot.
      await longPressDownAndDrag(
        tester: tester,
        finder: dragSelectFinder,
        offset: Offset(0, -(dragSelectState.height / 2) + 1),
      );
      await tester.pump();
      expect(dragSelectState.autoScroll.direction, AutoScrollDirection.up);
    },
  );

  testWidgets(
    'Auto-scroll is enabled when dragging to lower-hotspot.',
    (WidgetTester tester) async {
      await setUp(tester);

      await longPressDownAndDrag(
        tester: tester,
        finder: dragSelectFinder,
        offset: Offset(0, (dragSelectState.height / 2)),
      );
      await tester.pump();
      expect(dragSelectState.autoScroll.direction, AutoScrollDirection.down);
    },
  );

  testWidgets(
    'Auto-scroll is disabled with correct direction '
    'when pointer goes up from upper-hotspot.',
    (WidgetTester tester) async {
      await setUp(tester);

      final gesture = await longPressDownAndDrag(
        tester: tester,
        finder: dragSelectFinder,
        offset: Offset(0, -(dragSelectState.height / 2) + 1),
      );
      await tester.pump();
      expect(dragSelectState.autoScroll.direction, AutoScrollDirection.up);

      // Auto-scroll is disabled when pointer goes up.
      await gesture.up();
      await tester.pump();
      expect(
        dragSelectState.autoScroll,
        AutoScroll.stopped(direction: AutoScrollDirection.up),
      );
    },
  );

  testWidgets(
    'Auto-scroll is disabled with correct direction '
    'when pointer goes up from lower-hotspot.',
    (WidgetTester tester) async {
      await setUp(tester);

      final gesture = await longPressDownAndDrag(
        tester: tester,
        finder: dragSelectFinder,
        offset: Offset(0, dragSelectState.height / 2),
      );
      await tester.pump();
      expect(dragSelectState.autoScroll.direction, AutoScrollDirection.down);

      // Auto-scroll is disabled when pointer goes up.
      await gesture.up();
      await tester.pump();
      expect(
        dragSelectState.autoScroll,
        AutoScroll.stopped(direction: AutoScrollDirection.down),
      );
    },
  );

  testWidgets(
    'Auto-scroll is disabled when dragging out of the hotspot.',
    (WidgetTester tester) async {
      await setUp(tester);

      final gesture = await longPressDownAndDrag(
        tester: tester,
        finder: dragSelectFinder,
        offset: Offset(0, dragSelectState.height / 2),
      );
      await tester.pump();
      expect(dragSelectState.autoScroll.direction, AutoScrollDirection.down);

      // Auto-scroll is disabled when dragging out of the hotspot.
      await gesture.moveTo(tester.getCenter(dragSelectFinder));
      await tester.pump();
      expect(
        dragSelectState.autoScroll,
        AutoScroll.stopped(direction: AutoScrollDirection.down),
      );
    },
  );
}
