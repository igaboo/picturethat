String getCleanUrl(String url) {
  url = url.replaceFirst(RegExp(r'^(https?:\/\/)?(www\.)?'), '');
  final match = RegExp(r'^[^\/]+\/[^\/]+').firstMatch(url);
  return match != null ? match.group(0)! : url.split('/')[0];
}
