# Complete Setup & Run Guide

## Prerequisites

Make sure you have installed:
- **Node.js** (v14+) - [Download](https://nodejs.org/)
- **MongoDB** - [Download](https://www.mongodb.com/try/download/community)
- **Flutter** (v3.0+) - [Download](https://flutter.dev/docs/get-started/install)
- **Git** (optional) - [Download](https://git-scm.com/)

### Verify Installations

```bash
# Check Node.js version
node --version
npm --version

# Check MongoDB version
mongosh --version

# Check Flutter version
flutter --version
```

---

## Step 1: Setup & Start MongoDB

### Option A: Local MongoDB (Windows)

1. **Install MongoDB Community Edition**
   - Download from https://www.mongodb.com/try/download/community
   - Run installer and complete installation
   - MongoDB will be installed as a service

2. **Start MongoDB Service**
   ```bash
   # Open Command Prompt/PowerShell as Administrator
   net start MongoDB
   ```

3. **Verify MongoDB is running**
   ```bash
   mongosh
   ```
   You should see a connection prompt. Type `exit` to close.

### Option B: MongoDB Atlas (Cloud - Recommended for Learning)

1. **Go to MongoDB Atlas**: https://www.mongodb.com/cloud/atlas
2. **Create a Free Account** and sign in
3. **Create a Cluster** (M0 Free Tier)
4. **Get Connection String**:
   - Click "Connect" → "Drivers"
   - Copy the connection string: `mongodb+srv://username:password@cluster.mongodb.net/ecommerce?retryWrites=true&w=majority`
5. **Skip to Backend Setup** with this URI

---

## Step 2: Setup & Start Backend (Node.js)

### 2.1 Navigate to Backend Directory

```bash
cd "c:\Users\samsung\OneDrive\Desktop\E-Commerce App\e_commerce\backend"
```

### 2.2 Install Dependencies

```bash
npm install
```

This installs all packages from `package.json`:
- express
- mongoose
- cors
- dotenv
- bcryptjs
- jsonwebtoken
- etc.

**Expected output**: "added XX packages"

### 2.3 Configure Environment Variables

Edit `.env` file:

```
MONGODB_URI=mongodb://localhost:27017/ecommerce
PORT=5000
NODE_ENV=development
JWT_SECRET=your_jwt_secret_key_change_this_in_production
```

**For MongoDB Atlas**, replace `MONGODB_URI`:
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/ecommerce?retryWrites=true&w=majority
```

### 2.4 Start Backend Server

```bash
npm run dev
```

**Expected output**:
```
Server running on port 5000
MongoDB Connected: localhost
```

✅ Backend is ready! Keep this terminal open.

---

## Step 3: Setup & Run Flutter App

### 3.1 Open New Terminal/Command Prompt

### 3.2 Navigate to Project Root

```bash
cd "c:\Users\samsung\OneDrive\Desktop\E-Commerce App\e_commerce"
```

### 3.3 Install Flutter Dependencies

```bash
flutter pub get
```

**Expected output**: "Got dependencies"

### 3.4 Update API URL (if needed)

Edit `lib/services/api_service.dart`:

**For Local Backend**:
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

**For Android Emulator** (use 10.0.2.2 instead of localhost):
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

**For Real Device on Same Network**:
```dart
static const String baseUrl = 'http://YOUR_PC_IP:5000/api';
```

### 3.5 Run Flutter App

#### Option A: Run on Android Emulator

```bash
# Start Android emulator first, then run:
flutter run
```

#### Option B: Run on Real Android Device

```bash
# Connect device via USB, then:
flutter run
```

#### Option C: Run on iOS (Mac only)

```bash
flutter run
```

#### Option D: Run on Web

```bash
flutter run -d chrome
```

**Expected Output**:
```
Launching lib/main.dart on emulator...
✓ Build successful
✓ App launched
```

---

## Step 4: Test the Connection

### 4.1 Test Backend API

Open your browser and go to:
```
http://localhost:5000/api/health
```

**Should show**:
```json
{"status":"Server is running"}
```

### 4.2 Test Product Listing

Go to:
```
http://localhost:5000/api/products
```

**Should show**: Empty array `[]` (or products if you added them)

### 4.3 Test App Registration

In the Flutter app:
1. Open the registration screen
2. Fill in name, email, password
3. Click "Register"
4. Should see success message

---

## Step 5: Add Sample Data (Optional)

### Add Sample Products via API

Use **Postman** or **Thunder Client** (VS Code extension):

1. **Method**: `POST`
2. **URL**: `http://localhost:5000/api/products`
3. **Headers**: 
   - `Content-Type: application/json`
   - `Authorization: Bearer YOUR_ADMIN_TOKEN`
4. **Body**:
```json
{
  "name": "Nike Shoes",
  "description": "Comfortable sports shoes",
  "price": 5000,
  "originalPrice": 7000,
  "category": "Electronics",
  "image": "https://via.placeholder.com/400",
  "stock": 50
}
```

---

## All in One - Quick Start (Copy & Paste)

### Terminal 1 - Start Backend
```bash
cd "c:\Users\samsung\OneDrive\Desktop\E-Commerce App\e_commerce\backend"
npm install
npm run dev
```

### Terminal 2 - Start Flutter App
```bash
cd "c:\Users\samsung\OneDrive\Desktop\E-Commerce App\e_commerce"
flutter pub get
flutter run
```

---

## Troubleshooting

### ❌ "Can't connect to MongoDB"

**Solution**:
```bash
# Check if MongoDB is running
mongosh

# If error, start MongoDB service
net start MongoDB

# If still not working, check connection string in .env
```

### ❌ "Port 5000 already in use"

**Solution**:
```bash
# Kill process using port 5000
# Windows:
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Or change port in .env and backend server
```

### ❌ "Flutter app can't reach API"

**Solution**:
1. Check backend is running (`http://localhost:5000/api/health`)
2. Update `baseUrl` in `lib/services/api_service.dart`
3. For emulator, use `10.0.2.2` instead of `localhost`
4. For real device, use your PC's IP address

### ❌ "Module not found / npm install fails"

**Solution**:
```bash
cd backend
npm cache clean --force
rm -r node_modules
npm install
```

### ❌ "Flutter build fails"

**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### ❌ "API authentication fails"

**Solutions**:
1. Make sure you registered/logged in first
2. Check token is being saved (check Shared Preferences)
3. Verify JWT_SECRET in `.env` matches
4. Check Authorization header format: `Bearer <token>`

---

## File Locations Reference

```
📁 Project Root
├─ 📁 backend/
│  ├─ src/
│  │  ├─ server.js          ← Main backend file
│  │  ├─ config/database.js ← MongoDB connection
│  │  └─ ...
│  ├─ .env                   ← Edit MongoDB URI here
│  ├─ package.json
│  └─ npm install here
├─ 📁 lib/
│  ├─ services/api_service.dart    ← Edit baseUrl here
│  ├─ providers/                   ← State management
│  └─ ...
├─ pubspec.yaml
├─ README.md
└─ SETUP_AND_RUN.md          ← You are here
```

---

## Useful Commands Reference

```bash
# Backend
cd backend && npm install          # Install dependencies
npm run dev                        # Start development server
npm start                          # Start production server

# Frontend
flutter pub get                    # Install dependencies
flutter run                        # Run app
flutter run -d chrome              # Run on web
flutter clean                      # Clean build files
flutter pub upgrade                # Update packages

# MongoDB
mongosh                            # Open MongoDB shell
use ecommerce                      # Switch to database
db.products.find()                 # View all products
db.users.find()                    # View all users
```

---

## Next Steps After Running

1. ✅ Backend & Frontend are running
2. 🏗️ **Next**: Create Flutter UI screens
3. 📱 Build complete screens for:
   - Login/Register page
   - Product listing page
   - Product detail page
   - Shopping cart page
   - Checkout page
   - Order history page
   - Admin dashboard

---

## Important Notes

- ⚠️ **JWT_SECRET** in `.env` should be changed in production
- ⚠️ **Keep backend terminal running** while developing
- ⚠️ **MongoDB must be running** before starting backend
- ⚠️ **Update API URL** based on your setup (localhost/10.0.2.2/IP)
- ⚠️ **Rebuild app** if you change `pubspec.yaml` or API URL

---

## Need Help?

Check these files for more info:
- `backend/README.md` - Backend details
- `FLUTTER_README.md` - Flutter details
- `README.md` - Full architecture overview

Happy coding! 🚀
