import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/import.dart';

class GitHubScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/github',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GitHub')),
      body: BlocProvider(
        create: (BuildContext context) =>
            GitHubCubit(getRepository<GitHubRepository>(context))
              ..readRepositories(),
        child: GitHubBody(),
      ),
    );
  }
}

class GitHubBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GitHubCubit, GitHubState>(
      listener: (BuildContext context, GitHubState state) {
        if (state is GitHubLoadFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('GitHub Load Failure')),
            );
        }
      },
      builder: (BuildContext context, GitHubState state) {
        if (state is GitHubLoadInProgress) {
          return Center(child: const CircularProgressIndicator());
        }
        if (state is GitHubLoadSuccess && state.repositories.isNotEmpty) {
          // return Center(
          //   child: Text('${state.repositories.length}'),
          // );

          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: state.repositories.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _StarrableRepository(
                        repository: state.repositories[index]);
                  },
                ),
              ),
            ],
          );
        }
        return Center(
          child: Text('none'),
        );
      },
    );
  }
}

class _StarrableRepository extends StatelessWidget {
  const _StarrableRepository({
    Key key,
    @required this.repository,
  }) : super(key: key);

  final RepositoryModel repository;

  // Map<String, Object> extractRepositoryData(Object data) {
  //   final action =
  //       (data as Map<String, Object>)['action'] as Map<String, Object>;
  //   if (action == null) {
  //     return null;
  //   }
  //   return action['starrable'] as Map<String, Object>;
  // }

  // bool get starred => repository['viewerHasStarred'] as bool;
  // bool get optimistic => (repository as LazyCacheMap).isOptimistic;

  // Map<String, dynamic> get expectedResult => <String, dynamic>{
  //       'action': <String, dynamic>{
  //         'starrable': <String, dynamic>{'viewerHasStarred': !starred}
  //       }
  //     };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: repository.viewerHasStarred
          ? const Icon(
              Icons.star,
              color: Colors.amber,
            )
          : const Icon(Icons.star_border),
      // trailing: result.loading || optimistic
      //     ? const CircularProgressIndicator()
      //     : null,
      title: Text(repository.name),
      onTap: () {
        // toggleStar(
        //   <String, dynamic>{
        //     'starrableId': repository['id'],
        //   },
        //   optimisticResult: expectedResult,
        // );
      },
    );
  }
}