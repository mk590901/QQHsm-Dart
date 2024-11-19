import '../Evaluation/pair_string_string.dart';
import '../QQHsm/QQHsmEventsGenerator.dart';
import '../Evaluation/pair_int_string.dart';
import 'dart:convert';

import '../interfaces/i_serialization.dart';

class QQHsmMediator implements ISerialization {
  Map<String, String?> _table = <String, String>{};
  Map<int, String> _connector= <int, String>{};

  QQHsmMediator(QQHsmEventsGenerator generator) {
    List<PairIntString>
      list = generator.mapRevert2List();
    for (PairIntString pair in list) {
      String eventName = pair.getValue().toString();
      String key = '';
      String value = '';
      if (eventName.endsWith('_SIG')) {
        int idx = eventName.indexOf('_SIG');
        key = eventName;
        value = eventName.substring(0, idx);
      }
      else {
        key = '${eventName}_SIG';
        value = eventName;
      }
      _table[key] = value;
    }
    _table['INIT_SIG'] = 'INIT';
    int key = 1;
    for (PairIntString pair in list) {
      String eventName = pair.getValue().toString();
      if (!eventName.endsWith('_SIG')) {
        _connector[key++] = '${eventName}_SIG';
      }
    }
    _connector[key++] = 'INIT_SIG';
  }

  int getEventNumber(String eventName) {
    print("eventName->$eventName");
    int result = -1;
    if (_connector.isEmpty) {
      return result;
    }
    String event = '${eventName}_SIG';
    List<PairIntString> list = [];
    _connector.forEach((k, v) => list.add(PairIntString(k, v)));
    for (PairIntString pair in list) {
      if (event == pair.getValue().toString()) {
        result = pair.getKey();
        break;
      }
    }
    return result;
  }

  @override
  String encode() {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map toJson() => {
    "table": mapStringString2List(),
    "connector": mapIntString2List(),
  };

  QQHsmMediator.decode(String json) {
    var map = jsonDecode(json);
    _table = list2MapStringString(map["table"]);
    _connector = list2MapIntString(map["connector"]);
  }

  QQHsmMediator.fromMap(Map<String, dynamic> map) {
    _table = list2MapStringString(map["table"]);
    _connector = list2MapIntString(map["connector"]);
  }

  List<PairIntString> mapIntString2List() {
    List<PairIntString> list = [];
    _connector.forEach((k, v) => list.add(PairIntString(k, v)));
    return list;
  }

  Map<int, String> list2MapIntString(List<dynamic> list) {
    Map<int, String> result = <int, String>{};
    for (int i = 0; i < list.length; i++) {
      PairIntString pair = PairIntString.fromMap(list[i]);
      result[pair.getKey()] = pair.getValue() as String;
    }
    return result;
  }

  List<PairStringString> mapStringString2List() {
    List<PairStringString> list = [];
    _table.forEach((k, v) => list.add(PairStringString(k, v)));
    return list;
  }

  Map<String, String?> list2MapStringString(List<dynamic> list) {
    Map<String, String?> result = <String, String?>{};
    for (int i = 0; i < list.length; i++) {
      PairStringString pair = PairStringString.fromMap(list[i]);
      result[pair.getKey()!] = pair.getValue() as String;
    }
    return result;
  }

}