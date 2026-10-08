import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/core/network/dio_error_mapper.dart';

void main() {
  group('AppException Hierarchy & DioErrorMapper', () {
    test('AppException subclasses instantiate with correct messages', () {
      const net = NetworkException('No connection');
      const auth = UnauthorizedException('Token expired');
      const val = ValidationException('Invalid field');
      const nf = NotFoundException('Not found');
      const srv = ServerException('Internal error');

      expect(net.message, 'No connection');
      expect(auth.message, 'Token expired');
      expect(val.message, 'Invalid field');
      expect(nf.message, 'Not found');
      expect(srv.message, 'Internal error');
    });

    test('mapDioException returns inner AppException if already wrapped', () {
      const expected = NetworkException('Custom network issue');
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: expected,
      );

      final mapped = mapDioException(dioException);
      expect(mapped, same(expected));
    });

    test('mapDioException unwraps ApiException by status code', () {
      // 401 -> UnauthorizedException
      final unauthorizedDio = DioException(
        requestOptions: RequestOptions(path: '/user'),
        error: ApiException.unauthorized(),
      );
      expect(mapDioException(unauthorizedDio), isA<UnauthorizedException>());

      // 404 -> NotFoundException
      final notFoundDio = DioException(
        requestOptions: RequestOptions(path: '/item'),
        error: const ApiException('Item missing', statusCode: 404),
      );
      expect(mapDioException(notFoundDio), isA<NotFoundException>());

      // 422 -> ValidationException
      final validationDio = DioException(
        requestOptions: RequestOptions(path: '/submit'),
        error: const ApiException('Invalid input', statusCode: 422),
      );
      expect(mapDioException(validationDio), isA<ValidationException>());

      // 500 -> ServerException
      final serverDio = DioException(
        requestOptions: RequestOptions(path: '/data'),
        error: ApiException.server(),
      );
      expect(mapDioException(serverDio), isA<ServerException>());

      // null statusCode -> NetworkException
      final networkDio = DioException(
        requestOptions: RequestOptions(path: '/data'),
        error: ApiException.network(),
      );
      expect(mapDioException(networkDio), isA<NetworkException>());
    });

    test('mapDioException handles timeout and connection error types', () {
      final timeoutDio = DioException(
        requestOptions: RequestOptions(path: '/slow'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(mapDioException(timeoutDio), isA<NetworkException>());

      final cancelDio = DioException(
        requestOptions: RequestOptions(path: '/cancel'),
        type: DioExceptionType.cancel,
      );
      expect(mapDioException(cancelDio), isA<NetworkException>());
    });

    test('mapDioException parses bad response details', () {
      final response401 = Response(
        requestOptions: RequestOptions(path: '/auth'),
        statusCode: 401,
        data: {'detail': 'Invalid credentials'},
      );
      final dio401 = DioException(
        requestOptions: RequestOptions(path: '/auth'),
        type: DioExceptionType.badResponse,
        response: response401,
      );
      final mapped401 = mapDioException(dio401);
      expect(mapped401, isA<UnauthorizedException>());
      expect(mapped401.message, 'Invalid credentials');
    });
  });
}
