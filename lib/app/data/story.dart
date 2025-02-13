class Story {
  String? title;
  String? imageUrl;
  String? link;
  String? category;

  Story({
    this.title,
    this.imageUrl,
    this.link,
    this.category,
  });

  factory Story.fromMap(Map<dynamic, dynamic> json) {
    return Story(
      title: json['title'],
      imageUrl: json['imageUrl'],
      link: json['link'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'link': link,
      'category': category,
    };
  }
}
