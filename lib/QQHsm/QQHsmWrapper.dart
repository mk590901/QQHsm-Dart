import '../core/interfaces/i_mediator.dart';
import '../core/interfaces/i_hsm.dart';
import 'QQHsmScheme.dart';
import 'QQHsmEventsGenerator.dart';
import '../core/basic/q_event.dart';

class QQHsmWrapper implements IHsm {
  final IMediator?            _mediator;
  final QQHsmScheme	          _entity;
  final QQHsmEventsGenerator  _generator;

  QQHsmWrapper(this._entity, this._generator, this._mediator) {
    _mediator?.setHsm(this);
  }

  @override
  void init() {
    _entity.init(QEvent(_generator.getEvent("INIT_SIG")));
  }

  @override
  void dispatch(QEvent event) {
    _entity.dispatch(event);
  }
}
