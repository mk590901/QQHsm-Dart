import '../core/basic/q_event.dart';

abstract class QQHsm {
  String?        _state = "";

  final List<String?>  _path = List.filled(MAX_NEST_DEPTH, null, growable: false);

  static const Q_EMPTY_SIG  = 0;
  static const Q_INIT_SIG   = 1;
  static const Q_ENTRY_SIG  = 2;
  static const Q_EXIT_SIG   = 3;
  static const Q_USER_SIG   = 4;

  static final int MAX_NEST_DEPTH = 256; //	6

  static final QEvent _EMPTY_EVT_  = QEvent(Q_EMPTY_SIG);
  static final QEvent _INIT_EVT_   = QEvent(Q_INIT_SIG);
  static final QEvent _ENTRY_EVT_  = QEvent(Q_ENTRY_SIG);
  static final QEvent _EXIT_EVT_   = QEvent(Q_EXIT_SIG);

  static QEvent _EMPTY_EVT([int? ticket])
  {
    _EMPTY_EVT_.ticket = ticket;
    return  _EMPTY_EVT_;
  }

  static QEvent _INIT_EVT([int? ticket])
  {
    _INIT_EVT_.ticket = ticket;
    return  _INIT_EVT_;
  }

  static QEvent _ENTRY_EVT([int? ticket])
  {
    _ENTRY_EVT_.ticket = ticket;
    return  _ENTRY_EVT_;
  }

  static QEvent _EXIT_EVT([int? ticket])
  {
    _EXIT_EVT_.ticket = ticket;
    return  _EXIT_EVT_;
  }

  String? evalState (String? stateName, QEvent e);

  void init(QEvent e);

  static String?  top;

  void init_tran(String? initial) {
    _state = initial;

    String? s = top; //"top"; // an HSM starts in the top state
    do { // drill into the target...
      int ip = 0; // transition entry path index
      String? t = _state;
      _path[0] = t;
      //print ("@1@");
      for (t = evalState(t,_EMPTY_EVT()); t != s; t = evalState(t,_EMPTY_EVT())) {
        _path[++ip] = t;
      }
      assert (ip < MAX_NEST_DEPTH); // entry path must not overflow
      do { // retrace the entry path in reverse (desired) order...
        //print ("@2@");
        evalState(_path[ip],_ENTRY_EVT()); // enter _path[ip]
      } while (--ip >= 0);
      s = _state;
    } while (evalState(s,_INIT_EVT()) == null);
  }

  void Q_TRAN(String? target) {
    _state = target;
  }

  void dispatch(QEvent e) {
    String? s;
    String? t = _state;

    _path[1] = t; // save the current state in case a transition is taken
    _state = null; // make sure that a transition will be noticed

    do { // process the event hierarchically...
      s = t;
      t = evalState(s,e); // invoke state handler through pointer s
    } while (t != null);

    if (_state != null) { // transition taken?
      String? src = s; // the source of the transition
      int ip = -1; // transition entry path index
      int iq; // helper transition entry path index

      _path[0] = _state; // save the new state (target of tran.)
      _state = _path[1]; // restore the current state

      // exit current state to the transition source _path[1]...
      for (s = _path[1]; s != src;) {
        t = evalState(s,_EXIT_EVT(e.ticket));
        if (t != null) { // exit action unhandled
          s = t; // t points to superstate
        }
        else { // exit action handled
          s = evalState(s,_EMPTY_EVT(e.ticket)); // find out the superstate
        }
      }

      t = _path[0];

      if (src == t) { // (a) check source==target (transition to self)
        evalState(src,_EXIT_EVT(e.ticket)); // exit the source
        ip = 0; // enter the target
      }
      else {
        t = evalState(t,_EMPTY_EVT(e.ticket)); // superstate of target
        if (src == t) { // (b) check source==target->super
          ip = 0; // enter the target
        }
        else {
          s = evalState(src,_EMPTY_EVT(e.ticket)); // superstate of src
          if (s == t) { // (c) check source->super==target->super
            evalState(src,_EXIT_EVT()); // exit the source
            ip = 0; // enter the target
          }
          else {
            if (s == _path[0]) { // (d) check source->super==target
              evalState(src,_EXIT_EVT(e.ticket)); // exit the source
            }
            else { // (e) rest of source==target->super->super...
              // and store the entry path along the way

              iq = 0; // indicate that LCA not found
              ip = 1; // enter target and its superstate
              _path[1] = t; // save the superstate of target
              t = evalState(t,_EMPTY_EVT(e.ticket));
              while (t != null) {
                _path[++ip] = t; // store the entry path
                if (t == src) { // is it the source?
                  iq = 1; // indicate that LCA found
                  // entry path must not overflow
                  assert (ip < MAX_NEST_DEPTH);
                  --ip; // do not enter the source
                  t = null; // terminate the loop
                }
                else { // it is not the source, keep going up
                  t = evalState(t,_EMPTY_EVT(e.ticket));
                }
              }
              if (iq == 0) { // the LCA not found yet?

                // entry path must not overflow
                assert (ip < MAX_NEST_DEPTH);

                evalState(src,_EXIT_EVT(e.ticket)); // exit the source

                // (f) check the rest of source->super
                //             == target->super->super...

                iq = ip;
                do {
                  if (s == _path[iq]) { // is this the LCA?
                    t = s; // indicate that LCA is found
                    ip = (iq - 1); //do not enter LCA
                    iq = -1; // terminate the loop
                  }
                  else {
                    --iq; // try lower superstate of target
                  }
                } while (iq >= 0);

                if (t == null) { // LCA not found yet?
                  // (g) check each source->super->...
                  // for each target->super...

                  do {
                    t = evalState(s,_EXIT_EVT(e.ticket)); // exit s
                    if (t != null) { // unhandled?
                      s = t; // t points to super of s
                    }
                    else { // exit action handled
                      s = evalState(s,_EMPTY_EVT());
                    }
                    iq = ip;
                    do {
                      if (s == _path[iq]) { // is LCA?
                        // do not enter LCA
                        ip = (iq - 1);
                        iq = -1; // break inner loop
                        s = null; // break outer loop
                      }
                      else {
                        --iq;
                      }
                    } while (iq >= 0);
                  } while (s != null);
                }
              }
            }
          }
        }
      }
      // retrace the entry path in reverse (desired) order...
      for (; ip >= 0; --ip) {
        evalState(_path[ip],_ENTRY_EVT(e.ticket)); // enter _path[ip]
      }
      s = _path[0]; // stick the target into register
      _state = s; // update the current state

      // drill into the target hierarchy...
      while (evalState(s,_INIT_EVT(e.ticket)) == null) {
        t = _state;

        _path[0] = t;
        ip = 0;
        for (t = evalState(t,_EMPTY_EVT(e.ticket)); t != s;
        t = evalState(t,_EMPTY_EVT(e.ticket))) {
          _path[++ip] = t;
        }
        assert (ip < MAX_NEST_DEPTH); // entry path must not overflow

        do { // retrace the entry path in reverse (correct) order...
          evalState(_path[ip],_ENTRY_EVT(e.ticket)); // enter _path[ip]
        } while ((--ip) >= 0);
        s = _state;
      }
    }
    else {
      _state = _path[1]; // restore the current state
    }
  }
}

/* Original M.Samek
abstract class QHsm {
  QState _state;
  List<QState> _path = new List(MAX_NEST_DEPTH);

  static const Q_EMPTY_SIG  = 0;
  static const Q_INIT_SIG   = 1;
  static const Q_ENTRY_SIG  = 2;
  static const Q_EXIT_SIG   = 3;
  static const Q_USER_SIG   = 4;

  static final int MAX_NEST_DEPTH = 256; //	6

  static final QEvent _EMPTY_EVT  = new QEvent(Q_EMPTY_SIG);
  static final QEvent _INIT_EVT   = new QEvent(Q_INIT_SIG);
  static final QEvent _ENTRY_EVT  = new QEvent(Q_ENTRY_SIG);
  static final QEvent _EXIT_EVT   = new QEvent(Q_EXIT_SIG);

  void init(QEvent e);

  static QState  top(QEvent) => null;

  void init_tran(QState initial) {
    _state = initial;

    QState s = top; // an HSM starts in the top state
    do { // drill into the target...
      int ip = 0; // transition entry path index
      QState t = _state;
      _path[0] = t;
      for (t = t(_EMPTY_EVT); t != s; t = t(_EMPTY_EVT)) {
        _path[++ip] = t;
      }
      assert (ip < MAX_NEST_DEPTH); // entry path must not overflow
      do { // retrace the entry path in reverse (desired) order...
        _path[ip](_ENTRY_EVT); // enter _path[ip]
      } while (--ip >= 0);
      s = _state;
    } while (s(_INIT_EVT) == null);
  }

  void Q_TRAN(QState target) {
    _state = target;
  }

  void dispatch(QEvent e) {
    QState s;
    QState t = _state;

    _path[1] = t; // save the current state in case a transition is taken
    _state = null; // make sure that a transition will be noticed

    do { // process the event hierarchically...
      s = t;
      t = s(e); // invoke state handler through pointer s
    } while (t != null);

    if (_state != null) { // transition taken?
      QState src = s; // the source of the transition
      int ip = -1; // transition entry path index
      int iq; // helper transition entry path index

      _path[0] = _state; // save the new state (target of tran.)
      _state = _path[1]; // restore the current state

      // exit current state to the transition source _path[1]...
      for (s = _path[1]; s != src;) {
        t = s(_EXIT_EVT);
        if (t != null) { // exit action unhandled
          s = t; // t points to superstate
        }
        else { // exit action handled
          s = s(_EMPTY_EVT); // find out the superstate
        }
      }

      t = _path[0];

      if (src == t) { // (a) check source==target (transition to self)
        src(_EXIT_EVT); // exit the source
        ip = 0; // enter the target
      }
      else {
        t = t(_EMPTY_EVT); // superstate of target
        if (src == t) { // (b) check source==target->super
          ip = 0; // enter the target
        }
        else {
          s = src(_EMPTY_EVT); // superstate of src
          if (s == t) { // (c) check source->super==target->super
            src(_EXIT_EVT); // exit the source
            ip = 0; // enter the target
          }
          else {
            if (s == _path[0]) { // (d) check source->super==target
              src(_EXIT_EVT); // exit the source
            }
            else { // (e) rest of source==target->super->super...
              // and store the entry path along the way

              iq = 0; // indicate that LCA not found
              ip = 1; // enter target and its superstate
              _path[1] = t; // save the superstate of target
              t = t(_EMPTY_EVT);
              while (t != null) {
                _path[++ip] = t; // store the entry path
                if (t == src) { // is it the source?
                  iq = 1; // indicate that LCA found
                  // entry path must not overflow
                  assert (ip < MAX_NEST_DEPTH);
                  --ip; // do not enter the source
                  t = null; // terminate the loop
                }
                else { // it is not the source, keep going up
                  t = t(_EMPTY_EVT);
                }
              }
              if (iq == 0) { // the LCA not found yet?

                // entry path must not overflow
                assert (ip < MAX_NEST_DEPTH);

                src(_EXIT_EVT); // exit the source

                // (f) check the rest of source->super
                //             == target->super->super...

                iq = ip;
                do {
                  if (s == _path[iq]) { // is this the LCA?
                    t = s; // indicate that LCA is found
                    ip = (iq - 1); //do not enter LCA
                    iq = -1; // terminate the loop
                  }
                  else {
                    --iq; // try lower superstate of target
                  }
                } while (iq >= 0);

                if (t == null) { // LCA not found yet?
                  // (g) check each source->super->...
                  // for each target->super...

                  do {
                    t = s(_EXIT_EVT); // exit s
                    if (t != null) { // unhandled?
                      s = t; // t points to super of s
                    }
                    else { // exit action handled
                      s = s(_EMPTY_EVT);
                    }
                    iq = ip;
                    do {
                      if (s == _path[iq]) { // is LCA?
                        // do not enter LCA
                        ip = (iq - 1);
                        iq = -1; // break inner loop
                        s = null; // break outer loop
                      }
                      else {
                        --iq;
                      }
                    } while (iq >= 0);
                  } while (s != null);
                }
              }
            }
          }
        }
      }
      // retrace the entry path in reverse (desired) order...
      for (; ip >= 0; --ip) {
        _path[ip](_ENTRY_EVT); // enter _path[ip]
      }
      s = _path[0]; // stick the target into register
      _state = s; // update the current state

      // drill into the target hierarchy...
      while (s(_INIT_EVT) == null) {
        t = _state;

        _path[0] = t;
        ip = 0;
        for (t = t(_EMPTY_EVT); t != s;
        t = t(_EMPTY_EVT)) {
          _path[++ip] = t;
        }
        assert (ip < MAX_NEST_DEPTH); // entry path must not overflow

        do { // retrace the entry path in reverse (correct) order...
          _path[ip](_ENTRY_EVT); // enter _path[ip]
        } while ((--ip) >= 0);
        s = _state;
      }
    }
    else {
      _state = _path[1]; // restore the current state
    }
  }
}
*/
