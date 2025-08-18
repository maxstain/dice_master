class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profilePictureUrl,
  });

  // Factory constructor to create a User from a map
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      password: data['password'] as String,
      profilePictureUrl: data['profilePictureUrl'] as String?,
    );
  }

  // Method to convert User to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
