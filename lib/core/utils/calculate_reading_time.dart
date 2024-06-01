int calculateReadingTime(String content) {
  // calculate number of words
  final wordCount = content.split(RegExp(r'\s+')).length;
  // v = s/t
  // average reading time: 225 words(200-300) words per minute
  final readingTime = wordCount / 225;
  return readingTime.ceil();
}
