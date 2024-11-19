class ObjectEvent {
  int		  _event	= 0x00;
  Object?	_data;

  ObjectEvent(int event, [Object? data]) {
    _event	= event;
    _data	= data;
  }

  int event() {
    return	_event;
  }

  Object? data() {
    return	_data;
  }

}
