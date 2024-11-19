import 'dart:convert';
import '../interfaces/i_serialization.dart';
import 'data_container.dart';

class PairStringDataContainer implements ISerialization {

  String?          _state;
  DataContainer?   _entity;
  PairStringDataContainer (this._state, this._entity);
  String?        getState  ()  { return  _state;  }
  DataContainer? getEntity ()  { return  _entity;  }

  @override
  String  encode  () {
    return  jsonEncode(this);
  }

  PairStringDataContainer.decode(String json){
    var map = jsonDecode(json);
    _state  = map["state"];
    _entity = DataContainer.fromMap(map["entity"]);
  }

  PairStringDataContainer.fromMap(Map<String, dynamic> map){
    _state  = map["state"];
    _entity = DataContainer.fromMap(map["entity"]);
  }

  Map toJson() => { "state": _state, "entity": _entity, };

}

class DataCollection implements ISerialization {
//  Data
  Map<String,Object?> _container    = <String, Object?>{};

//  Constructor
  DataCollection();

//  Methods
  void  insert(String stateName, Object stateEntity) {
    _container[stateName] = stateEntity;
  }

  Object?  getDataContainer(String? stateName) {
    return _container.containsKey(stateName) ? _container[stateName] : null;
  }

  int size() {
    return  _container.length;
  }

  List<String>  getKeys() {
    List<String>
      result  = [];
    _container.forEach((k,v) => result.add(k));
    return  result;
  }

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
  @override
  String encode() {
    JsonEncoder
    encoder = const JsonEncoder.withIndent('  ');
    return  encoder.convert(toJson());
  }

  Map toJson() => {
    "container" : map2List(),
  };

  List<PairStringDataContainer> map2List() {
    List<PairStringDataContainer>
      list  = [];
    _container.forEach((k,v) => list.add(PairStringDataContainer(k,v as DataContainer)));
    return  list;
  }

  DataCollection.decode(String json) {
    var map     = jsonDecode(json);
    _container  = list2Map(map["container"]);
  }

  DataCollection.fromMap(Map<String, dynamic> map) {
    _container  = list2Map(map["container"]);
  }

  Map<String, Object> list2Map(List<dynamic> list) {
    Map<String, Object>
    result = <String, Object>{};
    for (int i = 0; i < list.length; i++) {
      PairStringDataContainer
      pair = PairStringDataContainer.fromMap(list[i]);
      result[pair.getState()!] = pair.getEntity() as DataContainer;
    }
    return  result;
  }

  void trace(String prompt) {
    print ("------- $prompt -------");
    _container.forEach((k, v) {
      print(k);
      if (v is DataContainer) {
        v.trace("\t");
      }
    });
    print ("+++++++ $prompt +++++++");
  }

}