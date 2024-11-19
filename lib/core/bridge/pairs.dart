import '../../QQHsm/QQHsm.dart';

class Pairs {
  final Map <int,int> _container 	= <int,int>{};

  int number() {
    return	_container.length;
  }

  bool	add	(int objectAction, int hsmSignal) {
    bool result = false;
    if (_container.containsKey(objectAction)) {
      return	result;
    }
    _container[objectAction] = hsmSignal;
    result = true;
    return	result;
  }

  int?	get(int objectAction) {
    int? result = QQHsm.Q_EMPTY_SIG;
    if (!_container.containsKey(objectAction)) {
      return	result;
    }
    result	= _container[objectAction];
    return	result;
  }
}
