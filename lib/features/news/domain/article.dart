class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String source;
  final String url;
  final String categoryId;
  final String? imageUrl;
  final String? publishedAt;

  const Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.source,
    required this.url,
    required this.categoryId,
    this.imageUrl,
    this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      source: json['source'] ?? '',
      url: json['url'] ?? '',
      categoryId: json['category_id'] ?? '',
      imageUrl: json['image_url'],
      publishedAt: json['published_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'source': source,
      'url': url,
      'category_id': categoryId,
      'image_url': imageUrl,
      'published_at': publishedAt,
    };
  }
}
