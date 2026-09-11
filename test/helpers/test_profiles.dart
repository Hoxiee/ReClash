import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';

class TestProfiles extends Profiles {
  final List<Profile> initial;
  Exception? putAsyncError;

  TestProfiles([this.initial = const []]);

  @override
  List<Profile> build() => initial;

  @override
  Future<Profile> putAsync(Profile profile) async {
    final error = putAsyncError;
    if (error != null) throw error;
    put(profile);
    return state.firstWhere((item) => item.id == profile.id);
  }

  @override
  void put(Profile profile) {
    final next = List<Profile>.from(state);
    final index = next.indexWhere((item) => item.id == profile.id);
    if (index == -1) {
      next.add(profile);
    } else {
      next[index] = profile;
    }
    state = next;
  }

  @override
  Future<void> del(int id) async {
    state = state.where((profile) => profile.id != id).toList();
  }

  @override
  void reorder(List<Profile> profiles) {
    state = List.of(profiles);
  }

  @override
  void updateProfile(int profileId, Profile Function(Profile profile) builder) {
    final index = state.indexWhere((item) => item.id == profileId);
    if (index == -1) return;
    final next = List<Profile>.from(state);
    next[index] = builder(state[index]);
    state = next;
  }

  void replace(List<Profile> profiles) {
    state = profiles;
  }
}
