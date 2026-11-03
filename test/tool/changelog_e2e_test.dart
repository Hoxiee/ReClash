import 'dart:convert';
import 'dart:io';

import 'package:reclash/common/update_summary.dart';
import 'package:test/test.dart';

import '../../tool/src/changelog/digest.dart';
import '../../tool/src/changelog/git.dart';
import '../../tool/src/changelog/models.dart';
import '../../tool/src/changelog/notes.dart';

const validNotes = '### New\n\n- A shipped feature.\n';

void main() {
  late Directory repo;

  String git(List<String> arguments) {
    final result = Process.runSync(
      'git',
      arguments,
      workingDirectory: repo.path,
      environment: const {
        'GIT_AUTHOR_DATE': '2026-01-02T00:00:00Z',
        'GIT_COMMITTER_DATE': '2026-01-02T00:00:00Z',
      },
    );
    if (result.exitCode != 0) {
      fail('git ${arguments.join(' ')} failed: ${result.stderr}');
    }
    return result.stdout as String;
  }

  void commit(String message) {
    git(['commit', '--allow-empty', '--quiet', '--message', message]);
  }

  void write(String path, String content) {
    final file = File('${repo.path}/$path');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
  }

  void writeSummary(String tag) {
    write(
      'release_summaries/$tag.json',
      jsonEncode(
        ReleaseSummary(
          tag: tag,
          locales: const {
            'en': ReleaseSummaryLocale(
              headline: 'Summary headline',
              spotlight: ReleaseHighlight(
                title: 'Spotlight',
                description: 'Spotlight text.',
              ),
            ),
          },
        ).toJson(),
      ),
    );
  }

  ReleaseDigest digest(String tag) => buildDigest(
    Git(workingDirectory: repo.path),
    repo.path,
    VersionTag.tryParse(tag)!,
  );

  ProcessResult changelog(List<String> arguments) => Process.runSync('dart', [
    'run',
    'tool/changelog.dart',
    '--root',
    repo.path,
    ...arguments,
  ]);

  setUp(() {
    repo = Directory.systemTemp.createTempSync('reclash-changelog-');
    git(['init', '--quiet', '--initial-branch=main']);
    git(['config', 'user.email', 'changelog-test@example.com']);
    git(['config', 'user.name', 'Changelog test']);
    commit('feat: initial release');
    git(['tag', 'v1.0.0']);
    git(['tag', 'backup-pre-squash-deadbee']);
  });

  tearDown(() {
    repo.deleteSync(recursive: true);
  });

  group('buildDigest', () {
    test('a prerelease covers only the commits after the last tag', () {
      commit('feat(a): first feature');
      git(['tag', 'v1.1.0-pre.1']);
      commit('feat(b): second feature');
      commit('fix(c): a fix');
      commit('chore: bump build number');
      commit('test: cover the fix');
      commit('feat: hidden feature\n\nChangelog: skip');

      final result = digest('v1.1.0-pre.2');

      expect(result.from, 'v1.1.0-pre.1');
      expect(result.groups.map((group) => group.type), [
        ChangelogType.feat,
        ChangelogType.fix,
      ]);
      expect(result.groups.first.entries.map((entry) => entry.text), [
        'Second feature',
      ]);
      expect(
        result.other,
        unorderedEquals([
          matches(r'^[0-9a-f]{7} chore: bump build number$'),
          matches(r'^[0-9a-f]{7} test: cover the fix$'),
          matches(r'^[0-9a-f]{7} feat: hidden feature$'),
        ]),
      );
      expect(result.earlierNotes, isEmpty);
      expect(result.warnings, isEmpty);
    });

    group('stable target', () {
      setUp(() {
        commit('feat(a): first feature');
        git(['tag', 'v1.1.0-pre.1']);
        commit('fix(b): second fix');
        git(['tag', 'v1.1.0-pre.2']);
        commit('feat(c): third feature');
      });

      test('starts at the newest prerelease of the cycle', () {
        write('release_notes/v1.1.0-pre.1.md', validNotes);
        write('release_notes/v1.1.0-pre.2.md', validNotes);

        final result = digest('v1.1.0');

        expect(result.from, 'v1.1.0-pre.2');
        expect(
          result.groups.expand((group) => group.entries).map((e) => e.text),
          ['Third feature'],
        );
        expect(result.earlierNotes.map((notes) => notes.tag.name), [
          'v1.1.0-pre.2',
          'v1.1.0-pre.1',
        ]);
        expect(result.warnings, isEmpty);
      });

      test('represents a prerelease without notes from its summary', () {
        write('release_notes/v1.1.0-pre.2.md', validNotes);
        writeSummary('v1.1.0-pre.1');

        final result = digest('v1.1.0');

        final fromSummary = result.earlierNotes.last;
        expect(fromSummary.tag.name, 'v1.1.0-pre.1');
        expect(fromSummary.body, contains('Summary headline'));
        expect(fromSummary.body, contains('- Spotlight: Spotlight text.'));
        expect(result.warnings, isEmpty);
      });

      test('warns about a prerelease with neither notes nor summary', () {
        write('release_notes/v1.1.0-pre.2.md', validNotes);

        final result = digest('v1.1.0');

        expect(result.earlierNotes.map((notes) => notes.tag.name), [
          'v1.1.0-pre.2',
        ]);
        expect(result.warnings.single, contains('v1.1.0-pre.1'));
        expect(result.warnings.single, contains('neither notes nor a summary'));
      });
    });

    test('without a reachable earlier tag the range is all history', () {
      final result = digest('v0.5.0');

      expect(result.from, isNull);
      expect(result.warnings.single, contains('no earlier release tag'));
    });

    test('renderDigest names the range and the commit hashes', () {
      commit('feat(a): first feature');
      final hash = git(['rev-parse', 'HEAD']).trim().substring(0, 7);

      final text = renderDigest(digest('v1.1.0-pre.1'));

      expect(text, contains('# Digest for v1.1.0-pre.1'));
      expect(text, contains('Range: v1.0.0..HEAD'));
      expect(text, contains('- [a] First feature ($hash)'));
    });
  });

  group('release notes files', () {
    test('readAllReleaseNotes ignores the README', () {
      write('release_notes/README.md', 'Plain prose, not release notes.\n');
      write('release_notes/v1.0.0.md', validNotes);

      expect(readAllReleaseNotes(repo.path).map((item) => item.tag.name), [
        'v1.0.0',
      ]);
      expect(verifyReleaseNotes(repo.path), isEmpty);
    });

    test('verifyReleaseNotes reports a misnamed file', () {
      write('release_notes/notes.md', validNotes);

      expect(verifyReleaseNotes(repo.path).single, contains('notes.md'));
      expect(
        verifyReleaseNotes(repo.path).single,
        contains('not named after a tag'),
      );
    });

    test('verifyReleaseNotes reports an invalid file with its path', () {
      write('release_notes/v1.0.0.md', '## Wrong heading\n');

      expect(
        verifyReleaseNotes(repo.path).single,
        startsWith('release_notes/v1.0.0.md:'),
      );
    });
  });

  group('CLI', () {
    test('changelog writes CHANGELOG.md from the notes', () {
      write('release_notes/v1.0.0.md', validNotes);

      final result = changelog(['changelog']);

      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      expect(
        File('${repo.path}/CHANGELOG.md').readAsStringSync(),
        allOf(startsWith('# Changelog'), contains('## v1.0.0')),
      );
    });

    test('verify passes when everything is consistent', () {
      write('release_notes/v1.0.0.md', validNotes);
      expect(changelog(['changelog']).exitCode, 0);

      final result = changelog(['verify']);

      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    });

    test('verify fails when CHANGELOG.md is stale', () {
      write('release_notes/v1.0.0.md', validNotes);
      expect(changelog(['changelog']).exitCode, 0);
      write('release_notes/v1.0.1.md', validNotes);

      final result = changelog(['verify']);

      expect(result.exitCode, 1);
      expect(result.stderr, contains('CHANGELOG.md is stale'));
    });

    test('render release fails when the notes file is missing', () {
      final result = changelog(['render', 'release', '--tag', 'v1.0.0']);

      expect(result.exitCode, isNot(0));
      expect(result.stderr, contains('release_notes/v1.0.0.md is missing'));
    });
  });
}
