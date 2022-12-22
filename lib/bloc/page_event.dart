part of 'page_bloc.dart';

@immutable
abstract class PageEvent {}

class ItemInsertedEvent extends PageEvent {}

class ItemRemovedEvent extends PageEvent {}

class ItemSelectedEvent extends PageEvent {
  ItemSelectedEvent(this.selectedItem);

  final int? selectedItem;
}
