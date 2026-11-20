import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/logging_interceptor.dart';
import 'package:sixvalley_vendor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late DioClient client;
  late AuthRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.userPassword: 'legacy-password',
      AppConstants.userEmail: 'vendor@example.com',
      AppConstants.token: 'session-secret',
    });
    preferences = await SharedPreferences.getInstance();
    client = DioClient('https://example.com', Dio(),
        loggingInterceptor: LoggingInterceptor(), sharedPreferences: preferences);
    repository = AuthRepository(
        dioClient: client, sharedPreferences: preferences);
  });

  tearDown(() => client.dio!.close(force: true));

  test('legacy passwords are purged without changing the saved session', () async {
    expect(repository.getUserPassword(), isEmpty);
    // Wait for the constructor's asynchronous legacy preference removal.
    await preferences.reload();
    expect(preferences.containsKey(AppConstants.userPassword), isFalse);
    expect(repository.getUserEmail(), 'vendor@example.com');
    expect(repository.getUserToken(), 'session-secret');
    expect(repository.isLoggedIn(), isTrue);
    expect(client.dio!.options.headers['Authorization'], 'Bearer session-secret');
  });

  test('remembering credentials saves only email and preserves token APIs', () async {
    await repository.saveUserCredentials('new@example.com', 'new-password');
    expect(preferences.containsKey(AppConstants.userPassword), isFalse);
    expect(repository.getUserPassword(), isEmpty);
    expect(repository.getUserEmail(), 'new@example.com');

    await repository.saveUserToken('updated-session');
    expect(repository.getUserToken(), 'updated-session');
    expect(client.token, 'updated-session');
    expect(client.dio!.options.headers['Authorization'], 'Bearer updated-session');

    expect(await repository.clearUserNumberAndPassword(), isTrue);
    expect(repository.getUserEmail(), isEmpty);
    expect(repository.getUserToken(), 'updated-session');
    expect(repository.isLoggedIn(), isTrue);
  });

  test('logout removes a legacy password left after startup cleanup', () async {
    await preferences.reload();
    await preferences.setString(AppConstants.userPassword, 'legacy-password');
    expect(preferences.containsKey(AppConstants.userPassword), isTrue);

    expect(await repository.clearSharedData(), isTrue);
    expect(preferences.containsKey(AppConstants.userPassword), isFalse);
    expect(repository.getUserToken(), isEmpty);
    expect(repository.isLoggedIn(), isFalse);
    expect(repository.getUserEmail(), 'vendor@example.com');
  });

  test('login still sends the supplied password without persisting it', () async {
    client.dio!.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.data, {
        'email': 'vendor@example.com',
        'password': 'login-password',
      });
      handler.resolve(Response(
          requestOptions: options, statusCode: 200, data: {'token': 'new-token'}));
    }));
    final result = await repository.login(
        emailAddress: 'vendor@example.com', password: 'login-password');
    expect(result.response?.statusCode, 200);
    expect(preferences.containsKey(AppConstants.userPassword), isFalse);
  });

  test('multipart diagnostics omit URLs, headers, fields and response secrets', () async {
    final messages = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) messages.add(message);
    };
    addTearDown(() => debugPrint = originalDebugPrint);
    client.dio!.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.headers['Authorization'], 'Bearer session-secret');
      expect(options.data, isA<FormData>());
      handler.resolve(
          Response(
              requestOptions: options,
              statusCode: 200,
              headers: Headers.fromMap({'set-cookie': ['cookie-secret']}),
              data: {'token': 'response-secret'}),
          true);
    }));

    await client.postMultipart('/upload?token=url-secret',
        data: {'password': 'body-secret'},
        queryParameters: {'token': 'query-secret'},
        options: Options(headers: {'X-Support-Token': 'support-secret'}));

    expect(messages, ['--> POST HTTP', '<-- 200 POST HTTP']);
    expect(messages.join(), isNot(contains('secret')));
    expect(messages.join(), isNot(contains('Authorization')));
  });

  test('error diagnostics omit server payloads and exception messages', () async {
    final messages = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) messages.add(message);
    };
    addTearDown(() => debugPrint = originalDebugPrint);
    client.dio!.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.reject(
          DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              message: 'exception-secret',
              response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {'token': 'response-secret'})),
          true);
    }));

    await expectLater(client.get('/private?token=url-secret'),
        throwsA(isA<DioException>()));
    expect(messages, ['--> GET HTTP', 'ERROR[401] GET badResponse']);
    expect(messages.join(), isNot(contains('secret')));
  });
}
