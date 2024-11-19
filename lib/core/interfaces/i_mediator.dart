import 'i_hsm.dart';

abstract class IMediator {
  void setHsm(IHsm hsm);
  void init();
  void execute(String? state, int signal, [int? data]); //  HSM->CONTROL OBJECT
  void objDone(int signal, Object? data); //  CONTROL OBJECT->HSM
  int getEvent(int contextEventID);
  String? getEventId(int event);
}
