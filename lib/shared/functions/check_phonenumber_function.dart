bool isPhoneNumber(String text) {
  final cleanText = text.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  return (text.startsWith('+') && cleanText.length > 1) ||
      (RegExp(r'^\d+$').hasMatch(cleanText) && cleanText.length >= 3);
}
