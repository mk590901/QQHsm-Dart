import '../interfaces/i_serialization.dart';
import 'QQHsm.dart';
import '../Evaluation/pair_int_string.dart';
import '../Evaluation/pair_string_int.dart';
import 'dart:convert';

class QQHsmEventsGenerator implements ISerialization {

  late  Map<String?, int> _container = <String?, int>{};
  late  Map<int, String>? _revertContainer;

//  Constructor
  QQHsmEventsGenerator() {
    _container["Q_EMPTY_SIG"] = QQHsm.Q_EMPTY_SIG;
    _container["Q_INIT_SIG"] = QQHsm.Q_INIT_SIG;
    _container["Q_ENTRY_SIG"] = QQHsm.Q_ENTRY_SIG;
    _container["Q_EXIT_SIG"] = QQHsm.Q_EXIT_SIG;
  }

  List<String> extractAppEvents() {
    List<String> standardEvents = [
      "INIT",
      "FINISH",
      "Q_EMPTY_SIG",
      "Q_INIT_SIG",
      "Q_ENTRY_SIG",
      "Q_EXIT_SIG"
    ];
    List<String> result = [];
    if (_container.isEmpty) {
      return result;
    }
    //  Form list from keys
    List<String> listEvents = [];
    _container.forEach((k, v) => listEvents.add(k!));

    for (int i = 0; i < listEvents.length; i++) {
      if (!standardEvents.contains(listEvents[i])) result.add(listEvents[i]);
    }
    return result;
  }

  int getEvent(String eventName) {
    int result = -1;
    if (_container.containsKey(eventName)) {
      result = _container[eventName]!;
      finalize(); //  Bug was fixed, 20.03.2020, Mk
      return result;
    }
    result = _container.length;
    _container[eventName] = result;
    finalize();
    return result;
  }

  String getEventName(int eventValue) {
    String result = "?";
    if (_revertContainer != null && _revertContainer!.containsKey(eventValue)) {
      result = _revertContainer![eventValue]!;
    }
    int idx = result.indexOf("_SIG");
    if (idx > 0) {
      result = result.substring(0, idx);
    }
    return result;
  }

  void finalize() {
    _revertContainer = _container.map((k, v) => MapEntry(v, k!));
  }

  @override
  String encode() {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map toJson() => {
        "direct": mapDirect2List(),
        "revert": mapRevert2List(),
      };

  List<PairStringInt> mapDirect2List() {
    List<PairStringInt> list = [];
    _container.forEach((k, v) => list.add(PairStringInt(k, v)));
    return list;
  }

  List<PairIntString> mapRevert2List() {
    List<PairIntString> list = [];
    _revertContainer!.forEach((k, v) => list.add(PairIntString(k, v)));
    return list;
  }

  QQHsmEventsGenerator.decode(String json) {
    var map = jsonDecode(json);
    _container = list2MapDirect(map["direct"]);
    _revertContainer = list2MapRevert(map["revert"]);
  }

  QQHsmEventsGenerator.fromMap(Map<String, dynamic> map) {
    _container = list2MapDirect(map["direct"]);
    _revertContainer = list2MapRevert(map["revert"]);
  }

  Map<int, String> list2MapRevert(List<dynamic> list) {
    Map<int, String> result = <int, String>{};
    for (int i = 0; i < list.length; i++) {
      PairIntString pair = PairIntString.fromMap(list[i]);
      result[pair.getKey()] = pair.getValue() as String;
    }
    return result;
  }

  Map<String, int> list2MapDirect(List<dynamic> list) {
    Map<String, int> result = <String, int>{};
    for (int i = 0; i < list.length; i++) {
      PairStringInt pair = PairStringInt.fromMap(list[i]);
      if (pair.getKey() != null) {
        result[pair.getKey() as String] = pair.getValue();
      }
    }
    return result;
  }
}
