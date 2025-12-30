import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthenticationRepositoryImpl implements AuthRepository {
  final AuthenticationRemoteDataSource remoteDataSource;
  final AuthenticationLocalDataSource localDataSource;

  AuthenticationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login({required String email, required String password,}) async {
    try {
      final remoteUser = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(remoteUser);

      return Right(remoteUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, User>> register({required String email, required String pass, required String displayName}) async {
    try {
      final remoteUser = await remoteDataSource.register(email, displayName, pass);
      await localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCachedUser();
      return const Right(unit);
    } on ServerException {
      return const Left(ServerFailure('Logout failed'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Thử remote trước
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser);
      }
      else{
        return Left(ServerFailure(''));
      }
    } on ServerException {
      // Fallback local nếu remote fail (offline)
    }

    try {
      final localUser = await localDataSource.getCachedUser();
      if(localUser != null){
        return Right(localUser);
      }
      else{
        return Left(ServerFailure(''));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message ?? 'Cache error'));
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return remoteDataSource.authStateChanges();
  }
}