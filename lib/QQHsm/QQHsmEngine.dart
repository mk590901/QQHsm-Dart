import '../core/utilities/utils.dart';
import 'QQHsmStateMachine.dart';
import '../QQBridge/QQHsmBridge.dart';
import './../interfaces/i_updater.dart';

class QQHsmEngine {
  late  QQHsmStateMachine?  _stateMachine;
  late  QQHsmBridge?        _bridge;
  final IUpdater?           _updater;
  late  List<String>?       _appEvents;
  late  bool                _indic  = false;

  QQHsmEngine(this._updater);

  bool create(String? text) {
    bool    result = false;
    if (isEmpty(text)) {
      return result;
    }
    _stateMachine = QQHsmStateMachine.decode(text!);
    if (_stateMachine == null) {
      return  result;
    }
    _appEvents = _stateMachine?.extractAppEvents();
    if (_appEvents == null) {
      return result;
    }

    if (_appEvents!.isEmpty) {
      return result;
    }

    init();

    _indic = true;

    return  result;
  }

  void init() {
    if (_stateMachine != null && _appEvents != null && _updater != null) {
      _bridge = QQHsmBridge(_stateMachine!, _appEvents!, _updater);
    }
  }

  void done (String eventName) {
    if (!_indic) {
      return;
    }
    if (_bridge == null) {
      return;
    }

    if (_appEvents == null) {
      return;
    }

    if (!_appEvents!.contains(eventName)) {
      return;
    }
    _bridge?.done(eventName);
  }

  List<String>? appEvents() {
    return _appEvents;
  }


}
