import 'i_mediator.dart';
import '../bridge/object_event.dart';

abstract class IObject {
  void		    done		    (ObjectEvent signal);
  IMediator?	mediator 	  ();
  void		    setMediator (IMediator? mediator);
  void		    init		    ();
}
