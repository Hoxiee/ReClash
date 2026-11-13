import 'package:reclash/features/lovense/client.dart';
import 'package:reclash/features/lovense/controller.dart';
import 'package:reclash/features/lovense/models.dart';

LovenseToy fakeLovenseToy({
  String id = 'toy1',
  bool connected = true,
  List<LovenseFunction> functions = const [
    LovenseFunction.vibrate,
    LovenseFunction.pump,
  ],
}) => LovenseToy(
  id: id,
  name: 'lush',
  nickName: 'Test toy $id',
  connected: connected,
  battery: 60,
  functions: functions,
  hasFunctionInfo: true,
);

class FakeLovenseApi implements LovenseApi {
  List<LovenseToy> toys = [fakeLovenseToy(), fakeLovenseToy(id: 'toy2')];
  final commands = <Map<String, Object>>[];
  Future<List<LovenseToy>>? pendingToys;
  Future<void>? pendingFunction;
  Future<void>? pendingStop;
  LovenseError? toysError;
  LovenseError? functionError;
  LovenseError? stopError;
  bool closed = false;

  @override
  Future<List<LovenseToy>> getToys() async {
    commands.add({'command': 'GetToys'});
    if (toysError != null) throw toysError!;
    return pendingToys ?? toys;
  }

  @override
  Future<void> function({
    required String toyId,
    required LovenseFunction function,
    required int strength,
    required int duration,
    LovenseStroke? stroke,
  }) async {
    commands.add({
      'command': 'Function',
      'action': '${function.apiName}:$strength',
      'toy': toyId,
      'timeSec': duration,
    });
    if (functionError != null) throw functionError!;
    final pending = pendingFunction;
    if (pending != null) await pending;
  }

  @override
  Future<void> stop({String? toyId}) async {
    commands.add({'command': 'Function', 'action': 'Stop', 'toy': ?toyId});
    if (stopError != null) throw stopError!;
    final pending = pendingStop;
    if (pending != null) await pending;
  }

  @override
  void close() => closed = true;
}

class FakeLovenseStore implements LovenseEndpointStore {
  String? address;
  int loads = 0;
  final saved = <String>[];
  bool saveResult = true;

  @override
  Future<String?> load() async {
    loads++;
    return address;
  }

  @override
  Future<bool> save(String address) async {
    saved.add(address);
    this.address = address;
    return saveResult;
  }
}
