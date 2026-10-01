enum PropertyType {
  sale,
  rent;

  /// Translates the API value (`"venda"` / `"aluguel"`) into the enum.
  static PropertyType fromJson(String value) => switch (value) {
    'venda' => sale,
    'aluguel' => rent,
    _ => throw FormatException('Unknown property type: "$value"'),
  };

  String toJson() => switch (this) {
    sale => 'venda',
    rent => 'aluguel',
  };
}

/// A real estate listing.
///
/// Field names are in English; the API keys (in Portuguese) are translated
/// only here, in [Property.fromJson].
class Property {
  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    required this.city,
    required this.neighborhood,
    required this.bedrooms,
    required this.bathrooms,
    required this.parkingSpaces,
    required this.area,
    required this.photoUrl,
  });

  final int id;
  final String title;
  final String description;
  final PropertyType type;
  final double price;
  final String city;
  final String neighborhood;
  final int bedrooms;
  final int bathrooms;
  final int parkingSpaces;

  /// Area in square meters.
  final double area;
  final String photoUrl;

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as int,
      title: json['titulo'] as String,
      description: json['descricao'] as String,
      type: PropertyType.fromJson(json['tipo'] as String),
      // JSON numbers may arrive as int (65) or double (65.5): read as num.
      price: (json['preco'] as num).toDouble(),
      city: json['cidade'] as String,
      neighborhood: json['bairro'] as String,
      bedrooms: json['quartos'] as int,
      bathrooms: json['banheiros'] as int,
      parkingSpaces: json['vagas'] as int,
      area: (json['area_m2'] as num).toDouble(),
      photoUrl: json['foto'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': title,
    'descricao': description,
    'tipo': type.toJson(),
    'preco': price,
    'cidade': city,
    'bairro': neighborhood,
    'quartos': bedrooms,
    'banheiros': bathrooms,
    'vagas': parkingSpaces,
    'area_m2': area,
    'foto': photoUrl,
  };
}
