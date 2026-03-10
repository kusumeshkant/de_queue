import 'translation_keys.dart';

/// English (US) translations.
/// To add a new string: add the key to [AppKeys] and add its translation here.
const Map<String, String> enUs = {
  // Auth
  AppKeys.mobileNumber: 'Mobile Number',
  AppKeys.mobileHint: '10-digit number',
  AppKeys.otp: 'OTP',
  AppKeys.otpHint: '6-digit OTP',
  AppKeys.verifyOtp: 'Verify OTP',
  AppKeys.getOtp: 'Get OTP',
  AppKeys.signUp: 'Sign Up',
  AppKeys.signIn: 'Sign In',
  AppKeys.back: 'Back',
  AppKeys.name: 'Name',
  AppKeys.yourName: 'Your Name',

  // Common
  AppKeys.error: 'Error',
  AppKeys.home: 'Home',

  // Bottom Navigation
  AppKeys.cart: 'Cart',
  AppKeys.settings: 'Settings',

  // Settings
  AppKeys.setting: 'Setting',
  AppKeys.account: 'Account',
  AppKeys.profile: 'Profile',
  AppKeys.yourOrders: 'Your Orders',
  AppKeys.phoneNumber: 'Phone number',
  AppKeys.email: 'Email',
  AppKeys.signOut: 'Sign out',
  AppKeys.language: 'Language',
  AppKeys.selectLanguage: 'Select Language',

  // Dashboard
  AppKeys.nearStores: 'Near Stores',
  AppKeys.recentVisit: 'Recent Visit',
  AppKeys.searchHint: 'Search store or product',
  AppKeys.youAreIn: 'You are in',
  AppKeys.noNearbyStores: 'No nearby stores found.',
  AppKeys.noStores: 'No stores available.',
  AppKeys.cancel: 'Cancel',
  AppKeys.confirmStore: 'Confirm Store',
  AppKeys.youAppearNear: 'You appear to be near',
  AppKeys.yesImHere: "Yes, I'm here",
  AppKeys.changeStore: 'Change Store',
  AppKeys.selectFromList: 'Select your store from the list below',
  AppKeys.changeStoreTitle: 'Change Store?',
  AppKeys.changeStoreBody:
      'Switching stores will clear your current cart. Do you want to continue?',
  AppKeys.clearAndChange: 'Clear & Change',

  // Cart
  AppKeys.myCart: 'My Cart',
  AppKeys.items: 'items',
  AppKeys.cartEmpty: 'Your cart is empty.\nScan a product to get started.',
  AppKeys.subtotal: 'Sub-Total',
  AppKeys.tax: 'Tax (18%)',
  AppKeys.total: 'Total',
  AppKeys.checkout: 'Checkout',
  AppKeys.retryPayment: 'Retry Payment',
  AppKeys.paymentFailed: 'Payment Failed',
  AppKeys.viewOrders: 'View Orders',
  AppKeys.orderPlaced: 'Order Placed!',
  AppKeys.orderSuccess: 'Your order has been placed successfully.',
  AppKeys.checkoutFailed: 'Checkout Failed',
  AppKeys.orderConfirmed: 'Order Confirmed',
  AppKeys.paymentSuccessful: 'Payment Successful',
  AppKeys.showToStaff: 'Show this to the store staff',
  AppKeys.orderIdLabel: 'Order ID',
  AppKeys.orderIdCopied: 'Order ID copied to clipboard',
  AppKeys.backToHome: 'Back to Home',

  // Order statuses
  AppKeys.statusPending: 'Pending',
  AppKeys.statusPreparing: 'Preparing',
  AppKeys.statusReady: 'Ready for Pickup',
  AppKeys.statusCompleted: 'Completed',
  AppKeys.statusConfirmed: 'Confirmed',
  AppKeys.statusCancelled: 'Cancelled',
  AppKeys.paymentStatus: 'Payment',
  AppKeys.paymentSuccess: 'Success',
  AppKeys.payStatusPending: 'Pending',
  AppKeys.payStatusFailed: 'Failed',

  // Orders
  AppKeys.noOrders:
      'No orders yet.\nScan products and checkout to place your first order.',
  AppKeys.unknownStore: 'Unknown Store',
  AppKeys.orderSubtotal: 'Subtotal',

  // Scanner
  AppKeys.scanBarcode: 'Scan product barcode',
  AppKeys.scanHint:
      'The barcode will be automatically detected\nwhen positioned between the guide lines',

  // Profile
  AppKeys.phoneNumberLabel: 'Phone Number',
  AppKeys.notAvailable: 'Not available',
  AppKeys.displayName: 'Display Name',
  AppKeys.enterName: 'Enter your name',
  AppKeys.saveChanges: 'Save Changes',
  AppKeys.saved: 'Saved',
  AppKeys.profileUpdated: 'Profile updated successfully.',

  // Language names
  AppKeys.langEnglish: 'English',
  AppKeys.langHindi: 'Hindi',
};
