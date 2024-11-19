import 'dart:convert';

import '../interfaces/i_serialization.dart';

class PairStringInt implements ISerialization
{
  int           _value = 0;
  Object?       _key;
  PairStringInt (this._key, this._value);
  Object?       getKey  ()  { return  _key;    }
  int           getValue()  { return  _value;  }

  @override
  String  encode  () {
    return  jsonEncode(this);
  }

  PairStringInt.decode(String json) {
    var map = jsonDecode(json);
    _key    = map["key"];
    _value  = map["value"];
  }

  PairStringInt.fromMap(Map<String, dynamic> map) {
    _key    = map["key"];
    _value  = map["value"];
  }

  Map toJson() => {"key":_key, "value": _value};

}
