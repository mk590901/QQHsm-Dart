import '../interfaces/i_serialization.dart';
import 'pair_int_string.dart';
import 'dart:convert';

class DataContainer implements ISerialization {
  Map<int,Object?> _container  = <int,Object?>{};
  String?          _superState;

  DataContainer(this._container, this._superState);

  Map<int,Object?> get container   => _container;
  String?          get superState  => _superState;

  set container (Map<int,Object?> pContainer) {
    _container = pContainer;
  }

  set superState (String? pReturnState) {
    _superState = pReturnState;
  }

  List<int>  getKeys() {
    List<int>
    result  = [];
    _container.forEach((k,v) => result.add(k));
    return  result;
  }

  @override
  String encode() {
    JsonEncoder
    encoder = const JsonEncoder.withIndent('  ');
    return  encoder.convert(toJson());
  }

  Map toJson() => {
    "container"   :  map2List(),
    "superstate"  : _superState,
  };

  List<PairIntString> map2List() {
    List<PairIntString>
    list  = [];
    _container.forEach((k,v) => list.add(PairIntString(k,v)));
    return  list;
  }

  DataContainer.decode(String json) {
    var map     = jsonDecode(json);
    _container  = list2Map(map["container"]);
    _superState = map["superstate"];
  }

  DataContainer.fromMap(Map<String, dynamic> map) {
    _container  = list2Map(map["container"]);
    _superState = map["superstate"];
  }

  Map<int, Object?> list2Map(List<dynamic> list) {
    Map<int, Object?>
      result = <int, Object?>{};
    for (int i = 0; i < list.length; i++) {
      PairIntString
        pair = PairIntString.fromMap(list[i]);
      result[pair.getKey()] = pair.getValue();
    }
    return  result;
  }

  void trace (String prompt) {
    print ("$prompt.superState->[$_superState]");
    print ("$prompt.container ->[$_container]");
  }

}

