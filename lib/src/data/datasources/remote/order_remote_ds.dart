import 'package:dq_app/src/data/model/order_model.dart';
import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/service_core/networks/graphql_service.dart';

class OrderRemoteDataSource {
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
        }
      }
    ''';

    final result = await GraphQLService.performMutation(
      mutation: mutation,
      variables: {
        'storeId': storeId,
        'items': items
            .map((i) => {
                  'barcode': i.barcode,
                  'name': i.name,
                  'price': i.price,
                  'quantity': i.quantity,
                  'mrp': i.mrp,
                  if (i.subtitle.isNotEmpty) 'description': i.subtitle,
                })
            .toList(),
        if (discountCode != null) 'discountCode': discountCode,
      },
    );

    final data = result.data?['createRazorpayOrder'];
    if (data == null) throw Exception('Failed to create Razorpay order');

    return RazorpayOrderEntity(
      id: data['id'] as String,
      amount: data['amount'] as int,
      currency: data['currency'] as String,
    );
  }

  Future<OrderModel> createOrder({
    required String storeId,
    required List<CartItemEntity> items,
    required double total,
    required double tax,
    required double grandTotal,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    String? discountCode,
  }) async {
    const mutation = '''
      mutation CreateOrder(
        \$storeId: ID!
        \$items: [OrderItemInput!]!
        \$total: Float!
        \$tax: Float!
        \$grandTotal: Float!
        \$razorpayOrderId: String!
        \$razorpayPaymentId: String!
        \$razorpaySignature: String!
        \$discountCode: String
      ) {
        createOrder(
          storeId: \$storeId
          items: \$items
          total: \$total
          tax: \$tax
          grandTotal: \$grandTotal
          razorpayOrderId: \$razorpayOrderId
          razorpayPaymentId: \$razorpayPaymentId
          razorpaySignature: \$razorpaySignature
          discountCode: \$discountCode
        ) {
          id
          status
          paymentStatus
          total
          tax
          grandTotal
          createdAt
          items { barcode name mrp price quantity sku description }
          storeName
        }
      }
    ''';

    final result = await GraphQLService.performMutation(
      mutation: mutation,
      variables: {
        'storeId': storeId,
        'items': items
            .map((i) => {
                  'barcode': i.barcode,
                  'name': i.name,
                  'mrp': i.mrp,
                  'price': i.price,
                  'quantity': i.quantity,
                  'sku': i.sku,
                  'description': i.subtitle,
                })
            .toList(),
        'total': total,
        'tax': tax,
        'grandTotal': grandTotal,
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
        if (discountCode != null) 'discountCode': discountCode,
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
        orderById(id: \$id) {
          id
          storeName
          total
          tax
          grandTotal
          status
          paymentStatus
          createdAt
          items { barcode name mrp price quantity sku description }
        }
      }
    ''';

    final result = await GraphQLService.performQuery(
      query: query,
      variables: {'id': orderId},
    );
    final data = result.data?['orderById'];
    if (data == null) throw Exception('Order not found');
    return OrderModel.fromJson(data);
  }

  Future<List<OrderModel>> getMyOrders() async {
    const query = '''
      query {
        myOrders {
          id
          storeName
          total
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
        }
      }
    ''';

    final result = await GraphQLService.performQuery(query: query);
    final List<dynamic> data = result.data?['myOrders'] ?? [];
    return data.map((o) => OrderModel.fromJson(o)).toList();
  }
}
