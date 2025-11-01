import 'package:dio/dio.dart';
import 'package:teslo_shop/config/config.dart';
import 'package:teslo_shop/features/auth/domain/domain.dart';
import 'package:teslo_shop/features/auth/infrastructure/infrastructure.dart';

class AuthDatasourceImpl extends AuthDatasource {
  final dio = Dio(BaseOptions(baseUrl: Environment.apiUrl));

  @override
  Future<User> checkAuthStatus(String token) async {
    try {
      final response = await dio.get('/auth/check-status',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final user = UserMapper.userJsonToEntity(response.data);
      return user;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        throw CustomError('Invalid token.');
      }
      throw Exception();
    } catch (error) {
      throw Exception();
    }
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dio
          .post('/auth/login', data: {'email': email, 'password': password});
      final user = UserMapper.userJsonToEntity(response.data);
      return user;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        throw CustomError(
            error.response?.data['message'] ?? 'Invalid credentials');
      }
      if (error.type == DioExceptionType.connectionTimeout) {
        throw CustomError('No internet connection');
      }
      throw Exception();
    } catch (error) {
      throw Exception();
    }
  }

  @override
  Future<User> register(String email, String password, String fullName) async {
    try {
      final response = await dio.post('/auth/register',
          data: {'email': email, 'password': password, 'fullName': fullName});
      final user = UserMapper.userJsonToEntity(response.data);
      return user;
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        throw CustomError(error.response?.data['message'] ?? 'Unknown error');
      }
      if (error.type == DioExceptionType.connectionTimeout) {
        throw CustomError('No internet connection');
      }
      throw Exception();
    } catch (error) {
      throw Exception();
    }
  }
}
