String normalizeTitle(String title) {
  return title.replaceAll(new RegExp('</span>|<span.*">'), '');
}
