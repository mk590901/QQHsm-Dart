class Commands {
  final Map<String,dynamic> _container 	= <String,dynamic>{};
  dynamic _executor;

  Commands ([dynamic executor]) {
    _executor = executor;
  }

  int number() {
    return	_container.length;
  }

  bool	adds	(String state, int signal) {
    bool	result = false;
    String	key = getKey(state,signal);
    if (_container.containsKey(key)) {
      return	result;
    }
    _container[key] = _executor;
    result = true;
    return	result;
  }

  bool	add	(String state, int signal, dynamic executor) {
    bool	result = false;
    String	key = getKey(state,signal);
    if (_container.containsKey(key)) {
      return	result;
    }
    _container[key] = executor;
    result = true;
    return	result;
  }

  dynamic	get(String state, int signal) {
    dynamic	result;
    String	key = getKey(state,signal);
    if (!_container.containsKey(key)) {
      return	result;
    }
    result	= _container[key];
    return	result;
  }

  String getKey(String state, int signal) {
    String	result = "$state@$signal";
    return	result;
  }

}
