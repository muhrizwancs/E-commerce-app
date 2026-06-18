# E-Commerce Backend API

Node.js REST API for the E-Commerce application with MongoDB.

## Setup

### Prerequisites
- Node.js (v14+)
- MongoDB (local or Atlas)
- npm or yarn

### Installation

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables in `.env`:
```
MONGODB_URI=mongodb://localhost:27017/ecommerce
PORT=5000
NODE_ENV=development
JWT_SECRET=your_jwt_secret_key_here
```

4. Start development server:
```bash
npm run dev
```

Server will run on `http://localhost:5000`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Products
- `GET /api/products` - Get all products (with filters)
- `GET /api/products/:id` - Get product details
- `POST /api/products` - Create product (admin only)
- `PUT /api/products/:id` - Update product (admin only)
- `DELETE /api/products/:id` - Delete product (admin only)
- `POST /api/products/:id/reviews` - Add product review

### Orders
- `POST /api/orders` - Create order
- `GET /api/orders` - Get user orders
- `GET /api/orders/:id` - Get order details
- `GET /api/orders/admin/all` - Get all orders (admin only)
- `PUT /api/orders/:id/status` - Update order status (admin only)

## Project Structure

```
backend/
├── src/
│   ├── config/        # Database configuration
│   ├── controllers/   # Request handlers
│   ├── middlewares/   # Authentication & validation
│   ├── models/        # MongoDB schemas
│   ├── routes/        # API routes
│   └── server.js      # Main application file
├── .env               # Environment variables
└── package.json       # Dependencies
```

## Technologies

- Express.js - REST API framework
- MongoDB - NoSQL database
- Mongoose - MongoDB ODM
- JWT - Authentication
- bcryptjs - Password hashing

## Next Steps

1. Set up Flutter frontend
2. Configure Flutter API client to connect to this backend
3. Set up payment gateway integration
4. Implement image upload functionality
