import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/external_link.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:reclash/models/profile.dart';

class _Window extends Mock implements WindowPort {}

class _CommonAction extends CommonAction {
  final requests = <bool>[];

  @override
  Future<void> setRunning(bool running) async => requests.add(running);
}

class _SystemAction extends SystemAction {
  int closes = 0;

  @override
  Future<void> handleClose([bool exit = true]) async => closes++;
}

class _ProfilesAction extends ProfilesAction {
  final sources = <ProfileLinkSource>[];

  int reveals = 0;

  @override
  Future<Profile> addConfirmedLinkSource(
    ProfileLinkSource source, {
    String? label,
    SubscriptionClientSettings? clientSettings,
    BuildContext? reviewContext,
    SubscriptionCancellation? cancellation,
  }) async {
    sources.add(source);
    return Profile.normal(label: label);
  }

  @override
  void showProfiles() => reveals++;
}

class _Session extends SetupSession {
  @override
  SetupSessionState build() => const SetupSessionState(
    active: false,
    step: SetupStep.profile,
    draft: SetupDraft(coverage: SetupCoverage.tun),
  );

  void setActive(bool active) => state = state.copyWith(active: active);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late _CommonAction common;
  late _SystemAction systemAction;
  late _Window window;
  late _Session session;
  late _ProfilesAction profiles;

  void accept([int version = disclaimerVersion]) => container
      .read(appSettingProvider.notifier)
      .update((value) => value.copyWith(acceptedDisclaimerVersion: version));

  setUp(() async {
    await AppLocalizations.load(const Locale('en'));
    common = _CommonAction();
    systemAction = _SystemAction();
    session = _Session();
    profiles = _ProfilesAction();
    window = _Window();
    when(window.show).thenAnswer((_) async {});
    final previous = windowPort;
    windowPort = window;
    addTearDown(() => windowPort = previous);
    container = ProviderContainer(
      overrides: [
        commonActionProvider.overrideWith(() => common),
        systemActionProvider.overrideWith(() => systemAction),
        profilesActionProvider.overrideWith(() => profiles),
        setupSessionProvider.overrideWith(() => session),
      ],
    );
    addTearDown(container.dispose);
    container.read(setupSessionProvider);
    container.listen(appSettingProvider, (_, _) {});
    accept();
  });

  Future<void> execute(
    ReClashCommand command, {
    Future<bool> Function(ReClashCommand)? confirm,
  }) => container
      .read(urlSchemeActionProvider.notifier)
      .execute(command, confirm: confirm ?? (_) async => true);

  test(
    'open reveals the window without confirmation or a network request',
    () async {
      var confirmations = 0;
      session.setActive(true);
      await execute(
        ReClashCommand.open,
        confirm: (_) async {
          confirmations++;
          return true;
        },
      );
      verify(window.show).called(1);
      expect(confirmations, 0);
      expect(common.requests, isEmpty);
    },
  );

  test('no command but open runs before setup or consent', () async {
    for (final command in [
      ReClashCommand.connect,
      ReClashCommand.disconnect,
      ReClashCommand.toggle,
      ReClashCommand.close,
    ]) {
      session.setActive(true);
      await expectLater(execute(command), throwsA(isA<MessageException>()));
      session.setActive(false);
      accept(0);
      await expectLater(execute(command), throwsA(isA<MessageException>()));
      accept();
    }
    expect(common.requests, isEmpty);
    expect(systemAction.closes, 0);
  });

  test('close runs once setup is done and consent exists', () async {
    await execute(ReClashCommand.close);
    expect(systemAction.closes, 1);
  });

  test('profile commands are not dispatched as application actions', () async {
    await execute(ReClashCommand.add);
    await execute(ReClashCommand.importProfile);
    await execute(ReClashCommand.installConfig);
    verifyNever(window.show);
    expect(common.requests, isEmpty);
  });

  test(
    'connect and disconnect delegate explicit intents after confirmation',
    () async {
      final confirmed = <ReClashCommand>[];
      for (final command in [
        ReClashCommand.connect,
        ReClashCommand.disconnect,
      ]) {
        await execute(
          command,
          confirm: (action) async {
            confirmed.add(action);
            return true;
          },
        );
      }
      expect(confirmed, [ReClashCommand.connect, ReClashCommand.disconnect]);
      expect(common.requests, [true, false]);
    },
  );

  test(
    'disconnect still requests stop while runtime is already stopped',
    () async {
      await execute(ReClashCommand.disconnect);
      expect(common.requests, [false]);
    },
  );

  test(
    'a declined action changes neither connection nor application state',
    () async {
      await execute(ReClashCommand.connect, confirm: (_) async => false);
      await execute(ReClashCommand.close, confirm: (_) async => false);
      expect(common.requests, isEmpty);
      expect(systemAction.closes, 0);
    },
  );

  test('toggle confirmation names the actual resolved action', () async {
    final confirmed = <ReClashCommand>[];
    for (final running in [false, true]) {
      container.read(runTimeProvider.notifier).value = running ? 0 : null;
      await execute(
        ReClashCommand.toggle,
        confirm: (action) async {
          confirmed.add(action);
          return true;
        },
      );
    }
    expect(confirmed, [ReClashCommand.connect, ReClashCommand.disconnect]);
    expect(common.requests, [true, false]);
  });

  test(
    'toggle applies only the action actually confirmed if runtime changes',
    () async {
      await execute(
        ReClashCommand.toggle,
        confirm: (action) async {
          expect(action, ReClashCommand.connect);
          container.read(runTimeProvider.notifier).value = 0;
          return true;
        },
      );
      expect(common.requests, [true]);
    },
  );

  test(
    'active setup blocks all external connection actions before confirmation',
    () async {
      session.setActive(true);
      var confirmations = 0;
      for (final command in [
        ReClashCommand.connect,
        ReClashCommand.disconnect,
        ReClashCommand.toggle,
      ]) {
        await expectLater(
          execute(
            command,
            confirm: (_) async {
              confirmations++;
              return true;
            },
          ),
          throwsA(isA<MessageException>()),
        );
      }
      expect(confirmations, 0);
      expect(common.requests, isEmpty);
    },
  );

  test('setup is checked again after awaiting confirmation', () async {
    await expectLater(
      execute(
        ReClashCommand.connect,
        confirm: (_) async {
          session.setActive(true);
          return true;
        },
      ),
      throwsA(isA<MessageException>()),
    );
    expect(common.requests, isEmpty);
  });

  test(
    'a failed confirmation cannot dispatch and does not block a later action',
    () async {
      await expectLater(
        execute(
          ReClashCommand.connect,
          confirm: (_) async {
            throw StateError('dialog failed');
          },
        ),
        throwsStateError,
      );
      expect(common.requests, isEmpty);
      await execute(ReClashCommand.disconnect);
      expect(common.requests, [false]);
    },
  );

  test('disposal during confirmation prevents late dispatch', () async {
    final entered = Completer<void>();
    final gate = Completer<bool>();
    final pending = execute(
      ReClashCommand.connect,
      confirm: (_) {
        entered.complete();
        return gate.future;
      },
    );
    await entered.future;
    container.dispose();
    gate.complete(true);
    await pending;
    expect(common.requests, isEmpty);
  });

  group('handleLink', () {
    Future<void> handle(
      String input, {
      Future<bool> Function(ReClashCommand)? confirmCommand,
      Future<ProfileLinkImport?> Function(ProfileLinkSource)? confirmImport,
      Future<void> Function(String, String)? openRouting,
      Future<void> Function(String?)? openDoctor,
      Future<void> Function(String)? openFix,
      bool Function()? isCurrent,
    }) => container
        .read(urlSchemeActionProvider.notifier)
        .handleLink(
          input,
          confirmCommand: confirmCommand ?? (_) async => true,
          confirmImport: (source, commit) async {
            final choice =
                await (confirmImport ?? (_) async => const ProfileLinkImport())(
                  source,
                );
            if (choice != null) await commit(choice);
            return choice;
          },
          openRouting: openRouting ?? (_, _) async {},
          openDoctor: openDoctor,
          openFix: openFix,
          isCurrent: isCurrent,
        );

    test('routing links open the review with the decoded text', () async {
      const yaml = 'rcx: 1\nprofiles: {}\n';
      final opened = <(String, String)>[];
      var imports = 0;
      await handle(
        encodeRcxLink(yaml),
        confirmImport: (_) async {
          imports++;
          return const ProfileLinkImport();
        },
        openRouting: (text, origin) async => opened.add((text, origin)),
      );
      expect(opened, [(yaml, 'link')]);
      expect(imports, 0);
      expect(common.requests, isEmpty);
    });

    test('routing links with a bad payload surface a link error', () async {
      var opened = 0;
      await expectLater(
        handle(
          'reclash://routing?p=%2A%2A',
          openRouting: (_, _) async => opened++,
        ),
        throwsA(
          isA<UrlSchemeException>().having(
            (e) => e.issue,
            'issue',
            UrlSchemeIssue.invalidBase64,
          ),
        ),
      );
      expect(opened, 0);
    });

    test('commands never dispatch to the profile importer', () async {
      final confirmed = <ReClashCommand>[];
      var imports = 0;
      await handle(
        'reclash://disconnect',
        confirmCommand: (action) async {
          confirmed.add(action);
          return true;
        },
        confirmImport: (_) async {
          imports++;
          return const ProfileLinkImport();
        },
      );
      expect(confirmed, [ReClashCommand.disconnect]);
      expect(common.requests, [false]);
      expect(imports, 0);
      expect(profiles.sources, isEmpty);
    });

    test('open is harmless during setup without confirmation', () async {
      session.setActive(true);
      var confirmations = 0;
      await handle(
        'reclash://open',
        confirmCommand: (_) async {
          confirmations++;
          return true;
        },
      );
      expect(confirmations, 0);
      verify(window.show).called(1);
      expect(container.read(setupSessionProvider).pendingLink, isNull);
      expect(common.requests, isEmpty);
    });

    test(
      'confirmed wrappers retain their name, preset and original source',
      () async {
        const url = 'https://example.com/private?token=secret';
        ProfileLinkSource? confirmed;
        await handle(
          'happ://add/${Uri.encodeComponent(url)}?name=Home',
          confirmImport: (source) async {
            expect(profiles.sources, isEmpty);
            confirmed = source;
            return const ProfileLinkImport();
          },
        );
        expect(profiles.sources.single, same(confirmed));
        expect(profiles.reveals, 1);
        expect(confirmed!.url, url);
        expect(confirmed!.name, 'Home');
        expect(confirmed!.preset, SubscriptionClientPreset.happ);
        expect(confirmed!.displaySource, 'https://example.com');
        expect(common.requests, isEmpty);
      },
    );

    test(
      'embedded imports pass decoded bytes only after confirmation',
      () async {
        const content = 'proxies: []\nrules: [MATCH,DIRECT]';
        final link = await buildUrlSchemeLink(
          ReClashCommand.importProfile,
          payload: content,
          name: 'Home',
        );
        await handle(link);
        expect(utf8.decode(profiles.sources.single.bytes!), content);
        expect(profiles.sources.single.name, 'Home');
      },
    );

    test('declining import leaves profiles and connection untouched', () async {
      await handle('https://example.com/sub', confirmImport: (_) async => null);
      expect(profiles.sources, isEmpty);
      expect(common.requests, isEmpty);
    });

    test(
      'setup receives the original link without resolving or importing',
      () async {
        session.setActive(true);
        const input = 'incy://crypt1/not-valid-ciphertext';
        var confirmations = 0;
        await handle(
          input,
          confirmImport: (_) async {
            confirmations++;
            return const ProfileLinkImport();
          },
        );
        expect(container.read(setupSessionProvider).pendingLink, input);
        expect(confirmations, 0);
        expect(profiles.sources, isEmpty);
        verify(window.show).called(1);
      },
    );

    test(
      'setup activated during confirmation receives the link, not a profile',
      () async {
        const input = 'https://example.com/sub';
        await handle(
          input,
          confirmImport: (_) async {
            session.setActive(true);
            return const ProfileLinkImport();
          },
        );
        expect(container.read(setupSessionProvider).pendingLink, input);
        expect(profiles.sources, isEmpty);
        expect(profiles.reveals, 0);
      },
    );

    test('a link before consent is held, not acted on', () async {
      accept(0);
      var confirmations = 0;
      await handle(
        'https://example.com/sub',
        confirmImport: (_) async {
          confirmations++;
          return const ProfileLinkImport();
        },
      );
      expect(
        container.read(setupSessionProvider).pendingLink,
        'https://example.com/sub',
      );
      expect(confirmations, 0);
      expect(profiles.sources, isEmpty);
    });

    test('fix links open the confirmation sheet and nothing else', () async {
      const link = 'reclash://fix?p=e30&s=AA';
      final opened = <String>[];
      await handle(
        link,
        confirmCommand: (_) async => fail('no command runs'),
        confirmImport: (_) async => fail('nothing is imported'),
        openFix: (input) async => opened.add(input),
      );
      expect(opened, [link]);
      expect(common.requests, isEmpty);
      expect(profiles.sources, isEmpty);
    });

    test('doctor and routing links are held during setup', () async {
      session.setActive(true);
      var opened = 0;
      for (final input in ['reclash://doctor', encodeRcxLink('rcx: 1\n')]) {
        await handle(
          input,
          openDoctor: (_) async => opened++,
          openRouting: (_, _) async => opened++,
        );
        expect(container.read(setupSessionProvider).pendingLink, input);
      }
      expect(opened, 0);
    });

    test('the latest held link wins and dropped commands leave it', () async {
      session.setActive(true);
      await handle('https://example.com/one');
      await handle('https://example.com/two');
      await expectLater(
        handle('reclash://connect'),
        throwsA(isA<MessageException>()),
      );
      expect(
        container.read(setupSessionProvider).pendingLink,
        'https://example.com/two',
      );
    });

    test('a held link is handed over only after setup and consent', () async {
      session.setActive(true);
      await handle('https://example.com/sub');
      final notifier = container.read(setupSessionProvider.notifier);
      expect(notifier.takeHeldLink(), isNull);
      session.setActive(false);
      accept(0);
      expect(notifier.takeHeldLink(), isNull);
      accept();
      expect(notifier.takeHeldLink(), 'https://example.com/sub');
      expect(container.read(setupSessionProvider).pendingLink, isNull);
      expect(notifier.takeHeldLink(), isNull);
    });

    test('a link is handled normally once setup is done', () async {
      var confirmations = 0;
      await handle(
        'https://example.com/sub',
        confirmImport: (_) async {
          confirmations++;
          return const ProfileLinkImport();
        },
      );
      expect(confirmations, 1);
      expect(profiles.sources, hasLength(1));
      expect(container.read(setupSessionProvider).pendingLink, isNull);
    });

    test('malformed links fail before confirmation or import', () async {
      var confirmations = 0;
      for (final input in [
        'reclash://connect?trusted=true',
        'incy://crypt2/AAAA',
      ]) {
        await expectLater(
          handle(
            input,
            confirmCommand: (_) async {
              confirmations++;
              return true;
            },
            confirmImport: (_) async {
              confirmations++;
              return const ProfileLinkImport();
            },
          ),
          throwsA(isA<UrlSchemeException>()),
        );
      }
      expect(confirmations, 0);
      expect(profiles.sources, isEmpty);
      expect(common.requests, isEmpty);
    });

    test(
      'an invalidated application cannot import after confirmation',
      () async {
        var current = true;
        await handle(
          'https://example.com/sub',
          isCurrent: () => current,
          confirmImport: (_) async {
            current = false;
            return const ProfileLinkImport();
          },
        );
        expect(profiles.sources, isEmpty);
      },
    );

    test('disposal prevents importing after confirmation', () async {
      final entered = Completer<void>();
      final gate = Completer<ProfileLinkImport?>();
      final pending = handle(
        'https://example.com/sub',
        confirmImport: (_) {
          entered.complete();
          return gate.future;
        },
      );
      await entered.future;
      container.dispose();
      gate.complete(const ProfileLinkImport());
      await pending;
      expect(profiles.sources, isEmpty);
    });

    test(
      'an invalidated application does not reveal or confirm commands',
      () async {
        await handle('reclash://connect', isCurrent: () => false);
        verifyNever(window.show);
        expect(common.requests, isEmpty);
      },
    );
  });
}
