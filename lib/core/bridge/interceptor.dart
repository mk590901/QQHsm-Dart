class Interceptor {
  final Map <int,Object> _container = <int, Object>{};
  final int INVALID_TICKET = -1;

  Interceptor();

  int	putObject(Object? object) {
    int	result = INVALID_TICKET;
    if (object == null) {
      return	result;
    }
    result = getUniqueId();
    if (result == INVALID_TICKET) {
      return	result;
    }

    if (_container.containsKey(result)) {
      result = INVALID_TICKET;
      return	result;
    }
    _container[result] = object;
    return	result;
  }

  Object? getObject(int? ticket) {
    Object?	result;
    if (!_container.containsKey(ticket)) {
      return	result;
    }
    result	= _container[ticket];
    return	result;
  }

  void clear([int? ticket]) {
    if (ticket != null) {
      _container.remove(ticket);
      return;
    }
    if (_container.isNotEmpty) {
      _container.clear();
    }
  }

  int getUniqueId()
  {
    int   result = INVALID_TICKET;
    int   counter = 1;
    while (true) {
      bool duplication = checkId(counter);
      if (!duplication) {
        result = counter;
        break;
      }
      ++counter;
    }
    return  result;
  }

  bool checkId(int id)
  {
    bool result = false;
    result = _container.containsKey(id);
    return  result;
  }
}
