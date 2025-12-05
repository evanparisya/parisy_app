# Backend Flask Setup Guide

## Quick Start Backend

Jika Anda ingin menggunakan API real (bukan mock), ikuti langkah ini:

### 1. Setup Environment
```bash
# Navigate ke folder backend
cd backend/

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# MacOS/Linux:
source venv/bin/activate

# Install dependencies
pip install flask flask-cors python-dotenv
```

### 2. Create `.env` file
```
FLASK_ENV=development
FLASK_APP=app.py
SECRET_KEY=your_secret_key_here
DB_URL=sqlite:///app.db
```

### 3. Create Basic Flask App (`backend/app.py`)
```python
from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime, timedelta
import json

app = Flask(__name__)
CORS(app)

# Dummy database
USERS = {
    'admin@gmail.com': {
        'id': 'USER-001',
        'name': 'Admin User',
        'email': 'admin@gmail.com',
        'password': 'password',
        'phone': '081234567890',
        'address': 'Jakarta, Indonesia'
    },
    'user@example.com': {
        'id': 'USER-002',
        'name': 'Regular User',
        'email': 'user@example.com',
        'password': 'password123',
        'phone': '081234567891',
        'address': 'Bandung, Indonesia'
    },
}

PRODUCTS = [
    {
        'id': 'PROD-001',
        'name': 'Laptop Gaming ASUS ROG',
        'price': 15000000,
        'image_url': 'https://via.placeholder.com/300x300?text=Laptop',
        'stock': 5,
    },
    {
        'id': 'PROD-002',
        'name': 'Smartphone Flagship',
        'price': 8999000,
        'image_url': 'https://via.placeholder.com/300x300?text=Phone',
        'stock': 12,
    },
]

# Health Check
@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'message': 'Backend is running'})

# Login Endpoint
@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    
    if email not in USERS:
        return jsonify({'success': False, 'message': 'Email tidak ditemukan'}), 401
    
    user = USERS[email]
    if user['password'] != password:
        return jsonify({'success': False, 'message': 'Password salah'}), 401
    
    # Generate token (simple JWT-like token)
    import base64
    token = base64.b64encode(f"{email}:{datetime.now().timestamp()}".encode()).decode()
    
    return jsonify({
        'success': True,
        'message': 'Login berhasil',
        'data': {
            'user': {
                'id': user['id'],
                'name': user['name'],
                'email': user['email'],
                'phone': user['phone'],
                'address': user['address']
            },
            'token': token
        }
    })

# Get Products
@app.route('/api/marketplace/products', methods=['GET'])
def get_products():
    return jsonify({'products': PRODUCTS})

# Get Orders
@app.route('/api/orders', methods=['GET'])
def get_orders():
    return jsonify({'orders': []})

if __name__ == '__main__':
    app.run(debug=True, host='localhost', port=5000)
```

### 4. Run Flask Backend
```bash
python app.py
```

Backend akan berjalan di: `http://localhost:5000`

### 5. Disable Mock Mode di Flutter App
Edit file `lib/features/auth/services/auth_service.dart`:
```dart
static const bool useMockAuth = false;  // Change to false
```

### 6. Test Login
- Gunakan akun yang sudah didefinisikan di USERS dict
- Login akan connect ke Flask API real
- Response akan diproses oleh AuthController

---

## Troubleshooting

### CORS Error
- Pastikan `flask_cors` sudah ter-install
- Import: `from flask_cors import CORS`
- Init: `CORS(app)`

### Connection Refused
- Pastikan Flask running di port 5000
- Check firewall settings
- Verify baseUrl di `app_constants.dart`

### 404 Not Found
- Pastikan endpoint path sesuai
- Check request method (GET/POST)
- Verify JSON payload

### Still getting network error?
- Keep `useMockAuth = true` untuk testing
- Atau setup backend sesuai guide ini
