import '../basic/q_event.dart';

abstract class IHsm {
  void 		    init		      ();
  void 		    dispatch	    (QEvent event);
}
