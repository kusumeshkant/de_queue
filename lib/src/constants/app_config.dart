class AppConfig {
  AppConfig._();

  // For Android emulator use: http://10.0.2.2:4000/
  // For physical device use your machine's local IP: http://192.168.x.x:4000/
  // For production use your deployed URL
  static const String graphqlEndpoint = 'http://192.168.1.15:4000/';

  static const String razorpayKeyId = 'rzp_test_SNjNbfNOTtc2oC';
}
