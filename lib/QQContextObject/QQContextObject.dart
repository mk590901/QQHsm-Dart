import '../core/interfaces/i_object.dart';
import '../core/bridge/object_event.dart';
import '../Log/i_logger.dart';
import '../core/interfaces/i_mediator.dart';
import '../interfaces/i_updater.dart';
import 'QQContextObjectEventsGenerator.dart';

class QQContextObject implements IObject {

  IMediator?  _mediator;
  ILogger?    _logger;
  IUpdater?   _update;

  final QQContextObjectEventsGenerator
    _internalEvents = QQContextObjectEventsGenerator();

  QQContextObject(IUpdater? update, [ILogger? logger]) {
    _update = update;
    _logger = logger;
  }

  @override
  void done(ObjectEvent signal) {
    _mediator?.objDone(signal.event(), signal.data());
  }

  @override
  IMediator? mediator() {
    return _mediator;
  }

  @override
  void setMediator(IMediator? mediator) {
    _mediator = mediator;
  }

  @override
  void init() {
    _mediator?.init();
  }

  bool onInit(Object? data) {
    bool result = false;
    _logger?.trace(data == null ? 'top-INIT' : 'top-INIT[$data]');
    return result;
  }

  bool onS_(String state, String event, Object? data) {
    bool result = false;
    _logger?.trace(data == null ? '$state-$event' : '$state-$event[$data]');
    _update?.transition(state, event);
    return result;
  }

  int? getEvent(String eventName) {
    return  _internalEvents.getEvent(eventName);
  }

  IUpdater? updater() {
    return _update;
  }

  ILogger? logger() {
    return _logger;
  }

}
