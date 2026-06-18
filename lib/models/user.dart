class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final Address? address;
  final bool isAdmin;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address?.toJson(),
    'isAdmin': isAdmin,
  };
}

class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;

  Address({
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() => {
    'street': street,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    'country': country,
  };
}
