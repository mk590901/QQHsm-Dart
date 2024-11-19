import 'dart:convert';
import '../interfaces/i_serialization.dart';

class PairStringString implements ISerialization {

  String? _key;
  Object? _value;

  PairStringString(this._key, this._value);

  String? getKey() {
    return _key;
  }

  Object? getValue() {
    return _value;
  }

  @override
  String encode() {
    return jsonEncode(this);
  }

  PairStringString.decode(String json) {
    var map = jsonDecode(json);
    _key = map["key"];
    _value = map["value"];
  }

  PairStringString.fromMap(Map<String, dynamic> map) {
    _key = map["key"];
    _value = map["value"];
  }

  Map toJson() => {"key": _key, "value": _value};
}
