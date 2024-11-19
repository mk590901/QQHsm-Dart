import 'dart:async';
import 'dart:collection';
import '../core/basic/q_event.dart';
import '../core/interfaces/i_mediator.dart';
import '../QQHsm/QQHsm.dart';
import '../QQHsm/QQHsmEventsGenerator.dart';
import '../QQHsm/QQHsmStateMachine.dart';
import '../core/interfaces/i_hsm.dart';
import '../QQContextObject/QQContextObject.dart';
import '../core/bridge/interceptor.dart';
import '../core/bridge/commands.dart';
import '../core/bridge/pairs.dart';
import '../Evaluation/data_container.dart';
import '../Evaluation/data_collection.dart';
import '../Log/i_logger.dart';

class QQMediator extends IMediator {

  Map <int,String> hashTable    = <int, String>{};

  late  ILogger?              _logger;
  final QQContextObject?	    _context;
  final Interceptor		        _interceptor;
  final Pairs		              _connector  = Pairs();
  late  IHsm? 		            _hsm;
  late  Commands 		          _commands;
  late  QQHsmEventsGenerator  _generator;

  final Queue<QEvent> _queue = Queue<QEvent>();

  QQMediator (this._context, QQHsmStateMachine hsmDescription, List<String> appEvents, this._interceptor) {

    _generator    = hsmDescription.getEventsGenerator()!;

    _context?.setMediator(this);

    _logger       = _context?.logger();

    createCommands      (hsmDescription);
    createTable         (appEvents);
    createConnector	    (appEvents);
  }

  void createTable(List<String> appEvents) {
    hashTable[_generator.getEvent("Q_EMPTY_SIG")] = "Q_EMPTY";
    hashTable[_generator.getEvent("Q_INIT_SIG") ] = "Q_INIT";
    hashTable[_generator.getEvent("Q_ENTRY_SIG")] = "Q_ENTRY";
    hashTable[_generator.getEvent("Q_EXIT_SIG") ] = "Q_EXIT";

    for (int i = 0; i < appEvents.length; i++) {
      hashTable[_generator.getEvent(appEvents[i]) ] = appEvents[i];
    }
    hashTable[_generator.getEvent("INIT_SIG")   ] = "INIT";
  }

  void createConnector(List<String> appEvents) {
    for (int i = 0; i < appEvents.length; i++) {
      _connector.add(_context!.getEvent(appEvents[i])!, _generator.getEvent(appEvents[i]));
    }
  }

  @override
  int getEvent(int contextEventID) {
    return  _connector.get(contextEventID)!;
  }

 @override
  String  getEventId(int event) {
    return hashTable.containsKey(event) ? hashTable[event]! : "UNKNOWN";
  }

  @override
  void execute(String? state, int signal, [int? data]) {
    if (state == null) {
      return;
    }
    String state_ = (state == QQHsm.top) ? "top" : state;
    dynamic command = _commands.get(state_, signal);
    if (command == null) {
      Object? data_ = _interceptor.getObject(data!);
      if (data_ == null) {
        _logger?.trace('$state_-${getEventId(signal)}');
      }
      else {
        _logger?.trace('$state_-${getEventId(signal)}[$data_]');
      }
    }
    else
    if (command != null) {
        command(state_, signal, data);
    }
  }

  @override
  void setHsm(IHsm hsm) {
    _hsm = hsm;
  }

  @override
  void objDone(int signal, Object? data) {
    int?	hsmEvt 	= eventObj2Hsm(signal);
    int	dataId	= _interceptor.putObject(data);
    QEvent 	 e	=  QEvent(hsmEvt!, dataId);
    _queue.add(e);
    scheduleMicrotask(() {
      while (_queue.isNotEmpty) {
        QEvent event = _queue.removeFirst();
        String  eventText = getEventId(event.sig);
          _logger?.clear('[$eventText]: ');
        _hsm?.dispatch(event);
        _context?.updater()?.trace(eventText, _logger?.toTrace());

        _interceptor.clear(event.ticket);
      }
    });
  }

  @override
  void init() {
    scheduleMicrotask(() {
        _logger?.clear('[INIT]: ');
      _hsm?.init();
        _context?.updater()?.trace('init', _logger?.toTrace());

    });
  }

  int? eventObj2Hsm(int signal) {
    return	_connector.get(signal); // !!! Problem H
  }

  void	createCommands(QQHsmStateMachine hsmDescription) {
    _commands = Commands(s_);

//  init
    _commands.adds("top",     _generator.getEvent("INIT_SIG"));

    DataCollection?
      dataCollection = hsmDescription.getHSMScheme();

    List<String>?
      keys = dataCollection?.getKeys();
    if (keys == null || keys.isEmpty) {
      return;
    }

    for (int i = 0; i < keys.length; i++) {
      Object? object = dataCollection?.getDataContainer(keys[i]);
      if (object is DataContainer) {
        DataContainer
          dataContainer = object;
        List<int>
          eventKeys = dataContainer.getKeys();
        for (int j = 0; j < eventKeys.length; j++) {
          _commands.adds(keys[i], eventKeys[j]);
        }
      }
    }
  }

  bool initTop (int signal, int? ticket) {
    Object? value   = _interceptor.getObject(ticket);
    bool? result    = _context?.onInit(value!);
    return	result?? false;
  }

  bool s_(String state, int signal, int? ticket) {
    String event    = _generator.getEventName(signal);
    Object? value   = _interceptor.getObject(ticket);
    bool? result    = _context?.onS_(state, event, value);
    return	result?? false;
  }


}