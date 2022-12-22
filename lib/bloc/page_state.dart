part of 'page_bloc.dart';

abstract class PageState {}

class LoadSuccessState extends PageState {
  LoadSuccessState({
    required this.list,
    required this.nextItem,
  });

  // ListModel<int> list;
  List<int> list;
  int nextItem; // The next item inserted when the user presses the '+' button.
  int? selectedItem;
}
