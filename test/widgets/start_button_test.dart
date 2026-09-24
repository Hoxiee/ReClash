import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/start_button.dart';
import 'package:reclash/widgets/nav/app_nav_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('RunTimeText emphasizes the day prefix', (tester) async {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF6750A4),
      onPrimaryContainer: Color(0xFF21005D),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: colorScheme),
        home: const RunTimeText(timeStamp: 24 * 60 * 60 * 1000),
      ),
    );

    final text = tester.widget<Text>(
      find.descendant(
        of: find.byType(RunTimeText),
        matching: find.byType(Text),
      ),
    );
    final span = text.textSpan! as TextSpan;

    expect(span.toPlainText(), '1d 00:00:00');
    expect(span.text, '1d');
    expect(span.style?.color, colorScheme.primary);
    expect(span.style?.fontWeight, FontWeight.w600);
    expect(span.children, hasLength(1));
    expect((span.children!.single as TextSpan).text, ' 00:00:00');
    expect(
      (span.children!.single as TextSpan).style?.color,
      colorScheme.onPrimaryContainer,
    );
  });

  testWidgets('RunTimeText uses one color below one day', (tester) async {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF6750A4),
      onPrimaryContainer: Color(0xFF21005D),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: colorScheme),
        home: const RunTimeText(timeStamp: 23 * 60 * 60 * 1000),
      ),
    );

    final text = tester.widget<Text>(
      find.descendant(
        of: find.byType(RunTimeText),
        matching: find.byType(Text),
      ),
    );

    expect(text.data, '23:00:00');
    expect(text.style?.color, colorScheme.onPrimaryContainer);
  });

  testWidgets('StartButton animates its width when uptime reaches a day', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWithValue([
          const Profile(id: 1, autoUpdateDuration: Duration.zero),
        ]),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(runTimeProvider.notifier).value = 23 * 60 * 60 * 1000;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          homeBuilder: (child) => Scaffold(floatingActionButton: child),
          child: const StartButton(),
        ),
      ),
    );
    await tester.pump();

    final button = find.byType(FloatingActionButton);
    expect(tester.getSize(button).height, 56);
    final hoursWidth = tester.getSize(button).width;

    container.read(runTimeProvider.notifier).value = 24 * 60 * 60 * 1000;
    await tester.pump();
    expect(tester.getSize(button).width, hoursWidth);

    await tester.pump(const Duration(milliseconds: 100));
    final animatedWidth = tester.getSize(button).width;
    expect(animatedWidth, greaterThan(hoursWidth));

    await tester.pumpAndSettle();
    expect(tester.getSize(button).width, greaterThan(animatedWidth));
  });

  testWidgets('StartButton resets its text after the close animation', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWithValue([
          const Profile(id: 1, autoUpdateDuration: Duration.zero),
        ]),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(runTimeProvider.notifier).value = const Duration(
      hours: 100,
      minutes: 2,
      seconds: 3,
    ).inMilliseconds;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          homeBuilder: (child) => Scaffold(floatingActionButton: child),
          child: const StartButton(),
        ),
      ),
    );
    await tester.pump();

    final button = find.byType(FloatingActionButton);
    String runTimeText() {
      final text = tester.widget<Text>(
        find.descendant(
          of: find.byType(RunTimeText),
          matching: find.byType(Text),
        ),
      );
      return text.data ?? text.textSpan!.toPlainText();
    }

    final expandedTextWidth = tester
        .widget<AnimatedContainer>(find.byType(AnimatedContainer))
        .constraints
        ?.maxWidth;
    expect(runTimeText(), '4d 04:02:03');

    container.read(runTimeProvider.notifier).value = null;
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // The panel is mid-close: wider than the collapsed pill, with the text
    // held until the close finishes.
    expect(tester.getSize(button).width, greaterThan(56));
    expect(
      tester
          .widget<AnimatedContainer>(find.byType(AnimatedContainer))
          .constraints
          ?.maxWidth,
      expandedTextWidth,
    );
    expect(runTimeText(), '4d 04:02:03');

    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getSize(button).width, 56);
    expect(runTimeText(), '4d 04:02:03');

    await tester.pumpAndSettle();

    expect(tester.getSize(button).width, 56);
    expect(runTimeText(), '00:00:00');
  });

  testWidgets('reduced motion swaps the pause slot without a ticker', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWithValue([
          const Profile(id: 1, autoUpdateDuration: Duration.zero),
        ]),
        initProvider.overrideWithBuild((_, _) => true),
        tunEnabledProvider.overrideWith((_) => true),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(runTimeProvider.notifier).value = 1;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: TestApp(
            includeNavigatorKey: false,
            setTheme: false,
            homeBuilder: (child) => Scaffold(floatingActionButton: child),
            child: const StartButton(),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);

    container.read(runTimeProvider.notifier).value = null;
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byIcon(Icons.pause_rounded), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('dispatches each toggle through the shared running state', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        initProvider.overrideWithBuild((_, _) => true),
        profilesProvider.overrideWithValue([
          const Profile(id: 1, autoUpdateDuration: Duration.zero),
        ]),
        setupActionProvider.overrideWith(_RecordingSetupAction.new),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(runTimeProvider.notifier).value = 1;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          homeBuilder: (child) => Scaffold(floatingActionButton: child),
          child: const StartButton(),
        ),
      ),
    );

    final action =
        container.read(setupActionProvider.notifier) as _RecordingSetupAction;
    final button = find.byType(FloatingActionButton);

    await tester.tap(button);
    expect(action.requests, [false]);
    expect(container.read(isStartProvider), isFalse);

    await tester.tap(button);
    expect(action.requests, [false, true]);
    expect(container.read(isStartProvider), isTrue);
  });
  testWidgets('pause stays reachable while paused and stop stays on the fab', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWithValue([
          const Profile(id: 1, autoUpdateDuration: Duration.zero),
        ]),
        initProvider.overrideWithBuild((_, _) => true),
        tunEnabledProvider.overrideWith((_) => true),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(runTimeProvider.notifier).value = 1;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          homeBuilder: (child) => Scaffold(floatingActionButton: child),
          child: const StartButton(),
        ),
      ),
    );
    await tester.pump();

    String mainTooltip() => tester
        .widget<FloatingActionButton>(find.byType(FloatingActionButton).last)
        .tooltip!;

    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(mainTooltip(), 'Stop');

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(container.read(pausedProvider), isTrue);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);
    expect(mainTooltip(), 'Stop');

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(container.read(pausedProvider), isFalse);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('StartButton collapses to a round glyph fab in the dock', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWithValue([
          const Profile(id: 1, autoUpdateDuration: Duration.zero),
        ]),
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                icon: const Icon(Icons.space_dashboard),
                label: PageLabel.dashboard,
                builder: (_) => const SizedBox.shrink(),
              ),
              NavigationItem(
                icon: const Icon(Icons.folder),
                label: PageLabel.profiles,
                builder: (_) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          includeNavigatorKey: false,
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: AppNavBar(trailing: StartButton()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GlyphIcon), findsOneWidget);
    expect(find.byType(BreathingRing), findsOneWidget);
    expect(find.byType(RunTimeText), findsNothing);
  });
}

class _RecordingSetupAction extends SetupAction {
  final requests = <bool>[];

  @override
  Future<bool> setRunning(bool running, {bool initialize = false}) {
    requests.add(running);
    ref.read(runTimeProvider.notifier).value = running ? 1 : null;
    return Future.value(true);
  }
}
