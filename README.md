<<<<<<< HEAD
# E-Commerce Application

A full-stack e-commerce application built with **Flutter** (frontend), **Node.js/Express** (backend), and **MongoDB** (database).

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  FLUTTER APP (Mobile)                    │
│  - User Auth, Products, Cart, Checkout, Order History   │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTP/REST
┌──────────────────────▼──────────────────────────────────┐
│              NODE.JS EXPRESS API (Backend)               │
│  - Auth Routes, Product Management, Order Processing    │
│  - User Management, Admin Dashboard                      │
└──────────────────────┬──────────────────────────────────┘
                       │ Mongoose
┌──────────────────────▼──────────────────────────────────┐
│                  MONGODB (Database)                      │
│  - Users, Products, Orders, Reviews                     │
└─────────────────────────────────────────────────────────┘
```

## Quick Start

### Backend Setup

1. Navigate to backend folder:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Configure `.env` file with MongoDB URI:
```
MONGODB_URI=mongodb://localhost:27017/ecommerce
PORT=5000
JWT_SECRET=your_secret_key
```

4. Start development server:
```bash
npm run dev
```

Backend runs on `http://localhost:5000`

### Frontend Setup

1. Navigate to project root:
```bash
cd ..
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Update API URL in `lib/services/api_service.dart` if needed

4. Run the app:
```bash
flutter run
```

## Project Structure

```
e_commerce/
├── backend/
│   ├── src/
│   │   ├── config/          # Database config
│   │   ├── controllers/     # API logic
│   │   ├── models/          # MongoDB schemas
│   │   ├── middlewares/     # Auth, validation
│   │   ├── routes/          # API endpoints
│   │   └── server.js        # Main server file
│   ├── .env                 # Environment variables
│   ├── package.json         # Node dependencies
│   └── README.md            # Backend documentation
│
├── lib/                     # Flutter app code
│   ├── models/              # Data models
│   ├── providers/           # State management
│   ├── services/            # API communication
│   ├── screens/             # UI screens
│   ├── widgets/             # Reusable components
│   └── main.dart            # App entry point
│
├── pubspec.yaml             # Flutter dependencies
├── FLUTTER_README.md        # Flutter setup guide
└── README.md                # This file
```

## Technologies

### Backend
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT tokens + bcryptjs
- **Validation**: express-validator
- **File Upload**: multer

### Frontend
- **Framework**: Flutter
- **State Management**: Provider
- **HTTP Client**: http package
- **Local Storage**: shared_preferences
- **UI**: Material Design

## Core Features

### 1. Authentication
- User registration with password hashing
- JWT-based login
- Secure token storage on device

### 2. Product Management
- Browse all products
- Search and filter by category
- Product details with reviews
- Price sorting

### 3. Shopping Cart
- Add/remove products
- Update quantities
- Calculate totals

### 4. Checkout & Orders
- Create orders from cart
- Shipping address entry
- Order status tracking
- Payment method selection

### 5. Admin Dashboard
- View all orders
- Update order status
- Add tracking numbers
- Manage product inventory

### 6. User Accounts
- User profile management
- Order history
- Address management
- Review products

## API Endpoints

### Auth
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login

### Products
- `GET /api/products` - List all products
- `GET /api/products?category=electronics` - Filter by category
- `GET /api/products/:id` - Get product details
- `POST /api/products/:id/reviews` - Add review (auth required)
- `POST /api/products` - Create product (admin)
- `PUT /api/products/:id` - Update product (admin)
- `DELETE /api/products/:id` - Delete product (admin)

### Orders
- `POST /api/orders` - Create order (auth required)
- `GET /api/orders` - Get user's orders (auth required)
- `GET /api/orders/:id` - Get order details (auth required)
- `GET /api/orders/admin/all` - Get all orders (admin)
- `PUT /api/orders/:id/status` - Update order status (admin)

## Data Models

### User
```javascript
{
  name: String,
  email: String,
  password: String (hashed),
  phone: String,
  address: { street, city, state, zipCode, country },
  isAdmin: Boolean
}
```

### Product
```javascript
{
  name: String,
  description: String,
  price: Number,
  originalPrice: Number,
  category: String,
  image: String,
  stock: Number,
  rating: Number,
  reviews: [{ userId, userName, rating, comment }]
}
```

### Order
```javascript
{
  userId: ObjectId,
  items: [{ productId, productName, price, quantity }],
  totalAmount: Number,
  shippingAddress: { street, city, state, zipCode, country },
  status: String (pending, processing, shipped, delivered),
  paymentStatus: String (unpaid, paid, failed),
  paymentMethod: String,
  trackingNumber: String
}
```

## Database Setup

### Local MongoDB

1. Install MongoDB from [mongodb.com](https://www.mongodb.com)

2. Start MongoDB service

3. Create database:
```bash
mongosh
use ecommerce
```

### MongoDB Atlas (Cloud)

1. Create account at [mongodb.com/cloud](https://mongodb.com/cloud)
2. Create cluster and database
3. Update `.env`:
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/ecommerce
```

## Development Workflow

1. **Start Backend**:
```bash
cd backend
npm run dev
```

2. **Start Flutter App** (in new terminal):
```bash
flutter run
```

3. **Hot Reload**: Press `r` during app run to reload changes

## Testing

### Backend
```bash
# Add test script to package.json and run
npm test
```

### Flutter
```bash
# Run tests
flutter test
```

## Deployment

### Backend (Node.js)
- Deploy to Heroku, Railway, or AWS EC2
- Update MongoDB URI for production
- Set secure JWT_SECRET

### Frontend (Flutter)
- Build Android APK: `flutter build apk --release`
- Build iOS app: `flutter build ios --release`
- Upload to Play Store/App Store

## Security Considerations

- ✅ Passwords hashed with bcryptjs
- ✅ JWT tokens for authentication
- ✅ CORS enabled for secure API access
- ✅ Environment variables for sensitive data
- ⚠️ TODO: Add rate limiting
- ⚠️ TODO: Implement HTTPS in production
- ⚠️ TODO: Add input validation on frontend

## Future Enhancements

- [ ] Payment gateway integration (Stripe, PayPal)
- [ ] Email notifications
- [ ] Real-time order tracking with WebSockets
- [ ] Wishlists
- [ ] Product recommendations
- [ ] Inventory management system
- [ ] Analytics dashboard
- [ ] Mobile app notifications

## Troubleshooting

### Backend won't start?
```bash
# Check MongoDB is running
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
npm run dev
```

### Can't connect to API?
- Ensure backend is running on port 5000
- Check firewall settings
- Update API URL in Flutter app

### Database connection error?
- Verify MongoDB is running
- Check MONGODB_URI in .env
- Ensure database exists

## Support & Contributions

For issues or contributions, please create an issue or pull request.

## License

MIT License - feel free to use for personal and commercial projects.
=======
# E-commerce-app
>>>>>>> e2ddf8cc181dbb4cebdc609eb7472d2c90987c7c
