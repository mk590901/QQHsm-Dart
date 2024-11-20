import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class ButtonEvent extends Equatable {
  const ButtonEvent();

  @override
  List<Object> get props => [];
}

class AddButtonList extends ButtonEvent {
  final List<String> buttonNames;

  const AddButtonList(this.buttonNames);

  @override
  List<Object> get props => [buttonNames];
}

class ButtonState extends Equatable {
  final List<String> buttons;

  const ButtonState(this.buttons);

  @override
  List<Object> get props => [buttons];
}

class ButtonBloc extends Bloc<ButtonEvent, ButtonState> {
  ButtonBloc() : super(const ButtonState([])) {
    on<AddButtonList>((event, emit) {
      emit(ButtonState(event.buttonNames));
    });
  }
}
