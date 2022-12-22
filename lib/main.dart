import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_animated_list/bloc/page_bloc.dart';

void main() {
  runApp(
    BlocProvider<PageBloc>(
      create: (context) => PageBloc(),
      child: const AnimatedListSample(),
    ),
  );
}

class AnimatedListSample extends StatefulWidget {
  const AnimatedListSample({super.key});

  @override
  State<AnimatedListSample> createState() => _AnimatedListSampleState();
}

class _AnimatedListSampleState extends State<AnimatedListSample> {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PageBloc>();
    bloc.removedItemBuilder = _buildRemovedItem;

    return MaterialApp(
      home: BlocBuilder<PageBloc, PageState>(
        builder: (context, state) {
          if (state is LoadSuccessState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('AnimatedList'),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () => bloc.add(ItemInsertedEvent()),
                    tooltip: 'insert a new item',
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () => bloc.add(ItemRemovedEvent()),
                    tooltip: 'remove the selected item',
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedList(
                  key: bloc.listKey,
                  initialItemCount: state.list.length,
                  // key: _listKey,
                  // initialItemCount: _list.length,
                  itemBuilder: _buildItem,
                ),
              ),
            );
          } else {
            return const Scaffold();
          }
        },
      ),
    );
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    final bloc = context.read<PageBloc>();
    final state = bloc.state;

    final int item = () {
      if (state is LoadSuccessState) {
        return state.list[index];
      } else {
        return -1;
      }
    }();

    final int? selectedItem = () {
      if (state is LoadSuccessState) {
        return state.selectedItem;
      } else {
        return null;
      }
    }();

    return CardItem(
      animation: animation,
      item: item,
      selected: selectedItem == item,
      onTap: () {
        final newSelectedItem = selectedItem == item ? null : item;
        bloc.add(ItemSelectedEvent(newSelectedItem));
      },
    );
  }

  /// The builder function used to build items that have been removed.
  ///
  /// Used to build an item after it has been removed from the list. This method
  /// is needed because a removed item remains visible until its animation has
  /// completed (even though it's gone as far as this ListModel is concerned).
  /// The widget will be used by the [AnimatedListState.removeItem] method's
  /// [AnimatedRemovedItemBuilder] parameter.
  Widget _buildRemovedItem(
      int item, BuildContext context, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: item,
      // No gesture detector here: we don't want removed items to be interactive.
    );
  }
}

typedef RemovedItemBuilder<T> = Widget Function(
    T item, BuildContext context, Animation<double> animation);

/// Displays its integer item as 'item N' on a Card whose color is based on
/// the item's value.
///
/// The text is displayed in bright green if [selected] is
/// true. This widget's height is based on the [animation] parameter, it
/// varies from 0 to 128 as the animation varies from 0.0 to 1.0.
class CardItem extends StatelessWidget {
  const CardItem({
    super.key,
    this.onTap,
    this.selected = false,
    required this.animation,
    required this.item,
  }) : assert(item >= 0);

  final Animation<double> animation;
  final VoidCallback? onTap;
  final int item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headlineMedium!;
    if (selected) {
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
    }
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        sizeFactor: animation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 80.0,
            child: Card(
              color: Colors.primaries[item % Colors.primaries.length],
              child: Center(
                child: Text('Item $item', style: textStyle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
