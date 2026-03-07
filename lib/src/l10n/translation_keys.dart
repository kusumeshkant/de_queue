/// All translation keys used throughout the app.
/// Use these constants with .tr extension to get translated text.
/// Example: AppKeys.mobileNumber.tr
abstract class AppKeys {
  // ── Auth ─────────────────────────────────────────────────────────────────
  static const mobileNumber = 'Mobile Number';
  static const mobileHint = '10-digit number';
  static const otp = 'OTP';
  static const otpHint = '6-digit OTP';
  static const verifyOtp = 'Verify OTP';
  static const getOtp = 'Get OTP';
  static const signUp = 'Sign Up';
  static const signIn = 'Sign In';
  static const back = 'Back';
  static const name = 'Name';
  static const yourName = 'Your Name';

  // ── Common ────────────────────────────────────────────────────────────────
  static const error = 'Error';
  static const home = 'Home';

  // ── Bottom Navigation ────────────────────────────────────────────────────
  static const cart = 'Cart';
  static const settings = 'Settings';

  // ── Settings ─────────────────────────────────────────────────────────────
  static const setting = 'Setting';
  static const account = 'Account';
  static const profile = 'Profile';
  static const yourOrders = 'Your Orders';
  static const phoneNumber = 'Phone number';
  static const email = 'Email';
  static const signOut = 'Sign out';
  static const language = 'Language';
  static const selectLanguage = 'Select Language';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const nearStores = 'Near Stores';
  static const recentVisit = 'Recent Visit';
  static const searchHint = 'Search store or product';
  static const youAreIn = 'You are in';
  static const noNearbyStores = 'No nearby stores found.';
  static const noStores = 'No stores available.';
  static const cancel = 'Cancel';
  static const confirmStore = 'Confirm Store';
  static const youAppearNear = 'You appear to be near';
  static const yesImHere = "Yes, I'm here";
  static const changeStore = 'Change Store';
  static const selectFromList = 'Select your store from the list below';
  static const changeStoreTitle = 'Change Store?';
  static const changeStoreBody =
      'Switching stores will clear your current cart. Do you want to continue?';
  static const clearAndChange = 'Clear & Change';

  // ── Cart ──────────────────────────────────────────────────────────────────
  static const myCart = 'My Cart';
  static const items = 'items';
  static const cartEmpty = 'Your cart is empty.\nScan a product to get started.';
  static const subtotal = 'Sub-Total';
  static const tax = 'Tax (18%)';
  static const total = 'Total';
  static const checkout = 'Checkout';
  static const retryPayment = 'Retry Payment';
  static const paymentFailed = 'Payment Failed';
  static const viewOrders = 'View Orders';
  static const orderPlaced = 'Order Placed!';
  static const orderSuccess = 'Your order has been placed successfully.';
  static const checkoutFailed = 'Checkout Failed';
  static const orderConfirmed = 'Order Confirmed';
  static const paymentSuccessful = 'Payment Successful';
  static const showToStaff = 'Show this to the store staff';
  static const orderIdLabel = 'Order ID';
  static const orderIdCopied = 'Order ID copied to clipboard';
  static const backToHome = 'Back to Home';

  // ── Orders ────────────────────────────────────────────────────────────────
  // ── Order statuses ───────────────────────────────────────────────────────
  static const statusPending = 'Pending';
  static const statusPreparing = 'Preparing';
  static const statusReady = 'Ready';
  static const statusCompleted = 'Completed';
  static const statusCancelled = 'Cancelled';

  static const noOrders =
      'No orders yet.\nScan products and checkout to place your first order.';
  static const unknownStore = 'Unknown Store';
  static const orderSubtotal = 'Subtotal';

  // ── Scanner ───────────────────────────────────────────────────────────────
  static const scanBarcode = 'Scan product barcode';
  static const scanHint =
      'The barcode will be automatically detected\nwhen positioned between the guide lines';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const phoneNumberLabel = 'Phone Number';
  static const notAvailable = 'Not available';
  static const displayName = 'Display Name';
  static const enterName = 'Enter your name';
  static const saveChanges = 'Save Changes';
  static const saved = 'Saved';
  static const profileUpdated = 'Profile updated successfully.';

  // ── Language names ────────────────────────────────────────────────────────
  static const langEnglish = 'English';
  static const langHindi = 'Hindi';
}
