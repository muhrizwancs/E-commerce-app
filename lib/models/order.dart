class Order {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final List<OrderItem> items;
  final double totalAmount;
  final Address shippingAddress;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String? trackingNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    this.status = 'pending',
    this.paymentStatus = 'unpaid',
    this.paymentMethod,
    this.trackingNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final userValue = json['userId'];
    final parsedUserId = userValue is Map<String, dynamic>
        ? userValue['_id'] ?? ''
        : userValue ?? '';

    return Order(
      id: json['_id'] ?? '',
      userId: parsedUserId,
      userName: userValue is Map<String, dynamic> ? userValue['name'] : null,
      userEmail: userValue is Map<String, dynamic> ? userValue['email'] : null,
      items: List<OrderItem>.from(
        json['items']?.map((x) => OrderItem.fromJson(x)) ?? [],
      ),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      shippingAddress: Address.fromJson(json['shippingAddress'] ?? {}),
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'unpaid',
      paymentMethod: json['paymentMethod'],
      trackingNumber: json['trackingNumber'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((x) => x.toJson()).toList(),
    'totalAmount': totalAmount,
    'shippingAddress': shippingAddress.toJson(),
    'paymentMethod': paymentMethod,
  };
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? image;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'price': price,
    'quantity': quantity,
    'image': image,
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
