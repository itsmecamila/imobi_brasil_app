/// The signed-in user.
class User {
  const User({required this.name, required this.email});

  /// Translates the API keys (Portuguese) into the model, like [Property].
  factory User.fromJson(Map<String, dynamic> json) =>
      User(name: json['nome'] as String, email: json['email'] as String);

  final String name;
  final String email;
}
