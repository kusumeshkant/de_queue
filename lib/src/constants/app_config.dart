class AppConfig {
  AppConfig._();

  // Set at build time via --dart-define=APP_FLAVOR=dev|uat|prod
  // Defaults to prod so accidental builds without --dart-define are always safe.
  static const _flavor = String.fromEnvironment('APP_FLAVOR', defaultValue: 'prod');

  static const String flavor  = _flavor;
  static const bool   isDev   = _flavor == 'dev';
  static const bool   isUat   = _flavor == 'uat';
  static const bool   isProd  = _flavor == 'prod';

  // UAT backend provider — set via --dart-define=BACKEND_PROVIDER=vercel|render|azure
  // vercel → Vercel DEV serverless (always warm, uses dq_dev)
  // render → Render UAT (suspended)
  // azure  → Azure UAT Container App (ca-dq-uat)
  static const _backendProvider = String.fromEnvironment('BACKEND_PROVIDER', defaultValue: 'azure');

  // Explicit backend override for dev/uat builds — e.g. a local backend or a
  // Vercel preview: --dart-define=GRAPHQL_ENDPOINT=http://localhost:4100/graphql
  // IGNORED for the prod flavor, so a production build can never be pointed
  // anywhere but the production backend by accident.
  static const _endpointOverride = String.fromEnvironment('GRAPHQL_ENDPOINT');

  static const String _defaultGraphqlEndpoint = _flavor == 'dev'
      ? 'https://de-backend-iota.vercel.app/graphql'
      : _flavor == 'uat'
          ? (_backendProvider == 'vercel'
              ? 'https://de-backend-iota.vercel.app/graphql'
              : _backendProvider == 'render'
                  ? 'https://dq-backend-uat.onrender.com/graphql'
                  : 'https://ca-dq-uat.ashysea-f5376b70.centralindia.azurecontainerapps.io/graphql')
          : 'https://de-backend-iota.vercel.app/graphql';

  static const String graphqlEndpoint =
      (_endpointOverride != '' && _flavor != 'prod') ? _endpointOverride : _defaultGraphqlEndpoint;

  // For prod builds pass --dart-define=RAZORPAY_KEY_ID=rzp_live_xxx to use the
  // live key. Dev and UAT always use the test key regardless of dart-define.
  static const String razorpayKeyId = _flavor == 'prod'
      ? String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: 'rzp_test_SNjNbfNOTtc2oC')
      : 'rzp_test_SNjNbfNOTtc2oC';
}
