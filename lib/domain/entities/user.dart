class User {
  final String name;
  final String id;
  final String imageUrl;
  final String email;
  final bool preferenceScreenCompleted;

  User({
    required this.name,
    required this.id,
    required this.imageUrl,
    required this.email,
    this.preferenceScreenCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'imageUrl': imageUrl,
      'email': email,
      'preferenceScreenCompleted': preferenceScreenCompleted,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      email: json['email'] ?? '',
      preferenceScreenCompleted: json['preferenceScreenCompleted'] ?? false,
    );
  }
}
