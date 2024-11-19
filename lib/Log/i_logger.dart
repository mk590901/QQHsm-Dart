abstract class ILogger {
  void            trace     (String string);
  void            printTrace();
  @override
  String          toString  ();
  String          toTrace   ();
  void            clear     (String label);
}
