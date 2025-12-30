import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/error/failures.dart';
import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import 'package:riverpod_todo_app/features/auth/domain/repositories/auth_repository.dart';

import '../entities/user_entity.dart';

class GetCurrentUserUseCase implements UseCase<User?, NoParams>{
  final AuthRepository authRepository;
  GetCurrentUserUseCase(this.authRepository);

  @override
  Future<Either<Failure, User?>> call(params) {
    return authRepository.getCurrentUser();
  }

}