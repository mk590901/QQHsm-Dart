import '../core/basic/q_event.dart';
import '../QQHsm/QQHsm.dart';
import '../QQHsm/QQHsmEventsGenerator.dart';
import '../Evaluation/data_container.dart';
import '../Evaluation/data_collection.dart';
import '../core/interfaces/i_mediator.dart';

class QQHsmScheme extends QQHsm {

  IMediator?             _mediator;
  DataCollection?        _collection;
  QQHsmEventsGenerator?  _generator;
  String?                _initialState;

  QQHsmScheme(DataCollection collection, QQHsmEventsGenerator generator, IMediator mediator, String initialState) {
    _collection   = collection;
    _generator    = generator;
    _mediator     = mediator;
    _initialState = initialState;
  }

  @override
  String? evalState(String? stateName, QEvent e) {
    //@print("evalState->[$stateName:${_generator!.getEventName(e.sig)}]");
    if (stateName == QQHsm.top) { //  null
      print ("return evalState 1 -> null");
      return  null; //  BUG WAS REPAIRED 09.10.2018, Mk
    }

    DataContainer?
      dataContainer = _collection?.getDataContainer(stateName) as DataContainer?;
    if (dataContainer == null) {
      print ("Failed to evalState '$stateName'");
      return null;
    }
    //@dataContainer.trace("-- evalState");
    Map<int, Object?>
      container = dataContainer.container;
    if (container.containsKey(e.sig)) {
      String? target = container[e.sig] as String?;
      //@print ("evalState target ->[$target]]");

      _mediator?.execute(stateName!, e.sig, e.ticket);
      if (target != null) {
        Q_TRAN(target);
      }
      //@print ("return evalState 2 -> null");
      return null;
    }
    //@print ("return evalState 3 -> ${dataContainer.superState}");
    return dataContainer.superState;
  }

  @override
  void init(QEvent e) {
    _mediator?.execute(QQHsm.top, _generator!.getEvent("INIT_SIG"));
    super.init_tran(_initialState!);
  }

}
