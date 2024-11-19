class QQContextObjectEventsGenerator {
  final Map<String, int>_container  = <String, int>{};
//  Constructor
  QQContextObjectEventsGenerator();
  int? getEvent(String eventName) {
    int? result = -1;
    if (_container.containsKey(eventName)) {
      result = _container[eventName];
      return result;
    }
    result = _container.length + 1;
    _container[eventName] = result;
    return result;
  }

}
