// Stage 4 — the customer's exit pass, exit status, entryMethod and the saved order.
import 'package:dq_app/src/data/datasources/remote/order_remote_ds.dart';
import 'package:dq_app/src/data/model/order_model.dart';
import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/domain/repo/order_repository.dart';
import 'package:dq_app/src/domain/repo/store_repository.dart';
import 'package:dq_app/src/domain/usecase/get_nearby_stores_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_order_by_id_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_store_by_code_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_stores_usecase.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:dq_app/src/presentation/order/order_detail_page.dart';
import 'package:dq_app/src/presentation/order/widgets/exit_pass.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/src/utils/services/local_storage.dart';
import 'package:dq_app/src/utils/services/pending_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _id = '6ac09f45469f468a4ebff14a';
const _qr = 'DQX1:JCTWB6R0XDPGZ5MBVHFXDD1M';

OrderEntity _order({String status = 'pending', String? exitQr = _qr, String? exitedAt}) => OrderEntity(
      id: _id,
      storeName: 'DQ UAT Demo Mart',
      total: 628,
      tax: 113.04,
      grandTotal: 741.04,
      status: status,
      createdAt: '2026-10-03T06:23:01.411Z',
      items: const [OrderItemEntity(barcode: 'UAT-0001', name: 'UAT Basmati Rice 1kg', price: 249, quantity: 1)],
      exitQr: exitQr,
      exitedAt: exitedAt,
    );

class _Theme extends ThemeController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _StoreRepo implements StoreRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Scripted answers for the dashboard's order refresh.
class _Repo implements OrderRepository {
  Object? next; // an OrderEntity to return, or an exception to throw
  int calls = 0;
  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    calls++;
    final n = next;
    if (n is OrderEntity) return n;
    throw n!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Dashboard extends DashboardController {
  _Dashboard(_Repo repo)
      : super(
          getStoresUseCase: GetStoresUseCase(repository: _StoreRepo()),
          getNearbyStoresUseCase: GetNearbyStoresUseCase(repository: _StoreRepo()),
          getOrderByIdUseCase: GetOrderByIdUseCase(repository: repo),
          getStoreByCodeUseCase: GetStoreByCodeUseCase(repository: _StoreRepo()),
        );

  // Skips loading stores / saved orders on start; the tests drive it directly.
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  group('exit state on the order', () {
    test('open order: QR is the DQX1 code, shown grouped for typing', () {
      final o = _order();
      expect(o.canExit, isTrue);
      expect(o.qrData, _qr);
      expect(o.exitCode, 'JCTWB6R0XDPGZ5MBVHFXDD1M');
      expect(o.exitCodeGrouped, 'DQX1: JCTW B6R0 XDPG Z5MB VHFX DD1M');
    });

    test('legacy order (no exit code) keeps the order-id QR', () {
      final o = _order(exitQr: null);
      expect(o.qrData, _id);
      expect(o.exitCode, isNull);
      expect(o.exitCodeGrouped, isNull);
    });

    test('exited (or completed under the old flow) or cancelled: no QR', () {
      expect(_order(status: 'completed', exitedAt: '2026-10-03T06:54:42.714Z').qrData, isNull);
      expect(_order(status: 'completed').isExited, isTrue);
      expect(_order(status: 'cancelled').qrData, isNull);
      expect(_order(status: 'cancelled').isExited, isFalse);
    });

    test('parses exitQr and exitedAt from the server', () {
      final o = OrderModel.fromJson({
        'id': _id, 'total': 628, 'tax': 113.04, 'grandTotal': 741.04, 'status': 'completed',
        'createdAt': '2026-10-03T06:23:01.411Z', 'items': [], 'exitQr': null, 'exitedAt': '2026-10-03T06:54:42.714Z',
      });
      expect(o.isExited, isTrue);
      expect(o.exitedAt, '2026-10-03T06:54:42.714Z');
    });
  });

  test('cart lines tell the server which were typed in', () {
    final items = OrderRemoteDataSource.checkoutItemsInput([
      CartItemEntity(barcode: 'A', name: 'a', subtitle: '', price: 1),
      CartItemEntity(barcode: 'B', name: 'b', subtitle: '', price: 2, entryMethod: CartEntryMethod.manual),
    ]);
    expect(items.map((i) => i['entryMethod']), ['SCAN', 'MANUAL']);
  });

  group('screens', () {
    setUp(() {
      Get.testMode = true;
      Get.reset();
      Get.put<ThemeController>(_Theme());
    });
    tearDown(Get.reset);

    Future<void> pump(WidgetTester t, Widget w) async {
      t.view.physicalSize = const Size(900, 2400);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(GetMaterialApp(home: Scaffold(body: SingleChildScrollView(child: w))));
      await t.pump();
    }

    testWidgets('open order: QR encodes the DQX1 code and the code is printed under it', (t) async {
      await pump(t, ExitPassCard(order: _order()));
      expect(t.widget<QrImageView>(find.byKey(const Key('exit-pass-qr'))), isNotNull);
      expect(find.text('DQX1: JCTW B6R0 XDPG Z5MB VHFX DD1M'), findsOneWidget);
      expect(find.text('Paid · show this at the exit'), findsOneWidget);
      expect(find.text('Exit code'), findsOneWidget);
    });

    testWidgets('legacy order: QR and text show the order id', (t) async {
      await pump(t, ExitPassCard(order: _order(exitQr: null)));
      expect(find.text(_id), findsOneWidget);
      expect(find.text('Order ID'), findsOneWidget);
    });

    testWidgets('exited order: the QR is replaced by "Exited at …"', (t) async {
      await pump(t, ExitPassCard(order: _order(status: 'completed', exitedAt: '2026-10-03T06:54:42.714Z')));
      expect(find.byKey(const Key('exit-pass-qr')), findsNothing);
      final text = t.widget<Text>(find.byKey(const Key('exit-pass-exited-at'))).data!;
      expect(text, startsWith('Exited at '));
      expect(text, contains('/2026'));
    });

    testWidgets('cancelled order: no QR', (t) async {
      await pump(t, ExitPassCard(order: _order(status: 'cancelled')));
      expect(find.byKey(const Key('exit-pass-qr')), findsNothing);
      expect(find.byKey(const Key('exit-pass-cancelled')), findsOneWidget);
    });

    testWidgets('status badge: Paid · show at exit / Exited / Cancelled', (t) async {
      await pump(t, Column(children: [
        ExitStatusBadge(order: _order()),
        ExitStatusBadge(order: _order(status: 'completed', exitedAt: '2026-10-03T06:54:42.714Z')),
        ExitStatusBadge(order: _order(status: 'cancelled')),
      ]));
      expect(find.text('Paid · show at exit'), findsOneWidget);
      expect(find.text('Exited'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('order detail (history) of an exited order shows Exited, not a QR', (t) async {
      t.view.physicalSize = const Size(900, 2400);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(GetMaterialApp(
          home: OrderDetailPage(order: _order(status: 'completed', exitedAt: '2026-10-03T06:54:42.714Z'))));
      await t.pump();
      expect(find.byKey(const Key('exit-pass-exited')), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);
    });
  });

  group('saved pending order (local storage)', () {
    late _Repo repo;
    late _Dashboard dash;

    setUp(() async {
      Get.testMode = true;
      Get.reset();
      SharedPreferences.setMockInitialValues({});
      repo = _Repo();
      dash = _Dashboard(repo);
      Get.put<DashboardController>(dash);
      await LocalStorage.savePendingOrder(_order(exitQr: null)); // saved before exit codes existed
      dash.activeOrder.value = await LocalStorage.loadPendingOrder();
    });
    tearDown(Get.reset);

    test('round-trips exitQr and exitedAt', () async {
      await LocalStorage.savePendingOrder(_order(exitedAt: '2026-10-03T06:54:42.714Z'));
      final o = (await LocalStorage.loadPendingOrder())!;
      expect(o.exitQr, _qr);
      expect(o.exitedAt, '2026-10-03T06:54:42.714Z');
    });

    test('still open: refreshed from the server and re-saved (now with the exit code)', () async {
      repo.next = _order();
      await dash.refreshActiveOrder();
      expect(dash.activeOrder.value!.exitQr, _qr);
      expect((await LocalStorage.loadPendingOrder())!.exitQr, _qr);
    });

    test('exited on the server: the saved order is dropped', () async {
      repo.next = _order(status: 'completed', exitedAt: '2026-10-03T06:54:42.714Z');
      await dash.refreshActiveOrder();
      expect(dash.activeOrder.value, isNull);
      expect(await LocalStorage.loadPendingOrder(), isNull);
    });

    test('cancelled on the server: dropped', () async {
      repo.next = _order(status: 'cancelled');
      await dash.refreshActiveOrder();
      expect(await LocalStorage.loadPendingOrder(), isNull);
    });

    test('the server no longer knows it for this account: dropped', () async {
      repo.next = const OrderNotFoundException(_id);
      await dash.refreshActiveOrder();
      expect(await LocalStorage.loadPendingOrder(), isNull);
    });

    test('network trouble: kept, to try again later', () async {
      repo.next = Exception('Network error');
      await dash.refreshActiveOrder();
      expect(dash.activeOrder.value, isNotNull);
      expect(await LocalStorage.loadPendingOrder(), isNotNull);
    });
  });

  group('cold start: reconcilePendingOrder decides whether to reopen the saved order', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await LocalStorage.savePendingOrder(_order(exitQr: null));
    });

    test('exited on the server: not reopened, and forgotten', () async {
      final saved = (await LocalStorage.loadPendingOrder())!;
      final shown = await reconcilePendingOrder(saved, (_) async => _order(status: 'completed', exitedAt: '2026-10-03T06:54:42.714Z'));
      expect(shown, isNull);
      expect(await LocalStorage.loadPendingOrder(), isNull);
    });

    test('still open: reopened with the fresh copy (now carrying the exit code)', () async {
      final saved = (await LocalStorage.loadPendingOrder())!;
      final shown = await reconcilePendingOrder(saved, (_) async => _order());
      expect(shown!.exitQr, _qr);
    });

    test('server too slow: the saved copy is shown rather than nothing', () async {
      final saved = (await LocalStorage.loadPendingOrder())!;
      final shown = await reconcilePendingOrder(
        saved,
        (_) => Future.delayed(const Duration(seconds: 1), () => _order(status: 'cancelled')),
        timeout: const Duration(milliseconds: 50),
      );
      expect(shown!.id, _id);
      expect(await LocalStorage.loadPendingOrder(), isNotNull);
    });
  });
}
