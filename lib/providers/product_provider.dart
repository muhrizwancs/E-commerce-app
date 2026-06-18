import 'package:flutter/foundation.dart';
import '../data/demo_products.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;
  bool _isShowingDemoProducts = false;
  bool _hasActiveFilter = false;

  List<Product> get products => _hasActiveFilter ? _filteredProducts : _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isShowingDemoProducts => _isShowingDemoProducts;
  String? get selectedCategory => _selectedCategory;
  List<String> get categories => _products
      .map((p) => p.category)
      .toSet()
      .toList();

  Future<void> fetchProducts({
    String? category,
    String? search,
    String? sort,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await ApiService.getProducts(
        category: category,
        search: search,
        sort: sort,
      );
      if (_products.isEmpty) {
        _products = List<Product>.from(demoProducts);
        _isShowingDemoProducts = true;
      } else {
        _isShowingDemoProducts = false;
      }
      _selectedCategory = category;
      _hasActiveFilter = false;
      _filteredProducts = [];
      _errorMessage = null;
    } catch (error) {
      _products = List<Product>.from(demoProducts);
      _isShowingDemoProducts = true;
      _hasActiveFilter = false;
      _filteredProducts = [];
      _errorMessage = 'Showing sample products because the store API is unavailable.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getProductById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final localMatches = _products.where((product) => product.id == id);
      final localProduct = localMatches.isEmpty ? null : localMatches.first;
      if (localProduct != null) {
        _selectedProduct = localProduct;
        return;
      }

      _selectedProduct = await ApiService.getProductById(id);
      _errorMessage = null;
    } catch (error) {
      final demoMatches = demoProducts.where((product) => product.id == id);
      _selectedProduct = demoMatches.isEmpty ? null : demoMatches.first;
      _errorMessage = _selectedProduct == null ? error.toString() : null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectProduct(Product product) {
    _selectedProduct = product;
    notifyListeners();
  }

  Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    double? originalPrice,
    required String category,
    String? image,
    required int stock,
  }) async {
    final product = await ApiService.createProduct(
      name: name,
      description: description,
      price: price,
      originalPrice: originalPrice,
      category: category,
      image: image,
      stock: stock,
    );
    _products.insert(0, product);
    _isShowingDemoProducts = false;
    _hasActiveFilter = false;
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final updatedProduct = await ApiService.updateProduct(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      originalPrice: product.originalPrice,
      category: product.category,
      image: product.image,
      stock: product.stock,
    );
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index != -1) {
      _products[index] = updatedProduct;
    }
    if (_selectedProduct?.id == product.id) {
      _selectedProduct = updatedProduct;
    }
    _hasActiveFilter = false;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await ApiService.deleteProduct(id);
    _products.removeWhere((product) => product.id == id);
    _filteredProducts.removeWhere((product) => product.id == id);
    if (_selectedProduct?.id == id) {
      _selectedProduct = null;
    }
    notifyListeners();
  }

  void filterByCategory(String category) {
    if (category.isEmpty) {
      _filteredProducts = [];
      _hasActiveFilter = false;
    } else {
      _filteredProducts = _products
          .where((product) => product.category == category)
          .toList();
      _hasActiveFilter = true;
    }
    _selectedCategory = category;
    notifyListeners();
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = [];
      _hasActiveFilter = _selectedCategory != null && _selectedCategory!.isNotEmpty;
      if (_hasActiveFilter) {
        _filteredProducts = _products
            .where((product) => product.category == _selectedCategory)
            .toList();
      }
    } else {
      final normalizedQuery = query.toLowerCase();
      _filteredProducts = _products.where((product) {
        final matchesCategory = _selectedCategory == null ||
            _selectedCategory!.isEmpty ||
            product.category == _selectedCategory;
        final matchesQuery =
            product.name.toLowerCase().contains(normalizedQuery) ||
                product.description.toLowerCase().contains(normalizedQuery);
        return matchesCategory && matchesQuery;
      }).toList();
      _hasActiveFilter = true;
    }
    notifyListeners();
  }
}
