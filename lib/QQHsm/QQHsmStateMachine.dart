import '../Evaluation/data_collection.dart';
import '../QQHsm/QQHsmEventsGenerator.dart';
import '../QQHsm/QQHsmMediator.dart';
import 'dart:convert';

import '../interfaces/i_serialization.dart';
import '../core/utilities/utils.dart';

class QQHsmStateMachine implements ISerialization {
  DataCollection? _collection;
  QQHsmEventsGenerator? _generator;
  QQHsmMediator? _mediator;

  String? _initialState = "";

  QQHsmStateMachine() {
    _generator = QQHsmEventsGenerator();
    _collection = DataCollection();
  }

  DataCollection? getHSMScheme() {
    return _collection;
  }

  QQHsmEventsGenerator? getEventsGenerator() {
    return _generator;
  }

  void setInitialState(String state) {
    /// In theory, there can't be more than one initial state in a scheme.
    /// This fact should be checked both during compilation and during editing
    /// of the properties of state. But there may also be errors due to the fact
    /// that sometimes an unfinished scheme is compiled.
    /// Therefore, the correct check is: if (state is not inside _initialState).
    if (isEmpty(_initialState)) {
      _initialState = state;
    }
    print('setInitialState->[$_initialState]');
  }

  String? getInitialState() {
    return _initialState;
  }

  void setMediator(QQHsmMediator mediator) {
    _mediator = mediator;
  }

  @override
  String encode() {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map toJson() => {
        "initstate": _initialState,
        "collection": _collection,
        "generator": _generator,
        "mediator": _mediator,
      };

  QQHsmStateMachine.decode(String json) {
    var map = jsonDecode(json);
    _initialState = map["initstate"];
    _collection = DataCollection.fromMap(map["collection"]);
    _generator = QQHsmEventsGenerator.fromMap(map["generator"]);
    _mediator = QQHsmMediator.fromMap(map["mediator"]);
  }

  List<String>? extractAppEvents() {
    return _generator?.extractAppEvents()?? [];
  }

}
