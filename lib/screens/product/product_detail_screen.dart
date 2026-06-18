import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        elevation: 0,
      ),
      bottomNavigationBar: Consumer2<ProductProvider, CartProvider>(
        builder: (context, productProvider, cartProvider, _) {
          final selectedProduct = productProvider.selectedProduct;
          final product = selectedProduct?.id == productId ? selectedProduct : null;

          if (product == null) {
            return const SizedBox.shrink();
          }

          final isInCart = cartProvider.isProductInCart(product.id);

          return SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: product.stock > 0
                          ? () {
                              cartProvider.addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} added to cart'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(isInCart ? 'In Cart' : 'Add to Cart'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: product.stock > 0
                          ? () {
                              cartProvider.addToCart(product);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartScreen(),
                                ),
                              );
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          final selectedProduct = productProvider.selectedProduct;
          final product = selectedProduct?.id == productId ? selectedProduct : null;

          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (product == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              productProvider.getProductById(productId);
            });
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 320,
                    width: double.infinity,
                    color: const Color(0xFFEFF6FF),
                    child: product.image != null
                        ? Image.network(
                            product.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const _DetailImageFallback();
                            },
                          )
                        : const _DetailImageFallback(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFF59E0B), size: 20),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: product.stock > 0
                            ? const Color(0xFFE7F8EF)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.stock > 0 ? '${product.stock} in stock' : 'Sold out',
                        style: TextStyle(
                          color: product.stock > 0
                              ? const Color(0xFF047857)
                              : const Color(0xFFB91C1C),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Rs ${product.price.toStringAsFixed(0)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (product.originalPrice != null)
                      Flexible(
                        child: Text(
                          'Rs ${product.originalPrice!.toStringAsFixed(0)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFF9CA3AF),
                            fontSize: 18,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Description',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 88),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailImageFallback extends StatelessWidget {
  const _DetailImageFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        color: Color(0xFF60A5FA),
        size: 80,
      ),
    );
  }
}
