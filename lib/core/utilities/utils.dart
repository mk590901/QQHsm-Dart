bool isEmpty(String? text) {
  return text == null || text.isEmpty;
}

String createKey(String s, String t) {
  return '$s.$t';
}
