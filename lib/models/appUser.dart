class AppUser {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
  });

  // Factory constructor to create a AppUser from a map
  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      profilePictureUrl: data['profilePictureUrl'] as String?,
    );
  }

  // Method to convert AppUser to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
