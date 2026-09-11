import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/database.g.dart';

Future<void> withRollback<T>({
  required T snapshot,
  required FutureOr<void> Function() action,
  required void Function(T snapshot) rollback,
}) async {
  try {
    await action();
  } catch (e, s) {
    rollback(snapshot);
    Error.throwWithStackTrace(e, s);
  }
}

Future<void> _persistOptimistically<T>(
  T previous,
  T next,
  T Function() read,
  void Function(T value) write,
  FutureOr<void> Function() action,
) async {
  write(next);
  try {
    await action();
  } catch (e, s) {
    if (identical(read(), next)) {
      write(previous);
    }
    Error.throwWithStackTrace(e, s);
  }
}

void _reportOptimisticFailure(Object error, StackTrace stackTrace) {
  commonPrint.log(
    'Optimistic database write failed: ${compactError(error)}, $stackTrace',
    logLevel: LogLevel.warning,
  );
  dialogs.showNotifier(
    currentAppLocalizations.databaseWriteFailedTip,
    level: MessageLevel.error,
  );
}

mixin OptimisticMixin<T> on AsyncNotifierMixin<T> {
  void optimistic(T next, FutureOr<void> Function() action) {
    unawaited(
      optimisticAsync(next, action).catchError(_reportOptimisticFailure),
    );
  }

  Future<void> optimisticAsync(T next, FutureOr<void> Function() action) {
    return _persistOptimistically(
      value,
      next,
      () => value,
      (v) => value = v,
      action,
    );
  }
}

@riverpod
Stream<List<Profile>> profilesStream(Ref ref) {
  return database.profilesDao.query().watch();
}

@riverpod
Stream<List<Rule>> addedRulesStream(Ref ref, int profileId) {
  return database.rulesDao.queryAddedRules(profileId).watch();
}

@riverpod
Stream<int> customRulesCount(Ref ref, int profileId) {
  return database.rulesDao.profileCustomRulesCount(profileId).watchSingle();
}

@riverpod
Stream<int> proxyGroupsCount(Ref ref, int profileId) {
  return database.proxyGroupsDao.count(profileId).watchSingle();
}

@Riverpod(keepAlive: true)
class Profiles extends _$Profiles {
  final _mutations = Queue<_ProfileMutation>();
  var _persisting = false;
  List<Profile>? _confirmed;

  @override
  List<Profile> build() {
    final persisted = ref.watch(profilesStreamProvider).value ?? [];
    _confirmed = persisted;
    return _replayProfileMutations(persisted, _mutations);
  }

  Future<Profile> putAsync(Profile profile) {
    final completer = Completer<void>();
    final optimized = state.optimizeLabel(profile);
    _enqueueMutation(_PutProfileMutation(optimized, completer));
    return completer.future.then((_) => optimized);
  }

  void put(Profile profile) {
    final optimized = state.optimizeLabel(profile);
    _enqueueMutation(_PutProfileMutation(optimized));
  }

  Future<void> del(int id) {
    final completer = Completer<void>();
    _enqueueMutation(_DeleteProfileMutation(id, completer));
    return completer.future;
  }

  void updateProfile(int profileId, Profile Function(Profile profile) builder) {
    if (state.getProfile(profileId) == null) return;
    _enqueueMutation(_UpdateProfileMutation(profileId, builder));
  }

  void setAndReorder(List<Profile> profiles) {
    _enqueueMutation(_SetProfilesMutation(List<Profile>.from(profiles)));
  }

  void reorder(List<Profile> profiles) {
    final ids = profiles.map((profile) => profile.id).toList();
    _enqueueMutation(_ReorderProfilesMutation(ids));
  }

  Future<void> reorderAsync(List<Profile> profiles) {
    final completer = Completer<void>();
    final ids = profiles.map((profile) => profile.id).toList();
    _enqueueMutation(_ReorderProfilesMutation(ids, completer));
    return completer.future;
  }

  void _enqueueMutation(_ProfileMutation mutation) {
    _confirmed ??= state;
    _mutations.add(mutation);
    state = mutation.apply(state);
    unawaited(_drainMutations());
  }

  Future<void> _drainMutations() async {
    if (_persisting) return;
    _persisting = true;
    try {
      while (_mutations.isNotEmpty) {
        final mutation = _mutations.first;
        try {
          await mutation.persist();
          _confirmed = mutation.confirm(_confirmed ?? const []);
          mutation.complete();
        } catch (error, stackTrace) {
          mutation.completeError(error, stackTrace);
          if (mutation.completer == null) {
            _reportOptimisticFailure(error, stackTrace);
          }
        } finally {
          _mutations.removeFirst();
          state = _replayProfileMutations(_confirmed ?? const [], _mutations);
        }
      }
    } finally {
      _persisting = false;
    }
  }

  @override
  bool updateShouldNotify(List<Profile> previous, List<Profile> next) {
    return !profileListEquality.equals(previous, next);
  }
}

List<Profile> _replayProfileMutations(
  List<Profile> base,
  Iterable<_ProfileMutation> mutations,
) {
  var current = base;
  for (final mutation in mutations) {
    current = mutation.apply(current);
  }
  return current;
}

sealed class _ProfileMutation {
  const _ProfileMutation(this.completer);

  final Completer<void>? completer;

  List<Profile> apply(List<Profile> profiles);

  List<Profile> confirm(List<Profile> profiles) => apply(profiles);

  Future<void> persist();

  void complete() => completer?.complete();

  void completeError(Object error, StackTrace stackTrace) =>
      completer?.completeError(error, stackTrace);
}

final class _PutProfileMutation extends _ProfileMutation {
  const _PutProfileMutation(this.profile, [super.completer]);

  final Profile profile;

  @override
  List<Profile> apply(List<Profile> profiles) =>
      profiles.copyAndPut(profile, (item) => item.id == profile.id);

  @override
  Future<void> persist() => database.profiles.put(profile.toCompanion());
}

final class _UpdateProfileMutation extends _ProfileMutation {
  _UpdateProfileMutation(this.id, this.builder) : super(null);

  final int id;
  final Profile Function(Profile profile) builder;
  Profile? _optimistic;
  Profile? _persisted;

  @override
  List<Profile> apply(List<Profile> profiles) {
    final profile = profiles.getProfile(id);
    if (profile == null) return profiles;
    final updated = builder(profile);
    _optimistic ??= updated;
    return profiles.copyAndPut(updated, (item) => item.id == id);
  }

  @override
  Future<void> persist() async {
    final rows = await database.profilesDao.query().get();
    final profile = rows.getProfile(id);
    if (profile == null) return;
    final updated = builder(profile);
    await database.profiles.put(updated.toCompanion());
    _persisted = updated;
  }

  @override
  List<Profile> confirm(List<Profile> profiles) {
    final profile = _persisted ?? _optimistic;
    if (profile == null || profiles.getProfile(id) == null) return profiles;
    return profiles.copyAndPut(profile, (item) => item.id == id);
  }
}

final class _DeleteProfileMutation extends _ProfileMutation {
  const _DeleteProfileMutation(this.id, [super.completer]);

  final int id;

  @override
  List<Profile> apply(List<Profile> profiles) =>
      profiles.where((profile) => profile.id != id).toList();

  @override
  Future<void> persist() =>
      database.profiles.remove((profile) => profile.id.equals(id));
}

final class _SetProfilesMutation extends _ProfileMutation {
  const _SetProfilesMutation(this.profiles) : super(null);

  final List<Profile> profiles;

  @override
  List<Profile> apply(List<Profile> current) => List<Profile>.from(profiles);

  @override
  Future<void> persist() => database.profilesDao.setAll(profiles);
}

final class _ReorderProfilesMutation extends _ProfileMutation {
  _ReorderProfilesMutation(this.ids, [super.completer]);

  final List<int> ids;
  List<Profile>? _persisted;

  @override
  List<Profile> apply(List<Profile> profiles) {
    final byId = {for (final profile in profiles) profile.id: profile};
    final reordered = <Profile>[
      for (final id in ids) ?byId.remove(id),
      ...byId.values,
    ];
    return [
      for (final (index, profile) in reordered.indexed)
        profile.order == index ? profile : profile.copyWith(order: index),
    ];
  }

  @override
  Future<void> persist() async {
    final persisted = await database.profilesDao.query().get();
    final reordered = apply(persisted);
    await database.profilesDao.putAll(
      reordered.mapIndexed((index, profile) => profile.toCompanion(index)),
    );
    _persisted = reordered;
  }

  @override
  List<Profile> confirm(List<Profile> profiles) =>
      _persisted ?? apply(profiles);
}

@riverpod
class Scripts extends _$Scripts with AsyncNotifierMixin, OptimisticMixin {
  @override
  Stream<List<Script>> build() {
    return database.scriptsDao.query().watch();
  }

  @override
  List<Script> get value => state.value ?? [];

  void put(Script script) {
    final next = List<Script>.from(value);
    final index = next.indexWhere((item) => item.id == script.id);
    if (index != -1) {
      next[index] = script;
    } else {
      next.add(script);
    }
    optimistic(next, () => database.scripts.put(script.toCompanion()));
  }

  void del(int id) {
    final next = List<Script>.from(value);
    final index = next.indexWhere((item) => item.id == id);
    if (index == -1) return;
    next.removeAt(index);
    optimistic(next, () => database.scripts.remove((t) => t.id.equals(id)));
  }

  void delAll(Iterable<int> ids) {
    final scriptIds = ids.toSet();
    optimistic(
      value.where((item) => !scriptIds.contains(item.id)).toList(),
      () => database.scripts.remove((t) => t.id.isIn(scriptIds)),
    );
  }

  bool isExits(String label) {
    return value.indexWhere((item) => item.label == label) != -1;
  }

  @override
  bool updateShouldNotify(
    AsyncValue<List<Script>> previous,
    AsyncValue<List<Script>> next,
  ) {
    return !scriptListEquality.equals(previous.value, next.value);
  }
}

@riverpod
Future<Script?> script(Ref ref, int? scriptId) async {
  final script = ref.watch(
    scriptsProvider.future.select((state) async {
      final scripts = await state;
      return scripts.get(scriptId);
    }),
  );
  return script;
}

mixin RuleListMixin on OptimisticMixin<List<Rule>> {
  Future<void> persistRule(Rule rule);

  Future<void> persistOrder({required int ruleId, required String order});

  @override
  List<Rule> get value => state.value ?? [];

  @override
  bool updateShouldNotify(
    AsyncValue<List<Rule>> previous,
    AsyncValue<List<Rule>> next,
  ) {
    return !ruleListEquality.equals(previous.value, next.value);
  }

  void put(Rule rule) {
    final newRule = rule.autoOrder(rule, null, value.firstOrNull?.order);
    optimistic(
      value.copyAndPut(newRule, (rule) => rule.id == newRule.id),
      () => persistRule(newRule),
    );
  }

  void delAll(Iterable<int> ruleIds) {
    optimistic(
      value.where((item) => !ruleIds.contains(item.id)).toList(),
      () => database.rulesDao.delRules(ruleIds),
    );
  }

  void order(int oldIndex, int newIndex) {
    final item = value[oldIndex];
    final nextItems = value.copyAndReorder(oldIndex, newIndex);
    final newOrder = indexing.generateKeyBetween(
      nextItems.safeGet(newIndex - 1)?.order,
      nextItems.safeGet(newIndex + 1)?.order,
    )!;
    optimistic(nextItems, () => persistOrder(ruleId: item.id, order: newOrder));
  }
}

@riverpod
class GlobalRules extends _$GlobalRules
    with AsyncNotifierMixin, OptimisticMixin, RuleListMixin {
  @override
  Stream<List<Rule>> build() {
    return database.rulesDao.queryGlobalAddedRules().watch();
  }

  @override
  Future<void> persistRule(Rule rule) => database.rulesDao.putGlobalRule(rule);

  @override
  Future<void> persistOrder({required int ruleId, required String order}) =>
      database.rulesDao.orderGlobalRule(ruleId: ruleId, order: order);
}

@riverpod
class ProfileAddedRules extends _$ProfileAddedRules
    with AsyncNotifierMixin, OptimisticMixin, RuleListMixin {
  @override
  Stream<List<Rule>> build(int profileId) {
    return database.rulesDao.queryProfileAddedRules(profileId).watch();
  }

  @override
  Future<void> persistRule(Rule rule) =>
      database.rulesDao.putProfileAddedRule(profileId, rule);

  @override
  Future<void> persistOrder({required int ruleId, required String order}) =>
      database.rulesDao.orderProfileAddedRule(
        profileId,
        ruleId: ruleId,
        order: order,
      );
}

@riverpod
class ProfileCustomRules extends _$ProfileCustomRules
    with AsyncNotifierMixin, OptimisticMixin, RuleListMixin {
  @override
  Stream<List<Rule>> build(int profileId) {
    return database.rulesDao.queryProfileCustomRules(profileId).watch();
  }

  @override
  Future<void> persistRule(Rule rule) =>
      database.rulesDao.putProfileCustomRule(profileId, rule);

  @override
  Future<void> persistOrder({required int ruleId, required String order}) =>
      database.rulesDao.orderProfileCustomRule(
        profileId,
        ruleId: ruleId,
        order: order,
      );
}

@riverpod
class ProxyGroups extends _$ProxyGroups
    with AsyncNotifierMixin, OptimisticMixin {
  @override
  Stream<List<ProxyGroup>> build(int profileId) {
    return database.proxyGroupsDao.query(profileId).watch();
  }

  @override
  bool updateShouldNotify(
    AsyncValue<List<ProxyGroup>> previous,
    AsyncValue<List<ProxyGroup>> next,
  ) {
    return !proxyGroupsEquality.equals(previous.value, next.value);
  }

  void del(String name) {
    optimistic(
      value.where((item) => item.name != name).toList(),
      () => database.proxyGroups.remove(
        (t) => t.profileId.equals(profileId) & t.name.equals(name),
      ),
    );
  }

  bool put(ProxyGroup proxyGroup) {
    final previous = value;
    final index = previous.indexWhere((item) => item.id == proxyGroup.id);
    if (index == -1 &&
        previous.indexWhere((item) => item.name == proxyGroup.name) != -1) {
      return false;
    }
    final renamedFrom = index != -1 && previous[index].name != proxyGroup.name
        ? previous[index].name
        : null;
    final icon = proxyGroup.icon?.value;
    final next = List<ProxyGroup>.from(previous);
    final ProxyGroup nextProxyGroup;
    if (index != -1) {
      nextProxyGroup = proxyGroup;
      next[index] = nextProxyGroup;
    } else {
      final lastOrder = previous.map((item) => item.order).nonNulls.lastOrNull;
      nextProxyGroup = proxyGroup.copyWith(
        order: indexing.generateKeyBetween(lastOrder, null),
      );
      next.add(nextProxyGroup);
    }
    optimistic(
      next,
      () => database.transaction(() async {
        if (renamedFrom != null) {
          await database.rulesDao.renameCustomRuleTarget(
            profileId,
            oldName: renamedFrom,
            newName: nextProxyGroup.name,
          );
          await database.proxyGroupsDao.renameProxies(
            profileId,
            oldName: renamedFrom,
            newName: nextProxyGroup.name,
          );
        }
        if (icon != null) {
          await database.iconRecordsDao.put(icon);
        }
        await database.proxyGroups.put(nextProxyGroup.toCompanion(profileId));
      }),
    );
    return true;
  }

  void order(int oldIndex, int newIndex) {
    final item = value[oldIndex];
    final nextItems = value.copyAndReorder(oldIndex, newIndex);
    final newOrder = indexing.generateKeyBetween(
      nextItems.safeGet(newIndex - 1)?.order,
      nextItems.safeGet(newIndex + 1)?.order,
    )!;
    optimistic(
      nextItems,
      () => database.proxyGroupsDao.order(
        profileId,
        proxyGroup: item,
        order: newOrder,
      ),
    );
  }

  @override
  List<ProxyGroup> get value => state.value ?? [];
}

@riverpod
class ProfileDisabledRuleIds extends _$ProfileDisabledRuleIds
    with AsyncNotifierMixin, OptimisticMixin {
  @override
  List<int> get value => state.value ?? [];

  @override
  Stream<List<int>> build(int profileId) {
    return database.rulesDao
        .queryProfileDisabledRules(profileId)
        .map((item) => item.id)
        .watch();
  }

  @override
  bool updateShouldNotify(
    AsyncValue<List<int>> previous,
    AsyncValue<List<int>> next,
  ) {
    return !intListEquality.equals(previous.value, next.value);
  }

  void del(int ruleId) {
    optimistic(
      value.where((item) => item != ruleId).toList(),
      () => database.rulesDao.delDisabledLink(profileId, ruleId),
    );
  }

  void put(int ruleId) {
    final next = List<int>.from(value);
    if (!next.contains(ruleId)) {
      next.insert(0, ruleId);
    }
    optimistic(
      next,
      () => database.rulesDao.putDisabledLink(profileId, ruleId),
    );
  }
}
