import 'package:dq_app/src/data/model/order_model.dart';
import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/service_core/networks/graphql_service.dart';

class OrderNotFoundException implements Exception {
  final String orderId;
  const OrderNotFoundException(this.orderId);
  @override
  String toString() => 'Order not found';
}

class OrderRemoteDataSource {
  /// Cart lines as createRazorpayOrder's OrderItemInput. The server prices
  /// every line from its own catalogue; entryMethod only tells exit staff
  /// which lines were typed in, so they check those tags closely.
  static List<Map<String, dynamic>> checkoutItemsInput(List<CartItemEntity> items) => items
      .map((i) => {
            'barcode': i.barcode,
            'name': i.name,
            'price': i.price,
            'quantity': i.quantity,
            'mrp': i.mrp,
            if (i.subtitle.isNotEmpty) 'description': i.subtitle,
            'entryMethod': i.isManualEntry ? 'MANUAL' : 'SCAN',
          })
      .toList();

  Future<RazorpayOrderEntity> createRazorpayOrder({
    required String storeId,
    required List<CartItemEntity> items,
    String? discountCode,
  }) async {
    const mutation = r'''
      mutation CreateRazorpayOrder(
        $storeId: ID!
        $items: [OrderItemInput!]!
        $discountCode: String
      ) {
        createRazorpayOrder(storeId: $storeId, items: $items, discountCode: $discountCode) {
          id
          amount
          currency
          keyId
        }
      }
    ''';

    final result = await GraphQLService.performMutation(
      mutation: mutation,
      variables: {
        'storeId': storeId,
        'items': checkoutItemsInput(items),
        if (discountCode != null) 'discountCode': discountCode,
      },
    );

    final data = result.data?['createRazorpayOrder'];
    if (data == null) throw Exception('Failed to create Razorpay order');

    return RazorpayOrderEntity(
      id: data['id'] as String,
      amount: data['amount'] as int,
      currency: data['currency'] as String,
      keyId: data['keyId'] as String?,
    );
  }

  /// Sends ONLY the three Razorpay values. The server builds the order —
  /// store, items, totals, discount — from its own record of what was paid
  /// for (backend A3), so nothing the client computes is trusted or sent.
  Future<OrderModel> createOrder({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    const mutation = '''
      mutation CreateOrder(
        \$razorpayOrderId: String!
        \$razorpayPaymentId: String!
        \$razorpaySignature: String!
      ) {
        createOrder(
          razorpayOrderId: \$razorpayOrderId
          razorpayPaymentId: \$razorpayPaymentId
          razorpaySignature: \$razorpaySignature
        ) {
          id
          status
          paymentStatus
          total
          discountAmount
          tax
          grandTotal
          createdAt
          items { barcode name mrp price quantity sku description }
          storeName
          exitQr
          exitedAt
        }
      }
    ''';

    final result = await GraphQLService.performMutation(
      mutation: mutation,
      variables: {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );

    final data = result.data?['createOrder'];
    if (data == null) throw Exception('Failed to create order');
    return OrderModel.fromJson(data);
  }

  Future<Map<String, dynamic>> validateDiscountCode({
    required String code,
    required String storeId,
    required double subtotal,
  }) async {
    const mutation = r'''
      mutation ValidateDiscountCode($code: String!, $storeId: ID!, $subtotal: Float!) {
        validateDiscountCode(code: $code, storeId: $storeId, subtotal: $subtotal) {
          valid discountPercent discountAmount finalAmount generatedByName expiresAt
        }
      }
    ''';

    final result = await GraphQLService.performMutation(
      mutation: mutation,
      variables: {'code': code, 'storeId': storeId, 'subtotal': subtotal},
    );

    final data = result.data?['validateDiscountCode'];
    if (data == null) throw Exception('Failed to validate code');
    return data as Map<String, dynamic>;
  }

  Future<List<String>> validateCartStock({
    required String storeId,
    required List<CartItemEntity> items,
  }) async {
    const query = r'''
      query ValidateCartStock($storeId: ID!, $items: [OrderItemInput!]!) {
        validateCartStock(storeId: $storeId, items: $items)
      }
    ''';

    final result = await GraphQLService.performQuery(
      query: query,
      variables: {
        'storeId': storeId,
        'items': items.map((i) => {
          'barcode': i.barcode,
          'name': i.name,
          'price': i.price,
          'quantity': i.quantity,
        }).toList(),
      },
    );

    final List<dynamic> data = result.data?['validateCartStock'] ?? [];
    return data.cast<String>();
  }

  Future<OrderModel> getOrderById(String orderId) async {
    const query = '''
      query GetOrderById(\$id: ID!) {
        order(id: \$id) {
          id
          storeName
          total
          discountAmount
          tax
          grandTotal
          status
          paymentStatus
          createdAt
          items { barcode name mrp price quantity sku description }
          exitQr
          exitedAt
        }
      }
    ''';

    final result = await GraphQLService.performQuery(
      query: query,
      variables: {'id': orderId},
    );
    final data = result.data?['order'];
    // The server answers null for an order this account does not own or that
    // no longer exists — not a network problem, so callers can drop it.
    if (data == null) throw OrderNotFoundException(orderId);
    return OrderModel.fromJson(data);
  }

  Future<List<OrderModel>> getMyOrders() async {
    const query = '''
      query {
        myOrders {
          id
          storeName
          total
          discountAmount
          tax
          grandTotal
          status
          paymentStatus
          createdAt
          items {
            barcode
            name
            price
            quantity
            sku
            description
          }
          exitQr
          exitedAt
        }
      }
    ''';

    final result = await GraphQLService.performQuery(query: query);
    final List<dynamic> data = result.data?['myOrders'] ?? [];
    return data.map((o) => OrderModel.fromJson(o)).toList();
  }
}
