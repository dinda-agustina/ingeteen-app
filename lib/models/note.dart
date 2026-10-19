class Note {
  String title;
  String content;
  String label;

  Note({
    required this.title,
    required this.content,
    this.label = 'Catatan Kuliah',
  });
}