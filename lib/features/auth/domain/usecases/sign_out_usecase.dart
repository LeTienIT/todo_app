import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/error/failures.dart';
import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import 'package:riverpod_todo_app/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase implements UseCase<Unit, NoParams>{
  final AuthRepository authRepository;
  SignOutUseCase(this.authRepository);

  @override
  Future<Either<Failure, Unit>> call(params) {
    return authRepository.logout();
  }

}