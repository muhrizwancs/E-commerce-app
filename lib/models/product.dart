class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final String? image;
  final List<String>? images;
  final int stock;
  final double rating;
  final List<Review>? reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    this.image,
    this.images,
    required this.stock,
    this.rating = 0,
    this.reviews,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      category: json['category'] ?? '',
      image: json['image'],
      images: List<String>.from(json['images'] ?? []),
      stock: json['stock'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: json['reviews'] != null
          ? List<Review>.from(json['reviews'].map((x) => Review.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id.isNotEmpty) '_id': id,
    'name': name,
    'description': description,
    'price': price,
    'originalPrice': originalPrice,
    'category': category,
    'image': image,
    'images': images,
    'stock': stock,
    'rating': rating,
  };
}

class Review {
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }
}
