import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../services/api_service.dart';

class AdminPortalScreen extends StatefulWidget {
  const AdminPortalScreen({super.key});

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  List<Order> _orders = [];
  bool _isLoadingOrders = false;
  String? _orderError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      _fetchOrders();
    });
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoadingOrders = true;
      _orderError = null;
    });

    try {
      final orders = await ApiService.getAllOrders();
      if (!mounted) return;
      setState(() => _orders = orders);
    } catch (error) {
      if (!mounted) return;
      setState(() => _orderError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoadingOrders = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _AdminSummary(orders: _orders),
            ),
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Products'),
                Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Orders'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ProductsAdminView(onChanged: _fetchOrders),
                  _OrdersAdminView(
                    orders: _orders,
                    isLoading: _isLoadingOrders,
                    error: _orderError,
                    onRefresh: _fetchOrders,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSummary extends StatelessWidget {
  final List<Order> orders;

  const _AdminSummary({required this.orders});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final revenue = orders.fold<double>(
      0,
      (total, order) => total + order.totalAmount,
    );
    final pendingOrders = orders.where((order) => order.status == 'pending').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useGrid = constraints.maxWidth > 680;
        final cards = [
          _MetricCard(
            label: 'Products',
            value: '${productProvider.products.length}',
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF2563EB),
          ),
          _MetricCard(
            label: 'Orders',
            value: '${orders.length}',
            icon: Icons.receipt_long_outlined,
            color: const Color(0xFF059669),
          ),
          _MetricCard(
            label: 'Pending',
            value: '$pendingOrders',
            icon: Icons.pending_actions_outlined,
            color: const Color(0xFFD97706),
          ),
          _MetricCard(
            label: 'Revenue',
            value: 'Rs ${revenue.toStringAsFixed(0)}',
            icon: Icons.payments_outlined,
            color: const Color(0xFF7C3AED),
          ),
        ];

        if (useGrid) {
          return Row(
            children: [
              for (final card in cards) Expanded(child: card),
            ],
          );
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: cards
              .map((card) => SizedBox(
                    width: (constraints.maxWidth - 10) / 2,
                    child: card,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsAdminView extends StatelessWidget {
  final Future<void> Function() onChanged;

  const _ProductsAdminView({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: productProvider.fetchProducts,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Catalog',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showProductForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add product'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (productProvider.errorMessage != null)
                _InlineMessage(message: productProvider.errorMessage!),
              for (final product in productProvider.products)
                _ProductAdminTile(
                  product: product,
                  onEdit: () => _showProductForm(context, product: product),
                  onDelete: () => _deleteProduct(context, product),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteProduct(BuildContext context, Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product'),
        content: Text('Delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await Provider.of<ProductProvider>(context, listen: false)
          .deleteProduct(product.id);
      await onChanged();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _showProductForm(BuildContext context, {Product? product}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _ProductFormDialog(product: product),
    );

    if (saved == true) {
      await onChanged();
    }
  }
}

class _ProductAdminTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductAdminTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: product.image == null || product.image!.isEmpty
              ? const Icon(Icons.image_outlined, color: Color(0xFF2563EB))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_outlined,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
        ),
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${product.category} • Rs ${product.price.toStringAsFixed(0)} • ${product.stock} in stock',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: 'Edit product',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete product',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  final Product? product;

  const _ProductFormDialog({this.product});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _originalPriceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _imageController;
  late final TextEditingController _stockController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(text: product?.description ?? '');
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toStringAsFixed(0),
    );
    _originalPriceController = TextEditingController(
      text: product?.originalPrice == null
          ? ''
          : product!.originalPrice!.toStringAsFixed(0),
    );
    _categoryController = TextEditingController(text: product?.category ?? '');
    _imageController = TextEditingController(text: product?.image ?? '');
    _stockController = TextEditingController(text: product?.stock.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add product' : 'Edit product'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TextInput(controller: _nameController, label: 'Name'),
                _TextInput(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 3,
                ),
                _TextInput(controller: _categoryController, label: 'Category'),
                Row(
                  children: [
                    Expanded(
                      child: _TextInput(
                        controller: _priceController,
                        label: 'Price',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TextInput(
                        controller: _originalPriceController,
                        label: 'Original price',
                        keyboardType: TextInputType.number,
                        required: false,
                      ),
                    ),
                  ],
                ),
                _TextInput(
                  controller: _stockController,
                  label: 'Stock',
                  keyboardType: TextInputType.number,
                ),
                _TextInput(
                  controller: _imageController,
                  label: 'Image URL',
                  required: false,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final originalPrice = _originalPriceController.text.trim().isEmpty
        ? null
        : double.parse(_originalPriceController.text.trim());
    final image = _imageController.text.trim().isEmpty
        ? null
        : _imageController.text.trim();

    try {
      if (widget.product == null) {
        await provider.createProduct(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          originalPrice: originalPrice,
          category: _categoryController.text.trim(),
          image: image,
          stock: int.parse(_stockController.text.trim()),
        );
      } else {
        await provider.updateProduct(
          Product(
            id: widget.product!.id,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            price: double.parse(_priceController.text.trim()),
            originalPrice: originalPrice,
            category: _categoryController.text.trim(),
            image: image,
            stock: int.parse(_stockController.text.trim()),
            rating: widget.product!.rating,
            reviews: widget.product!.reviews,
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool required;

  const _TextInput({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          if (keyboardType == TextInputType.number &&
              value != null &&
              value.trim().isNotEmpty &&
              double.tryParse(value.trim()) == null) {
            return 'Enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}

class _OrdersAdminView extends StatelessWidget {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;

  const _OrdersAdminView({
    required this.orders,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Orders',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh orders',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (error != null) _InlineMessage(message: error!),
          if (orders.isEmpty && error == null)
            const _InlineMessage(message: 'No orders yet.'),
          for (final order in orders)
            _OrderAdminTile(order: order, onChanged: onRefresh),
        ],
      ),
    );
  }
}

class _OrderAdminTile extends StatelessWidget {
  final Order order;
  final Future<void> Function() onChanged;

  const _OrderAdminTile({
    required this.order,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final customer = order.userName ?? order.userEmail ?? order.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Text(
          'Order ${order.id.length <= 8 ? order.id : order.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '$customer • ${order.items.length} items • Rs ${order.totalAmount.toStringAsFixed(0)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _StatusChip(status: order.status),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (final item in order.items)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(item.productName),
              subtitle: Text('Qty ${item.quantity}'),
              trailing: Text('Rs ${(item.price * item.quantity).toStringAsFixed(0)}'),
            ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: Text(
                  order.trackingNumber == null || order.trackingNumber!.isEmpty
                      ? 'No tracking number'
                      : 'Tracking: ${order.trackingNumber}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showStatusDialog(context),
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showStatusDialog(BuildContext context) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _OrderStatusDialog(order: order),
    );

    if (saved == true) {
      await onChanged();
    }
  }
}

class _OrderStatusDialog extends StatefulWidget {
  final Order order;

  const _OrderStatusDialog({required this.order});

  @override
  State<_OrderStatusDialog> createState() => _OrderStatusDialogState();
}

class _OrderStatusDialogState extends State<_OrderStatusDialog> {
  static const statuses = [
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  late String _status;
  late final TextEditingController _trackingController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
    _trackingController = TextEditingController(text: widget.order.trackingNumber ?? '');
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update order'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: statuses.contains(_status) ? _status : statuses.first,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: statuses
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _trackingController,
              decoration: InputDecoration(
                labelText: 'Tracking number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ApiService.updateOrderStatus(
        id: widget.order.id,
        status: _status,
        trackingNumber: _trackingController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'delivered' => const Color(0xFF059669),
      'shipped' => const Color(0xFF2563EB),
      'cancelled' => const Color(0xFFDC2626),
      'processing' => const Color(0xFFD97706),
      _ => const Color(0xFF6B7280),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;

  const _InlineMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF92400E),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
