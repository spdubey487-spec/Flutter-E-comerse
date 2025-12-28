import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart'; // For formatting currency

// ========== DATA MODELS ==========
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.quantity = 0,
  });
}

// ========== STATE MANAGEMENT (Cart) ==========
class CartProvider extends ChangeNotifier {
  final List<Product> _cartItems = [];

  List<Product> get items => _cartItems;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _cartItems.fold(
      0.0, (sum, item) => sum + (item.price * item.quantity));

  void addToCart(Product product) {
    final index = _cartItems.indexWhere((item) => item.id == product.id);
    if (index != -1) {
      _cartItems[index].quantity++;
    } else {
      _cartItems.add(Product(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: 1,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    final index = _cartItems.indexWhere((item) => item.id == productId);
    if (index != -1) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

// ========== MAIN APP WIDGET ==========
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const QuickFoodApp(),
    ),
  );
}

class QuickFoodApp extends StatelessWidget {
  const QuickFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Food Delivery',
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const ProductListScreen(),
    );
  }
}

// ========== PRODUCT LIST SCREEN ==========
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Fresh Veg Pizza',
      description: 'Loaded with fresh vegetables and cheese',
      price: 12.99,
      imageUrl:
          'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?w=400',
    ),
    Product(
      id: '2',
      name: 'Avocado Salad Bowl',
      description: 'Healthy bowl with avocado, greens, and seeds',
      price: 9.50,
      imageUrl:
          'https://images.unsplash.com/photo-1540420828642-fca2c5c18abe?w-400',
    ),
    Product(
      id: '3',
      name: 'Organic Grocery Pack',
      description: 'Weekly essentials: milk, eggs, bread, fruits',
      price: 24.75,
      imageUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w-400',
    ),
    Product(
      id: '4',
      name: 'Chicken Burger Meal',
      description: 'Burger with fries and a soft drink',
      price: 14.25,
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w-400',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Food Delivery'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 8,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cart.totalItems.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ProductCard(product: product);
        },
      ),
    );
  }
}

// ========== PRODUCT CARD WIDGET ==========
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  Future<ImageProvider> _getImage() async {
    try {
      final response = await http.get(Uri.parse(product.imageUrl));
      if (response.statusCode == 200) {
        return MemoryImage(response.bodyBytes);
      }
    } catch (e) {
      // If network image fails, use asset placeholder
    }
    return const AssetImage('assets/food_default.png');
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            FutureBuilder<ImageProvider>(
              future: _getImage(),
              builder: (context, snapshot) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: snapshot.data ??
                          const AssetImage('assets/food_default.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormat.format(product.price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          cart.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${product.name} to cart'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
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

// ========== CART SCREEN ==========
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Remove all items from your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          cart.clearCart();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: NetworkImage(item.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Text(currencyFormat.format(item.price)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => cart.removeFromCart(item.id),
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => cart.addToCart(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Checkout Summary
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Items:', style: TextStyle(fontSize: 16)),
                          Text('${cart.totalItems}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Price:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            currencyFormat.format(cart.totalPrice),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Order Placed!'),
                                content: Text(
                                    'Your order of ${currencyFormat.format(cart.totalPrice)} has been confirmed.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      cart.clearCart();
                                      Navigator.popUntil(context, (route) => route.isFirst);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(fontSize: 16),
                          ),
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
