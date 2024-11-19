import '../Log/i_logger.dart';
import '../Log/logger.dart';
import '../core/bridge/interceptor.dart';
import '../core/bridge/object_event.dart';
import '../QQHsm/QQHsmStateMachine.dart';
import '../QQHsm/QQHsmScheme.dart';
import '../QQMediator/QQMediator.dart';
import '../QQContextObject/QQContextObject.dart';
import '../QQHsm/QQHsmWrapper.dart';
import '../interfaces/i_updater.dart';

class QQHsmBridge {
  ILogger                 contextLogger = Logger();
  late Interceptor        interceptor;
  late QQContextObject    contextObject;
  late QQHsmStateMachine  hsmStateMachine;
  late QQMediator         mediator;
  late QQHsmScheme        scheme;
  late QQHsmWrapper       schemeWrapper;

//  Constructor
  QQHsmBridge (this.hsmStateMachine, List<String> appEvents, IUpdater updater) {

    interceptor   = Interceptor();
    contextObject = QQContextObject(updater, contextLogger);
    mediator      = QQMediator(contextObject, hsmStateMachine, appEvents, interceptor);
    scheme        = QQHsmScheme(hsmStateMachine.getHSMScheme()!, hsmStateMachine.getEventsGenerator()!, mediator, hsmStateMachine.getInitialState()!);
    schemeWrapper = QQHsmWrapper(scheme, hsmStateMachine.getEventsGenerator()!, mediator);

    contextObject.init();
  }

  void done (String eventName) {
    contextObject.done(ObjectEvent(contextObject.getEvent(eventName) ?? 0));
  }

}