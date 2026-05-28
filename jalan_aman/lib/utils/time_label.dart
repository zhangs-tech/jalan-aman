String timeAgoLabel(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

String? expiresInLabel(DateTime expiresAt) {
  final diff = expiresAt.difference(DateTime.now());
  if (diff.isNegative) return null;
  if (diff.inHours <= 3) {
    if (diff.inMinutes < 60) return 'Expires in ${diff.inMinutes}m';
    return 'Expires in ${diff.inHours}h';
  }
  return null;
}
