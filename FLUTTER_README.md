# E-Commerce Flutter App

A complete Flutter e-commerce application with user authentication, product catalog, shopping cart, and order management.

## Features

- ✅ User Registration & Login
- ✅ Product Browsing & Search
- ✅ Category Filtering
- ✅ Shopping Cart Management
- ✅ Order Creation & Tracking
- ✅ User Profile Management
- ✅ Admin Dashboard (order management)
- ✅ Reviews & Ratings

## Prerequisites

- Flutter (v3.0+)
- Dart (v3.0+)
- Android Studio / Xcode
- MongoDB instance running
- Node.js backend running on `http://localhost:5000`

## Installation

1. Navigate to the project directory:
```bash
cd e_commerce
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update API base URL in `lib/services/api_service.dart` if needed:
```dart
static const String baseUrl = 'http://your-api-url:5000/api';
```

For Android Emulator, use:
```
http://10.0.2.2:5000/api
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── models/
│   ├── user.dart           # User model
│   ├── product.dart        # Product model
│   └── order.dart          # Order model
├── providers/
│   ├── auth_provider.dart      # Authentication provider
│   ├── product_provider.dart   # Product management provider
│   └── cart_provider.dart      # Shopping cart provider
├── services/
│   └── api_service.dart    # API communication service
├── screens/                # UI screens
├── widgets/                # Reusable widgets
└── main.dart              # App entry point
```

## API Integration

The app communicates with the Node.js backend via REST APIs. Ensure the backend is running before starting the app.

### Key API Endpoints Used

- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/products` - Fetch products
- `GET /api/products/:id` - Fetch product details
- `POST /api/orders` - Create order

## State Management

The app uses **Provider** package for state management:

- `AuthProvider` - Manages user authentication
- `ProductProvider` - Manages product data
- `CartProvider` - Manages shopping cart

## Local Storage

- Uses `shared_preferences` to store JWT tokens locally
- Tokens are automatically loaded on app startup

## Next Steps

1. Create UI screens (Home, Product Detail, Cart, Checkout, Orders)
2. Implement payment gateway integration
3. Add image upload functionality
4. Create admin dashboard screens
5. Implement notifications

## Troubleshooting

### Can't connect to backend?
- Ensure Node.js backend is running on port 5000
- Check API_BASE_URL in `api_service.dart`
- For emulator, use `10.0.2.2` instead of `localhost`

### Packages not installing?
```bash
flutter pub cache clean
flutter pub get
```

### Build issues?
```bash
flutter clean
flutter pub get
flutter run
```

## Dependencies

- **http** - REST API communication
- **provider** - State management
- **shared_preferences** - Local storage
- **intl** - Localization & formatting
- **cached_network_image** - Image caching
- **shimmer** - Loading animations

## License

MIT
