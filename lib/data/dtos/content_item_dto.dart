class ContentItemDto {
  final int id;
  final String title;
  final String type;
  final String createdAt;

  ContentItemDto({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
  });

  factory ContentItemDto.fromJson(Map<String, dynamic> json) {
    return ContentItemDto(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      createdAt: json['created_at'],
    );
  }
}
