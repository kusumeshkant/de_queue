import 'translation_keys.dart';

/// Hindi (India) translations.
/// To add a new string: add the key to [AppKeys] and add its translation here.
const Map<String, String> hiIn = {
  // Auth
  AppKeys.mobileNumber: 'मोबाइल नंबर',
  AppKeys.mobileHint: '10 अंकों का नंबर',
  AppKeys.otp: 'ओटीपी',
  AppKeys.otpHint: '6 अंकों का ओटीपी',
  AppKeys.verifyOtp: 'ओटीपी सत्यापित करें',
  AppKeys.getOtp: 'ओटीपी प्राप्त करें',
  AppKeys.signUp: 'साइन अप',
  AppKeys.signIn: 'साइन इन',
  AppKeys.back: 'वापस',
  AppKeys.name: 'नाम',
  AppKeys.yourName: 'आपका नाम',

  // Common
  AppKeys.error: 'त्रुटि',
  AppKeys.home: 'होम',

  // Bottom Navigation
  AppKeys.cart: 'कार्ट',
  AppKeys.settings: 'सेटिंग्स',

  // Settings
  AppKeys.setting: 'सेटिंग',
  AppKeys.account: 'खाता',
  AppKeys.profile: 'प्रोफ़ाइल',
  AppKeys.yourOrders: 'आपके ऑर्डर',
  AppKeys.phoneNumber: 'फ़ोन नंबर',
  AppKeys.email: 'ईमेल',
  AppKeys.signOut: 'साइन आउट',
  AppKeys.language: 'भाषा',
  AppKeys.selectLanguage: 'भाषा चुनें',

  // Dashboard
  AppKeys.nearStores: 'नज़दीकी दुकानें',
  AppKeys.recentVisit: 'हाल का दौरा',
  AppKeys.searchHint: 'दुकान या उत्पाद खोजें',
  AppKeys.youAreIn: 'आप यहाँ हैं',
  AppKeys.noNearbyStores: 'कोई नज़दीकी दुकान नहीं मिली।',
  AppKeys.noStores: 'कोई दुकान उपलब्ध नहीं।',
  AppKeys.cancel: 'रद्द करें',
  AppKeys.confirmStore: 'दुकान की पुष्टि करें',
  AppKeys.youAppearNear: 'आप इस दुकान के पास लगते हैं',
  AppKeys.yesImHere: 'हाँ, मैं यहाँ हूँ',
  AppKeys.changeStore: 'दुकान बदलें',
  AppKeys.selectFromList: 'नीचे सूची से अपनी दुकान चुनें',
  AppKeys.changeStoreTitle: 'दुकान बदलें?',
  AppKeys.changeStoreBody:
      'दुकान बदलने पर आपकी मौजूदा कार्ट साफ़ हो जाएगी। क्या आप जारी रखना चाहते हैं?',
  AppKeys.clearAndChange: 'साफ़ करें और बदलें',

  // Cart
  AppKeys.myCart: 'मेरी कार्ट',
  AppKeys.items: 'आइटम',
  AppKeys.cartEmpty: 'आपकी कार्ट खाली है।\nशुरू करने के लिए कोई उत्पाद स्कैन करें।',
  AppKeys.subtotal: 'उप-कुल',
  AppKeys.tax: 'कर (18%)',
  AppKeys.total: 'कुल',
  AppKeys.checkout: 'चेकआउट',
  AppKeys.retryPayment: 'पुनः भुगतान करें',
  AppKeys.paymentFailed: 'भुगतान विफल',
  AppKeys.viewOrders: 'ऑर्डर देखें',
  AppKeys.orderPlaced: 'ऑर्डर दर्ज हो गया!',
  AppKeys.orderSuccess: 'आपका ऑर्डर सफलतापूर्वक दर्ज हो गया।',
  AppKeys.checkoutFailed: 'चेकआउट विफल',
  AppKeys.orderConfirmed: 'ऑर्डर कन्फर्म',
  AppKeys.paymentSuccessful: 'भुगतान सफल',
  AppKeys.showToStaff: 'यह स्टोर स्टाफ को दिखाएं',
  AppKeys.orderIdLabel: 'ऑर्डर ID',
  AppKeys.orderIdCopied: 'ऑर्डर ID कॉपी हुई',
  AppKeys.backToHome: 'होम पर वापस जाएं',

  // Order statuses
  AppKeys.statusPending: 'प्रतीक्षित',
  AppKeys.statusPreparing: 'तैयारी हो रही है',
  AppKeys.statusReady: 'लेने के लिए तैयार',
  AppKeys.statusCompleted: 'पूर्ण',
  AppKeys.statusCancelled: 'रद्द',

  // Orders
  AppKeys.noOrders:
      'अभी तक कोई ऑर्डर नहीं।\nपहला ऑर्डर देने के लिए उत्पाद स्कैन करें और चेकआउट करें।',
  AppKeys.unknownStore: 'अज्ञात दुकान',
  AppKeys.orderSubtotal: 'उप-कुल',

  // Scanner
  AppKeys.scanBarcode: 'उत्पाद बारकोड स्कैन करें',
  AppKeys.scanHint:
      'बारकोड को गाइड लाइनों के बीच रखने पर\nस्वचालित रूप से पहचाना जाएगा',

  // Profile
  AppKeys.phoneNumberLabel: 'फ़ोन नंबर',
  AppKeys.notAvailable: 'उपलब्ध नहीं',
  AppKeys.displayName: 'प्रदर्शन नाम',
  AppKeys.enterName: 'अपना नाम दर्ज करें',
  AppKeys.saveChanges: 'परिवर्तन सहेजें',
  AppKeys.saved: 'सहेजा गया',
  AppKeys.profileUpdated: 'प्रोफ़ाइल सफलतापूर्वक अपडेट हो गई।',

  // Language names
  AppKeys.langEnglish: 'English',
  AppKeys.langHindi: 'हिन्दी',
};
