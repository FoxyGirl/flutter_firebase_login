import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_firebase_login/import.dart';

class GitHubRepositoriesCubit extends Cubit<GitHubRepositoriesState> {
  GitHubRepositoriesCubit(this.gitHubRepository)
      : assert(gitHubRepository != null),
        super(const GitHubRepositoriesState());

  final GitHubRepository gitHubRepository;

  Future<bool> load() async {
    var result = true;
    emit(state.copyWith(status: GitHubStatus.busy));
    try {
      final items = await gitHubRepository.readRepositories();
      emit(const GitHubRepositoriesState());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(state.copyWith(
        items: items,
        status: GitHubStatus.ready,
      ));
    } catch (error) {
      result = false;
    }
    return result;
  }

  List<RepositoryModel> _updateStarLocally(String id, bool value) {
    final index =
        state.items.indexWhere((RepositoryModel item) => item.id == id);
    if (index == -1) {
      return state.items;
    }
    final items = [...state.items];
    final item = items[index];
    items[index] = item.copyWith(viewerHasStarred: value);
    return items;
  }

  Future<bool> toggleStar({String id, bool value}) async {
    var result = true;
    emit(state.copyWith(
      items: _updateStarLocally(id, value),
      loadingItems: {...state.loadingItems}..add(id),
    ));
    try {
      await gitHubRepository.toggleStar(id: id, value: value);
    } catch (error) {
      emit(state.copyWith(
        items: _updateStarLocally(id, !value),
      ));
      result = false;
    } finally {
      emit(state.copyWith(
        loadingItems: {...state.loadingItems}..remove(id),
      ));
    }
    return result;
  }
}

enum GitHubStatus { initial, busy, ready }

class GitHubRepositoriesState extends Equatable {
  const GitHubRepositoriesState({
    this.items = const [],
    this.status = GitHubStatus.initial,
    this.loadingItems = const {},
  }) : assert(items != null);

  final List<RepositoryModel> items;
  final GitHubStatus status;
  final Set<String> loadingItems;

  @override
  List<Object> get props => [items, status, loadingItems];

  GitHubRepositoriesState copyWith({
    List<RepositoryModel> items,
    GitHubStatus status,
    Set<String> loadingItems,
  }) {
    return GitHubRepositoriesState(
      items: items ?? this.items,
      status: status ?? this.status,
      loadingItems: loadingItems ?? this.loadingItems,
    );
  }
}
