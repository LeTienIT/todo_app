import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/error/failures.dart';
import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import 'package:riverpod_todo_app/features/auth/domain/entities/user_entity.dart';
import 'package:riverpod_todo_app/features/auth/domain/repositories/auth_repository.dart';
class SignParams{
  final String email;
  final String pass;

  SignParams({required this.email, required this.pass});
}
class SignInUseCase implements UseCase<User, SignParams>{
  final AuthRepository authRepository;
  SignInUseCase(this.authRepository);

  @override
  Future<Either<Failure, User>> call(params) {
    return authRepository.login(email: params.email, password: params.pass);
  }

}