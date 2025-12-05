"""
CONTOH IMPLEMENTASI BACKEND (Flask)
File: app.py atau main blueprint
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
import jwt
from functools import wraps

app = Flask(__name__)
CORS(app)

# Config
app.config['SECRET_KEY'] = 'your-secret-key-here'
app.config['JWT_ALGORITHM'] = 'HS256'
app.config['JWT_EXPIRATION'] = 86400  # 24 hours

# ============ HELPER FUNCTIONS ============

def token_required(f):
    """Decorator untuk check JWT token"""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        
        if not token:
            return jsonify({'message': 'Token missing'}), 401
        
        try:
            token = token.split(' ')[1]  # Remove 'Bearer '
            data = jwt.decode(token, app.config['SECRET_KEY'], 
                            algorithms=[app.config['JWT_ALGORITHM']])
            current_user_id = data['user_id']
        except:
            return jsonify({'message': 'Invalid token'}), 401
        
        return f(current_user_id, *args, **kwargs)
    
    return decorated

def generate_token(user_id):
    """Generate JWT token"""
    payload = {
        'user_id': user_id,
        'iat': datetime.utcnow(),
    }
    token = jwt.encode(payload, app.config['SECRET_KEY'], 
                       algorithm=app.config['JWT_ALGORITHM'])
    return token

# ============ DATABASE MODELS (example dengan dict) ============

# Simulasi database
users = {}
products = [
    {
        'id': 'prod_1',
        'name': 'Tomat Segar',
        'description': 'Tomat organik berkualitas tinggi',
        'price': 25000,
        'image_url': 'https://example.com/tomato.jpg',
        'rating': 4.5,
        'review_count': 15,
        'stock': 50,
        'category': 'Sayuran',
        'created_at': '2024-01-01T00:00:00Z'
    },
    {
        'id': 'prod_2',
        'name': 'Cabai Merah',
        'description': 'Cabai merah keriting segar',
        'price': 35000,
        'image_url': 'https://example.com/chili.jpg',
        'rating': 4.8,
        'review_count': 25,
        'stock': 30,
        'category': 'Sayuran',
        'created_at': '2024-01-02T00:00:00Z'
    },
]
orders = {}

# ============ AUTH ENDPOINTS ============

@app.route('/api/auth/register', methods=['POST'])
def register():
    """Register user baru"""
    data = request.get_json()
    
    email = data.get('email')
    password = data.get('password')
    name = data.get('name')
    
    # Validation
    if not email or not password or not name:
        return jsonify({'message': 'Missing required fields'}), 400
    
    if email in users:
        return jsonify({'message': 'Email already exists'}), 409
    
    # Create user (in real app, hash password!)
    user = {
        'id': f'user_{len(users) + 1}',
        'email': email,
        'password': password,  # DON'T DO THIS IN PRODUCTION!
        'name': name,
        'profile_image': None,
        'created_at': datetime.utcnow().isoformat() + 'Z'
    }
    
    users[email] = user
    token = generate_token(user['id'])
    
    return jsonify({
        'token': token,
        'user': {
            'id': user['id'],
            'email': user['email'],
            'name': user['name'],
            'profile_image': user['profile_image'],
            'created_at': user['created_at']
        }
    }), 201


@app.route('/api/auth/login', methods=['POST'])
def login():
    """Login user"""
    data = request.get_json()
    
    email = data.get('email')
    password = data.get('password')
    
    if not email or not password:
        return jsonify({'message': 'Missing email or password'}), 400
    
    user = users.get(email)
    
    if not user or user['password'] != password:
        return jsonify({'message': 'Invalid email or password'}), 401
    
    token = generate_token(user['id'])
    
    return jsonify({
        'token': token,
        'user': {
            'id': user['id'],
            'email': user['email'],
            'name': user['name'],
            'profile_image': user['profile_image'],
            'created_at': user['created_at']
        }
    }), 200


@app.route('/api/auth/logout', methods=['POST'])
@token_required
def logout(current_user_id):
    """Logout user"""
    return jsonify({'message': 'Logged out successfully'}), 200


@app.route('/api/auth/verify', methods=['GET'])
@token_required
def verify_token(current_user_id):
    """Verify token dan return user info"""
    for email, user in users.items():
        if user['id'] == current_user_id:
            return jsonify({
                'id': user['id'],
                'email': user['email'],
                'name': user['name'],
                'profile_image': user['profile_image'],
                'created_at': user['created_at']
            }), 200
    
    return jsonify({'message': 'User not found'}), 404


# ============ MARKETPLACE ENDPOINTS ============

@app.route('/api/marketplace/products', methods=['GET'])
def get_products():
    """Get products dengan pagination & filter"""
    page = request.args.get('page', 1, type=int)
    page_size = request.args.get('page_size', 10, type=int)
    search = request.args.get('search', '')
    category = request.args.get('category', '')
    
    # Filter
    filtered_products = products
    
    if search:
        filtered_products = [p for p in filtered_products 
                            if search.lower() in p['name'].lower()]
    
    if category:
        filtered_products = [p for p in filtered_products 
                           if p['category'] == category]
    
    # Pagination
    start = (page - 1) * page_size
    end = start + page_size
    paginated = filtered_products[start:end]
    
    return jsonify({
        'products': paginated,
        'total': len(filtered_products),
        'page': page,
        'page_size': page_size
    }), 200


@app.route('/api/marketplace/products/<product_id>', methods=['GET'])
def get_product_detail(product_id):
    """Get detail product"""
    product = next((p for p in products if p['id'] == product_id), None)
    
    if not product:
        return jsonify({'message': 'Product not found'}), 404
    
    return jsonify(product), 200


@app.route('/api/marketplace/search', methods=['GET'])
def search_products():
    """Search products"""
    query = request.args.get('q', '')
    
    if not query:
        return jsonify({'message': 'Search query required'}), 400
    
    results = [p for p in products 
              if query.lower() in p['name'].lower() or 
                 query.lower() in p['description'].lower()]
    
    return jsonify({
        'products': results,
        'total': len(results),
        'page': 1,
        'page_size': len(results)
    }), 200


@app.route('/api/marketplace/detect', methods=['POST'])
def detect_product():
    """Detect product dari image (AI/ML integration)"""
    if 'image' not in request.files:
        return jsonify({'message': 'Image file required'}), 400
    
    image_file = request.files['image']
    
    # TODO: Implement image detection dengan ML model
    # For now, return dummy results
    detected_products = products[:2]  # Return 2 produk pertama
    
    return jsonify({
        'products': detected_products,
        'total': len(detected_products),
        'page': 1,
        'page_size': len(detected_products),
        'confidence': 0.95
    }), 200


@app.route('/api/marketplace/categories', methods=['GET'])
def get_categories():
    """Get all categories"""
    categories = list(set(p['category'] for p in products))
    
    return jsonify({
        'categories': categories
    }), 200


# ============ CART ENDPOINTS ============

@app.route('/api/cart/checkout', methods=['POST'])
@token_required
def checkout(current_user_id):
    """Checkout cart"""
    data = request.get_json()
    
    items = data.get('items', [])
    total_price = data.get('total_price')
    address = data.get('address')
    phone_number = data.get('phone_number')
    notes = data.get('notes', '')
    
    if not items or not address or not phone_number:
        return jsonify({'message': 'Missing required fields'}), 400
    
    # Create order
    order_id = f'order_{len(orders) + 1}'
    order = {
        'id': order_id,
        'user_id': current_user_id,
        'status': 'pending',
        'total_price': total_price,
        'address': address,
        'phone_number': phone_number,
        'notes': notes,
        'items': items,
        'created_at': datetime.utcnow().isoformat() + 'Z',
        'delivered_at': None
    }
    
    orders[order_id] = order
    
    return jsonify({
        'order_id': order_id,
        'status': 'pending',
        'total_price': total_price,
        'created_at': order['created_at']
    }), 201


@app.route('/api/cart/items', methods=['GET'])
@token_required
def get_cart_items(current_user_id):
    """Get cart items (if stored in backend)"""
    # Usually cart is stored in frontend
    # This endpoint untuk restore cart dari backend (optional)
    
    return jsonify({
        'items': []
    }), 200


# ============ ORDER ENDPOINTS ============

@app.route('/api/orders', methods=['GET'])
@token_required
def get_orders(current_user_id):
    """Get user's orders"""
    page = request.args.get('page', 1, type=int)
    page_size = request.args.get('page_size', 10, type=int)
    
    # Filter orders by user
    user_orders = [o for o in orders.values() 
                   if o['user_id'] == current_user_id]
    
    # Pagination
    start = (page - 1) * page_size
    end = start + page_size
    paginated = user_orders[start:end]
    
    return jsonify({
        'orders': paginated,
        'total': len(user_orders),
        'page': page,
        'page_size': page_size
    }), 200


@app.route('/api/orders/<order_id>', methods=['GET'])
@token_required
def get_order_detail(current_user_id, order_id):
    """Get order detail"""
    order = orders.get(order_id)
    
    if not order:
        return jsonify({'message': 'Order not found'}), 404
    
    if order['user_id'] != current_user_id:
        return jsonify({'message': 'Unauthorized'}), 403
    
    return jsonify(order), 200


@app.route('/api/orders/<order_id>/cancel', methods=['POST'])
@token_required
def cancel_order(current_user_id, order_id):
    """Cancel order"""
    order = orders.get(order_id)
    
    if not order:
        return jsonify({'message': 'Order not found'}), 404
    
    if order['user_id'] != current_user_id:
        return jsonify({'message': 'Unauthorized'}), 403
    
    if order['status'] not in ['pending', 'processing']:
        return jsonify({'message': 'Cannot cancel order in this status'}), 400
    
    order['status'] = 'cancelled'
    
    return jsonify({'message': 'Order cancelled successfully'}), 200


# ============ WEBSOCKET UNTUK STREAM STATUS ============

# Gunakan flask-socketio untuk WebSocket
from flask_socketio import SocketIO, emit, join_room, leave_room

socketio = SocketIO(app, cors_allowed_origins='*')

@socketio.on('connect')
def handle_connect():
    print('Client connected')
    emit('response', {'data': 'Connected'})

@socketio.on('join_order')
def handle_join_order(data):
    order_id = data['order_id']
    join_room(order_id)
    emit('message', {'data': f'Joined order {order_id}'})

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')

# Simulasi update status pesanan
import threading
import time

def simulate_order_updates():
    """Simulasi update status pesanan"""
    status_sequence = ['pending', 'processing', 'shipped', 'delivered']
    
    for order_id, order in orders.items():
        current_status_index = status_sequence.index(order['status'])
        
        if current_status_index < len(status_sequence) - 1:
            # Update status after 30 seconds
            time.sleep(30)
            order['status'] = status_sequence[current_status_index + 1]
            
            socketio.emit('order_status_update', {
                'order_id': order_id,
                'status': order['status'],
                'timestamp': datetime.utcnow().isoformat()
            }, room=order_id)


# ============ ERROR HANDLERS ============

@app.errorhandler(400)
def bad_request(error):
    return jsonify({'message': 'Bad request'}), 400

@app.errorhandler(404)
def not_found(error):
    return jsonify({'message': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'message': 'Internal server error'}), 500


# ============ RUN APP ============

if __name__ == '__main__':
    # Uncomment untuk production
    # socketio.run(app, host='0.0.0.0', port=5000, debug=False)
    
    # Development
    socketio.run(app, host='127.0.0.1', port=5000, debug=True)


"""
============ INSTALLATION ============

pip install flask
pip install flask-cors
pip install pyjwt
pip install flask-socketio
pip install python-socketio
pip install python-engineio


============ RUN ============

python app.py
# Server akan berjalan di http://localhost:5000


============ TESTING ============

1. Register:
POST http://localhost:5000/api/auth/register
Body: {
  "email": "user@example.com",
  "password": "password123",
  "name": "User Name"
}

2. Login:
POST http://localhost:5000/api/auth/login
Body: {
  "email": "user@example.com",
  "password": "password123"
}

3. Get Products:
GET http://localhost:5000/api/marketplace/products?page=1&page_size=10

4. Checkout:
POST http://localhost:5000/api/cart/checkout
Header: Authorization: Bearer <token>
Body: {
  "items": [...],
  "total_price": 100000,
  "address": "Jl. Example",
  "phone_number": "08123456789",
  "notes": "Catatan"
}

5. Get Orders:
GET http://localhost:5000/api/orders
Header: Authorization: Bearer <token>

"""
