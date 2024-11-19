import 'dart:convert';

import '../interfaces/i_serialization.dart';

class PairIntString implements ISerialization {
  int _key = 0;
  Object? _value;

  PairIntString(this._key, this._value);

  int getKey() {
    return _key;
  }

  Object? getValue() {
    return _value;
  }

  @override
  String encode() {
    return jsonEncode(this);
  }

  PairIntString.decode(String json) {
    var map = jsonDecode(json);
    _key = map["key"];
    _value = map["value"];
  }

  PairIntString.fromMap(Map<String, dynamic> map) {
    _key = map["key"];
    _value = map["value"];
  }

  Map toJson() => {"key": _key, "value": _value};
}
