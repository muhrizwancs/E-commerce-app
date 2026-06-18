import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  static String? _authToken;

  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  static Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> _getHeaders({bool requireAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (requireAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Auth APIs
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await setAuthToken(data['token']);
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Registration failed');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await setAuthToken(data['token']);
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
    }
  }

  // Product APIs
  static Future<List<Product>> getProducts({
    String? category,
    String? search,
    String? sort,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (search != null) queryParams['search'] = search;
    if (sort != null) queryParams['sort'] = sort;

    final uri = Uri.parse('$baseUrl/products');
    final response = await http.get(
      queryParams.isEmpty ? uri : uri.replace(queryParameters: queryParams),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  static Future<Product> getProductById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch product');
    }
  }

  static Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    double? originalPrice,
    required String category,
    String? image,
    required int stock,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'category': category,
        'image': image,
        'stock': stock,
      }),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create product');
    }
  }

  static Future<Product> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    double? originalPrice,
    required String category,
    String? image,
    required int stock,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'category': category,
        'image': image,
        'stock': stock,
      }),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update product');
    }
  }

  static Future<void> deleteProduct(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to delete product');
    }
  }

  // Order APIs
  static Future<Order> createOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode({
        'items': items,
        'totalAmount': totalAmount,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
      }),
    );

    if (response.statusCode == 201) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create order');
    }
  }

  static Future<List<Order>> getUserOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Order.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch orders');
    }
  }

  static Future<List<Order>> getAllOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/admin/all'),
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Order.fromJson(item)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch all orders');
    }
  }

  static Future<Order> updateOrderStatus({
    required String id,
    required String status,
    String? trackingNumber,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$id/status'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode({
        'status': status,
        'trackingNumber': trackingNumber,
      }),
    );

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update order');
    }
  }

  static Future<Order> getOrderById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$id'),
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch order');
    }
  }
}
