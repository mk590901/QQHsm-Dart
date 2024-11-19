
class QEvent {
  int _sig = 0;
  int? _ticket = 0;

  QEvent(this._sig, [this._ticket]);

  int get sig => _sig;
  int? get ticket => _ticket;

  set sig(int pSig) {
    _sig = pSig;
  }

  set ticket(int? pTicket) {
    _ticket = pTicket;
  }
}
