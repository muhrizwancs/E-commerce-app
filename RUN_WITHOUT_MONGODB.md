# Run App WITHOUT Installing MongoDB

## Option 1: MongoDB Atlas (Cloud) ⭐ EASIEST

No local MongoDB needed! Use free cloud database.

### Steps:

1. **Go to MongoDB Atlas**: https://www.mongodb.com/cloud/atlas

2. **Create Free Account**
   - Sign up with Google or Email
   - Verify email

3. **Create a Cluster**
   - Click "Build a Database"
   - Select "Free" (M0 Sandbox) tier
   - Choose region close to you
   - Click "Create Deployment"

4. **Create Database User**
   - Username: `ecommerceuser`
   - Password: Generate strong password
   - Click "Create User"

5. **Allow Network Access**
   - Click "Add IP Address"
   - Select "Allow Access from Anywhere" (0.0.0.0/0)
   - Click "Confirm"

6. **Get Connection String**
   - Click "Connect"
   - Select "Drivers"
   - Copy the connection string:
   ```
   mongodb+srv://ecommerceuser:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/ecommerce?retryWrites=true&w=majority
   ```

7. **Update `.env` file in backend:**
   ```
   MONGODB_URI=mongodb+srv://ecommerceuser:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/ecommerce?retryWrites=true&w=majority
   PORT=5000
   NODE_ENV=development
   JWT_SECRET=your_jwt_secret_key
   ```

8. **Run Backend** (no MongoDB service needed!)
   ```bash
   cd backend
   npm install
   npm run dev
   ```

9. **Run Flutter App**
   ```bash
   flutter pub get
   flutter run
   ```

✅ Done! Database is in the cloud, nothing to install locally.

---

## Option 2: Docker (One Command - No MongoDB Install)

If you have **Docker Desktop** installed:

```bash
# Start MongoDB in a container (no installation needed)
docker run -d -p 27017:27017 --name mongodb mongo

# Then run backend
cd backend
npm install
npm run dev

# In another terminal, run Flutter
flutter run
```

When done, stop MongoDB:
```bash
docker stop mongodb
docker rm mongodb
```

---

## Option 3: In-Memory Mock Database (Testing Only)

For quick testing without any database:

### 3.1 Create Mock Database Service

Create file: `backend/src/mockDB.js`

```javascript
// Simple in-memory mock database
class MockDB {
  constructor() {
    this.products = [
      {
        _id: '1',
        name: 'Nike Shoes',
        description: 'Comfortable sports shoes',
        price: 5000,
        originalPrice: 7000,
        category: 'Footwear',
        image: 'https://via.placeholder.com/400',
        stock: 50,
        rating: 4.5,
        reviews: []
      },
      {
        _id: '2',
        name: 'Samsung Phone',
        description: 'Latest smartphone',
        price: 30000,
        originalPrice: 40000,
        category: 'Electronics',
        image: 'https://via.placeholder.com/400',
        stock: 20,
        rating: 4.8,
        reviews: []
      },
      {
        _id: '3',
        name: 'Cotton T-Shirt',
        description: 'Comfortable cotton shirt',
        price: 500,
        originalPrice: 800,
        category: 'Clothing',
        image: 'https://via.placeholder.com/400',
        stock: 100,
        rating: 4.2,
        reviews: []
      }
    ];
    this.users = [];
    this.orders = [];
  }

  // Products
  findProduct(id) {
    return this.products.find(p => p._id === id);
  }

  getAllProducts(filter = {}) {
    let result = [...this.products];
    
    if (filter.category) {
      result = result.filter(p => p.category === filter.category);
    }
    if (filter.search) {
      const search = filter.search.toLowerCase();
      result = result.filter(p => 
        p.name.toLowerCase().includes(search) ||
        p.description.toLowerCase().includes(search)
      );
    }
    
    return result;
  }

  addProduct(product) {
    product._id = Date.now().toString();
    this.products.push(product);
    return product;
  }

  // Users
  findUser(email) {
    return this.users.find(u => u.email === email);
  }

  addUser(user) {
    user._id = Date.now().toString();
    this.users.push(user);
    return user;
  }

  // Orders
  addOrder(order) {
    order._id = Date.now().toString();
    this.orders.push(order);
    return order;
  }

  getUserOrders(userId) {
    return this.orders.filter(o => o.userId === userId);
  }

  getAllOrders() {
    return this.orders;
  }
}

module.exports = new MockDB();
```

### 3.2 Update Backend Server

Edit `backend/src/server.js` - change:

```javascript
// BEFORE:
const connectDB = require('./config/database');
connectDB();

// AFTER:
// Skip MongoDB and use mock DB instead
console.log('Using in-memory mock database (no MongoDB)');
```

### 3.3 Update Controllers

Edit `backend/src/controllers/productController.js`:

```javascript
// Replace MongoDB calls with mock DB
const mockDB = require('../mockDB');

exports.getAllProducts = async (req, res) => {
  try {
    const { category, search, sort } = req.query;
    let products = mockDB.getAllProducts({ category, search });
    
    if (sort === 'price-asc') {
      products = products.sort((a, b) => a.price - b.price);
    }
    if (sort === 'price-desc') {
      products = products.sort((a, b) => b.price - a.price);
    }
    
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getProductById = async (req, res) => {
  try {
    const product = mockDB.findProduct(req.params.id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    res.json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
```

### 3.4 Run Backend

```bash
cd backend
npm install
npm run dev
```

✅ Will show: `Server running on port 5000` (no MongoDB needed)

---

## Comparison

| Method | Setup Time | Cost | Persistence | Best For |
|--------|-----------|------|-------------|----------|
| **MongoDB Atlas** | 5 min | Free | ✅ Cloud | Production, learning |
| **Docker** | 2 min | Free | ✅ Local | Development |
| **Mock DB** | 2 min | Free | ❌ RAM only | Testing, prototyping |

---

## ⭐ RECOMMENDED: Use MongoDB Atlas

**Why?**
- ✅ No local installation
- ✅ Free tier (512MB storage)
- ✅ Auto backups
- ✅ Production-ready
- ✅ Easy to upgrade later

**Quick Setup**: 5 minutes max!

---

## Troubleshooting

### ❌ "Connection refused" with Atlas?
- Check username/password in connection string
- Verify IP is whitelisted (0.0.0.0/0 or your IP)
- Check internet connection

### ❌ "Out of space" error (Mock DB)?
- Mock DB only stores in RAM
- For persistent storage, use Atlas or Docker

### ❌ "Port already in use"?
```bash
# Kill process on port 5000
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

---

## Final Command (with MongoDB Atlas)

```bash
# Terminal 1: Start Backend (no MongoDB needed!)
cd backend
npm install
npm run dev

# Terminal 2: Start Flutter
flutter pub get
flutter run
```

That's it! No MongoDB installation needed! 🚀
