import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/error/failures.dart';
import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import 'package:riverpod_todo_app/features/auth/domain/entities/user_entity.dart';
import 'package:riverpod_todo_app/features/auth/domain/repositories/auth_repository.dart';
class RegisterParams{
  final String email;
  final String pass;
  final String displayName;

  RegisterParams({required this.email, required this.pass, required this.displayName});
}
class RegisterUseCase implements UseCase<User, RegisterParams>{
  final AuthRepository authRepository;
  RegisterUseCase(this.authRepository);

  @override
  Future<Either<Failure, User>> call(params) {
    return authRepository.register(email: params.email, pass: params.pass, displayName: params.displayName);
  }

}