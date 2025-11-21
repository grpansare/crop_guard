# Crop Disease Backend API

A Spring Boot REST API with JWT authentication for the Crop Disease Detection Flutter app.

## Features

- User registration and authentication
- JWT token-based security
- Password encryption with BCrypt
- H2 in-memory database for development
- CORS enabled for Flutter app integration
- Role-based access control

## Technologies Used

- Spring Boot 3.2.0
- Spring Security
- Spring Data JPA
- JWT (JSON Web Tokens)
- H2 Database
- Maven

## API Endpoints

### Authentication Endpoints

#### POST /api/auth/signup
Register a new user account.

**Request Body:**
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "password123",
  "fullName": "John Doe"
}
```

**Response:**
```json
{
  "message": "User registered successfully!"
}
```

#### POST /api/auth/signin
Login with existing credentials.

**Request Body:**
```json
{
  "username": "john_doe",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "fullName": "John Doe"
}
```

#### GET /api/auth/profile
Get current user profile (requires authentication).

**Headers:**
```
Authorization: Bearer <your-jwt-token>
```

**Response:**
```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "fullName": "John Doe"
}
```

### Test Endpoints

#### GET /api/test/all
Public endpoint accessible to everyone.

#### GET /api/test/user
Protected endpoint for authenticated users.

**Headers:**
```
Authorization: Bearer <your-jwt-token>
```

#### GET /api/test/admin
Protected endpoint for admin users only.

## Running the Application

1. Make sure you have Java 17+ and Maven installed
2. Navigate to the backend directory
3. Run the application:

```bash
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

## Database Access

The H2 console is available at: `http://localhost:8080/h2-console`

**Connection details:**
- JDBC URL: `jdbc:h2:mem:testdb`
- Username: `sa`
- Password: `password`

## Flutter Integration

### HTTP Client Setup

Add these dependencies to your Flutter `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

### Example Flutter Code

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8080/api/auth';
  
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'fullName': fullName,
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  Future<Map<String, dynamic>> signin({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save token to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', data['token']);
      return data;
    } else {
      throw Exception('Failed to sign in');
    }
  }
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
```

## Security Configuration

- JWT tokens expire after 24 hours
- Passwords are encrypted using BCrypt
- CORS is configured to allow requests from any origin
- Session management is stateless

## Error Handling

The API returns appropriate HTTP status codes:
- 200: Success
- 400: Bad Request (validation errors)
- 401: Unauthorized
- 403: Forbidden
- 500: Internal Server Error

## Development Notes

- The application uses H2 in-memory database for development
- For production, configure a persistent database like PostgreSQL or MySQL
- Update the JWT secret in production
- Configure proper CORS origins for production
