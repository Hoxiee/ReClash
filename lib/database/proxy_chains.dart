part of 'database.dart';

@DataClassName('RawProxyChain')
class ProxyChains extends Table {
  @override
  String get tableName => 'proxy_chains';

  IntColumn get id => integer()();

  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();

  TextColumn get hops => text().map(const StringListConverter())();

  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  BoolColumn get nameAuto => boolean().withDefault(const Constant(true))();

  BoolColumn get offered => boolean().withDefault(const Constant(true))();

  TextColumn get targetGroup => text().nullable()();

  TextColumn get fingerprints =>
      text().map(const HopFingerprintsConverter()).nullable()();

  IntColumn get sortIndex => integer().withDefault(const Constant(0))();

  TextColumn get restorePick => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [ProxyChains])
class ProxyChainsDao extends DatabaseAccessor<Database>
    with _$ProxyChainsDaoMixin {
  ProxyChainsDao(super.attachedDatabase);

  Selectable<ProxyChain> query(int profileId) {
    return proxyChains.readable(
      (row) => row.toProxyChain(),
      where: (t) => t.profileId.equals(profileId),
      orderBy: [
        (t) => OrderingTerm.asc(t.sortIndex),
        (t) => OrderingTerm.asc(t.id),
      ],
    );
  }

  Selectable<ProxyChain> all() {
    return proxyChains.readable((row) => row.toProxyChain());
  }

  Future<ProxyChain?> get(int id) async {
    final rows = await proxyChains
        .readable((row) => row.toProxyChain(), where: (t) => t.id.equals(id))
        .get();
    return rows.firstOrNull;
  }

  Future<void> put(ProxyChain chain) async {
    await proxyChains.put(chain.toCompanion());
  }

  Future<void> remove(int id) async {
    await proxyChains.remove((t) => t.id.equals(id));
  }

  Future<void> reorder(List<int> ids) {
    return batch((b) {
      for (final (index, id) in ids.indexed) {
        b.update(
          proxyChains,
          ProxyChainsCompanion(sortIndex: Value(index)),
          where: (t) => t.id.equals(id),
        );
      }
    });
  }

  void setAllWithBatch(Batch batch, Iterable<ProxyChain> items) {
    proxyChains.setAll(
      batch,
      items.map((item) => item.toCompanion()),
      deleteFilter: (_) => const Constant(true),
      preDelete: true,
    );
  }

  void putAllWithBatch(Batch batch, Iterable<ProxyChain> items) {
    batch.insertAllOnConflictUpdate(
      proxyChains,
      items.map((item) => item.toCompanion()),
    );
  }
}

extension RawProxyChainExt on RawProxyChain {
  ProxyChain toProxyChain() {
    if (hops.length < minChainHops) {
      throw FormatException('chain $id has ${hops.length} hops');
    }
    return ProxyChain(
      id: id,
      profileId: profileId,
      name: name,
      hops: hops,
      enabled: enabled,
      nameAuto: nameAuto,
      offered: offered,
      targetGroup: targetGroup,
      fingerprints: fingerprints ?? const [],
      sortIndex: sortIndex,
      restorePick: restorePick,
    );
  }
}

extension ProxyChainsCompanionExt on ProxyChain {
  ProxyChainsCompanion toCompanion() {
    return ProxyChainsCompanion.insert(
      id: Value(id),
      profileId: profileId,
      name: name,
      hops: hops,
      enabled: Value(enabled),
      nameAuto: Value(nameAuto),
      offered: Value(offered),
      targetGroup: Value(targetGroup),
      fingerprints: Value(fingerprints.isEmpty ? null : fingerprints),
      sortIndex: Value(sortIndex),
      restorePick: Value(restorePick),
    );
  }
}
