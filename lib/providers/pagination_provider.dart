import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginationState<T> {
  final List<T> items;
  final DocumentSnapshot? lastDocument;
  final bool hasNextPage;
  final bool isFetchingNextPage;
  final Object? nextPageError;

  PaginationState({
    this.items = const [],
    this.lastDocument,
    this.hasNextPage = true,
    this.isFetchingNextPage = false,
    this.nextPageError,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    DocumentSnapshot? lastDocument,
    bool? hasNextPage,
    bool? isFetchingNextPage,
    Object? nextPageError,
  }) {
    return PaginationState(
      items: items ?? this.items,
      lastDocument: lastDocument ?? this.lastDocument,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
      nextPageError: nextPageError ?? this.nextPageError,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaginationState<T> &&
        listEquals(other.items, items) &&
        other.lastDocument == lastDocument &&
        other.hasNextPage == hasNextPage &&
        other.isFetchingNextPage == isFetchingNextPage &&
        other.nextPageError == nextPageError;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll([items]),
      lastDocument,
      hasNextPage,
      isFetchingNextPage,
      nextPageError,
    );
  }
}

typedef FetchPage<T> = Future<({List<T> items, DocumentSnapshot? lastDoc})>
    Function({
  required int limit,
  DocumentSnapshot? lastDocument,
});

typedef FetchPageWithArg<T, Arg>
    = Future<({List<T> items, DocumentSnapshot? lastDoc})> Function({
  required Arg arg,
  required int limit,
  DocumentSnapshot? lastDocument,
});

abstract class PaginatedAsyncNotifier<T>
    extends AsyncNotifier<PaginationState<T>> {
  int get pageSize;
  FetchPage<T> get fetchPage;

  bool _isFetching = false;

  @override
  Future<PaginationState<T>> build();

  Future<void> fetchNextPage() async {
    final currentState = state.valueOrNull;
    if (_isFetching || currentState == null || !currentState.hasNextPage) {
      return;
    }

    _isFetching = true;
    state = AsyncData(currentState.copyWith(
      isFetchingNextPage: true,
      nextPageError: null,
    ));

    try {
      final result = await fetchPage(
        limit: pageSize,
        lastDocument: currentState.lastDocument,
      );

      final hasNext = result.items.length == pageSize;
      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...result.items],
        lastDocument: result.lastDoc ?? currentState.lastDocument,
        hasNextPage: hasNext,
        isFetchingNextPage: false,
      ));
    } catch (e) {
      state = AsyncData(currentState.copyWith(
        isFetchingNextPage: false,
        nextPageError: e,
      ));
    } finally {
      _isFetching = false;
    }
  }
}

abstract class PaginatedFamilyAsyncNotifier<T, Arg>
    extends FamilyAsyncNotifier<PaginationState<T>, Arg> {
  int get pageSize;
  FetchPageWithArg<T, Arg> get fetchPage;

  bool _isFetching = false;

  @override
  Future<PaginationState<T>> build(Arg arg);

  Future<void> fetchNextPage() async {
    final currentArg = arg;
    final currentState = state.valueOrNull;

    if (_isFetching || currentState == null || !currentState.hasNextPage) {
      return;
    }

    _isFetching = true;
    state = AsyncData(currentState.copyWith(
      isFetchingNextPage: true,
      nextPageError: null,
    ));

    try {
      final result = await fetchPage(
        arg: currentArg,
        limit: pageSize,
        lastDocument: currentState.lastDocument,
      );

      final hasNext = result.items.length == pageSize;
      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...result.items],
        lastDocument: result.lastDoc ?? currentState.lastDocument,
        hasNextPage: hasNext,
        isFetchingNextPage: false,
      ));
    } catch (e) {
      state = AsyncData(currentState.copyWith(
        isFetchingNextPage: false,
        nextPageError: e,
      ));
    } finally {
      _isFetching = false;
    }
  }
}
