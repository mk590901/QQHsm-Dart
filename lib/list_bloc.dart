import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ListEvent extends Equatable {
  const ListEvent();

  @override
  List<Object> get props => [];
}

class AddItem extends ListEvent {
  final String item;

  const AddItem(this.item);

  @override
  List<Object> get props => [item];
}

class DeleteItem extends ListEvent {
  final String item;

  const DeleteItem(this.item);

  @override
  List<Object> get props => [item];
}

// States
abstract class ListState extends Equatable {
  const ListState();

  @override
  List<Object> get props => [];
}

class ListInitial extends ListState {}

class ListLoaded extends ListState {
  final List<String> items;

  const ListLoaded(this.items);

  @override
  List<Object> get props => [items];
}

// BLoC
class ListBloc extends Bloc<ListEvent, ListState> {
  ListBloc() : super(ListInitial()) {

    on<AddItem>((event, emit) {
      final state = this.state;
      if (state is ListLoaded) {
        emit(ListLoaded(List.from(state.items)..add(event.item)));
      } else {
        emit(ListLoaded([event.item]));
      }
    });

    on<DeleteItem>((event, emit) {
      final state = this.state;
      if (state is ListLoaded) {
        emit(ListLoaded(List.from(state.items)..remove(event.item)));
      }
    });
  }
}
