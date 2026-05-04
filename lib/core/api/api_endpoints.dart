/// Configuration centralisée des endpoints API
class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://djinaapi.gconnectapp.com';

  // Auth endpoints
  static const String tokenObtain = '/api/auth/token/';
  static const String tokenRefresh = '/api/auth/token/refresh/';
  static const String registerCustomer = '/api/auth/register-customer/';
  static const String registerDriver = '/api/auth/register-driver/';
  static const String authMe = '/api/auth/me/';

  // OTP endpoints
  static const String otpRequest = '/api/auth/otp/request/';
  static const String otpVerify = '/api/auth/otp/verify/';
  static const String otpLogin = '/api/auth/otp/login/';
  static const String otpResend = '/api/auth/otp/resend/';

  // Users
  static const String users = '/api/users/';

  // Courses
  static const String courses = '/api/courses/';
  static const String initiateRide = '/api/courses/initiate/';
  static String startRide(String rideId) => '/api/courses/$rideId/start/';
  static String completeRide(String rideId) => '/api/courses/$rideId/complete/';
  static String cancelRide(String rideId) => '/api/courses/$rideId/cancel/';
  static String getActiveRide(String userId) => '/api/courses/active/$userId/';
  static const String submitRating = '/api/courses/rate/';
  static String driverLocation(String rideId) => '/api/courses/$rideId/location/';
  
  // Payments
  static const String payments = '/api/payments/';

  // Helper pour construire une URL complète
  static String fullUrl(String endpoint) => '$baseUrl$endpoint';
}