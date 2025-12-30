import 'package:riverpod_todo_app/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String email, required String pass, required String displayName
  });

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, User?>> getCurrentUser();
}