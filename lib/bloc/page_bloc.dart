import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:poc_animated_list/main.dart';

part 'page_event.dart';
part 'page_state.dart';

class PageBloc extends Bloc<PageEvent, PageState> {
  PageBloc()
      : super(
          LoadSuccessState(
            list: [0, 1, 2],
            nextItem: 3,
          ),
        ) {
    on<ItemInsertedEvent>(_onItemInsertedEvent);
    on<ItemRemovedEvent>(_onItemRemovedEvent);
    on<ItemSelectedEvent>(_onItemSelectedEvent);
  }

  late RemovedItemBuilder<int> removedItemBuilder;
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  AnimatedListState? get _animatedList => listKey.currentState;

  FutureOr<void> _onItemInsertedEvent(
    ItemInsertedEvent event,
    Emitter<PageState> emit,
  ) {
    final state = this.state;

    if (state is LoadSuccessState) {
      final list = state.list;
      final selectedItem = state.selectedItem;
      final int index =
          selectedItem == null ? list.length : list.indexOf(selectedItem!);

      list.insert(index, state.nextItem++);
      _animatedList?.insertItem(index);
    }
  }

  FutureOr<void> _onItemRemovedEvent(
    ItemRemovedEvent event,
    Emitter<PageState> emit,
  ) {
    final state = this.state;

    if (state is LoadSuccessState) {
      final list = state.list;
      final selectedItem = state.selectedItem;

      if (selectedItem != null) {
        final index = list.indexOf(selectedItem);
        list.removeAt(index);

        _animatedList?.removeItem(
          index,
          (context, animation) => removedItemBuilder(
            selectedItem,
            context,
            animation,
          ),
        );

        state.selectedItem = null;
      }
    }
  }

  FutureOr<void> _onItemSelectedEvent(
    ItemSelectedEvent event,
    Emitter<PageState> emit,
  ) {
    final state = this.state;

    if (state is LoadSuccessState) {
      state.selectedItem = event.selectedItem;
      // emit(state);

      final newState = LoadSuccessState(
        list: state.list,
        nextItem: state.nextItem,
      );
      newState.selectedItem = state.selectedItem;
      newState.nextItem = state.nextItem;
      emit(newState);
    }
  }
}
