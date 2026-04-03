import 'package:dq_app/src/data/model/order_model.dart';
import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/service_core/networks/graphql_service.dart';

class OrderRemoteDataSource {
  Future<RazorpayOrderEntity> createRazorpayOrder(double amount) async {
    const mutation = '''
      mutation CreateRazorpayOrder(\$amount: Float!) {
        createRazorpayOrder(amount: \$amount) {
          id
          amount
          currency
        }
      }
    ''';

    final result = await GraphQLService.performMutation(
      mutation: mutation,
      variables: {'amount': amount},
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
        ) {
          id
          status
          paymentStatus
          total
          tax
          grandTotal
          createdAt
          items { barcode name price quantity sku description }
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
      },
    );

    final data = result.data?['createOrder'];
    if (data == null) throw Exception('Failed to create order');
    return OrderModel.fromJson(data);
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
          items { barcode name price quantity sku description }
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
