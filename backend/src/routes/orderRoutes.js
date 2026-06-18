const express = require('express');
const orderController = require('../controllers/orderController');
const { authMiddleware, adminMiddleware } = require('../middlewares/auth');

const router = express.Router();

// Admin routes
router.get('/admin/all', authMiddleware, adminMiddleware, orderController.getAllOrders);
router.put('/:id/status', authMiddleware, adminMiddleware, orderController.updateOrderStatus);

// Protected routes
router.post('/', authMiddleware, orderController.createOrder);
router.get('/', authMiddleware, orderController.getUserOrders);
router.get('/:id', authMiddleware, orderController.getOrderById);

module.exports = router;
