part of 'database.dart';

@DataClassName('RawClashProvider')
class ClashProviders extends Table {
  @override
  String get tableName => 'clash_providers';

  IntColumn get id => integer()();

  TextColumn get kind => textEnum<ProviderKind>()();

  TextColumn get label => text()();

  TextColumn get url => text()();

  TextColumn get requestHeaders =>
      text().map(const ProviderHeadersConverter()).nullable()();

  TextColumn get behavior => textEnum<RuleProviderBehavior>().nullable()();

  TextColumn get format => textEnum<RuleProviderFormat>().nullable()();

  IntColumn get order => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ProviderHeadersConverter
    extends TypeConverter<Map<String, String>?, String?> {
  const ProviderHeadersConverter();

  @override
  Map<String, String>? fromSql(String? value) {
    if (value == null) return const {};
    return decodeOrRestoreDefault(
      'provider request headers',
      () => validateResourceHeaders(
        Map<String, String>.from(json.decode(value) as Map),
      ),
      () => const {},
    );
  }

  @override
  String? toSql(Map<String, String>? value) =>
      value == null ? null : json.encode(validateResourceHeaders(value));
}

@DriftAccessor(tables: [ClashProviders])
class ClashProvidersDao extends DatabaseAccessor<Database>
    with _$ClashProvidersDaoMixin {
  ClashProvidersDao(super.attachedDatabase);

  /// App-level providers are rule providers. Older builds still read [kind],
  /// and a proxy provider one of them saved is left out.
  Expression<bool> _isRuleProvider($ClashProvidersTable t) {
    return t.kind.equalsValue(ProviderKind.rule);
  }

  Selectable<ClashProvider> query() {
    return clashProviders.readable(
      (row) => row.toClashProvider(),
      where: _isRuleProvider,
      orderBy: [
        (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
        (t) => OrderingTerm.asc(t.id),
      ],
    );
  }

  Selectable<String> fileNames() {
    final query = selectOnly(clashProviders)
      ..addColumns([
        clashProviders.id,
        clashProviders.url,
        clashProviders.requestHeaders,
      ])
      ..where(_isRuleProvider(clashProviders));
    return query.map(
      (row) => ClashProvider(
        id: row.read(clashProviders.id)!,
        label: '',
        url: row.read(clashProviders.url)!,
        headers:
            row.readWithConverter<Map<String, String>?, String>(
              clashProviders.requestHeaders,
            ) ??
            const <String, String>{},
      ).fileName,
    );
  }

  Future<void> putAll(Iterable<ClashProvidersCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(clashProviders, items);
    });
  }

  void putAllWithBatch(Batch batch, Iterable<ClashProvider> providers) {
    batch.insertAllOnConflictUpdate(
      clashProviders,
      providers.map((item) => item.toCompanion()),
    );
  }

  void setAllWithBatch(Batch batch, Iterable<ClashProvider> providers) {
    clashProviders.setAll(
      batch,
      providers.map((provider) => provider.toCompanion()),
      deleteFilter: (_) => const Constant(true),
      preDelete: true,
    );
  }
}

extension RawClashProviderExt on RawClashProvider {
  ClashProvider toClashProvider() {
    return ClashProvider(
      id: id,
      label: label,
      url: url,
      headers: requestHeaders ?? const {},
      behavior: behavior ?? RuleProviderBehavior.classical,
      format: format ?? RuleProviderFormat.yaml,
      order: order,
    );
  }
}

extension ClashProvidersCompanionExt on ClashProvider {
  ClashProvidersCompanion toCompanion([int? order]) {
    return ClashProvidersCompanion.insert(
      id: Value(id),
      kind: ProviderKind.rule,
      label: label,
      url: url,
      requestHeaders: Value(headers),
      behavior: Value(behavior),
      format: Value(format),
      order: Value(order ?? this.order),
    );
  }
}
