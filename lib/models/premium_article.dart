class PremiumArticle {
  final String id;
  final String title;
  final String author;
  final String date;
  final String introduction;
  final String conclusion;
  final List<ArticleSection> sections;
  final List<String> references;
  final String topic;
  final String? imageUrl;
  
  const PremiumArticle({
    required this.id,
    required this.title,
    required this.author,
    required this.date,
    required this.introduction,
    required this.conclusion,
    required this.sections,
    required this.topic,
    this.references = const [],
    this.imageUrl,
  });
  
  factory PremiumArticle.fromJson(Map<String, dynamic> json) {
    return PremiumArticle(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      date: json['date'],
      introduction: json['introduction'],
      conclusion: json['conclusion'],
      sections: (json['sections'] as List)
          .map((section) => ArticleSection.fromJson(section))
          .toList(),
      references: (json['references'] as List?)
          ?.map((ref) => ref.toString())
          .toList() ?? [],
      topic: json['topic'],
      imageUrl: json['image_url'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'date': date,
      'introduction': introduction,
      'conclusion': conclusion,
      'sections': sections.map((section) => section.toJson()).toList(),
      'references': references,
      'topic': topic,
      'image_url': imageUrl,
    };
  }
}

class ArticleSection {
  final String heading;
  final String content;
  final String? imageUrl;
  
  const ArticleSection({
    required this.heading,
    required this.content,
    this.imageUrl,
  });
  
  factory ArticleSection.fromJson(Map<String, dynamic> json) {
    return ArticleSection(
      heading: json['heading'],
      content: json['content'],
      imageUrl: json['image_url'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'content': content,
      'image_url': imageUrl,
    };
  }
}