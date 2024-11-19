abstract class IUpdater {
  void  transition (String state, String event);
  void  trace(String event, String? log);
}