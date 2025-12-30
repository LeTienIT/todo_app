
import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import 'package:riverpod_todo_app/features/auth/domain/usecases/get_user_usecase.dart';

import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_todo_app/core/providers.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginUseCase: sl<SignInUseCase>(),
    registerUseCase: sl<RegisterUseCase>(),
    logoutUseCase: sl<SignOutUseCase>(),
    getCurrentUserUseCase: sl<GetCurrentUserUseCase>()
  );
});


class AuthController extends StateNotifier<AuthState> {
  final SignInUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final SignOutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthState.initial());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    final result = await getCurrentUserUseCase(NoParams());

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false);
      },
          (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
        );
      },
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await loginUseCase(SignParams(email: email, pass: password));

    result.fold(
          (failure) {
            state = state.copyWith(
              isLoading: false,
              error: failure.message,
            );
          },
          (user) {
            state = state.copyWith(
              isLoading: false,
              user: user,
            );
          },
    );
  }

  Future<void> register(String email, String password, String displayName,) async {
    state = state.copyWith(isLoading: true, error: null);

    final result =
    await registerUseCase(RegisterParams(email: email, pass: password, displayName: displayName));

    result.fold(
          (failure) => state = state.copyWith(
            isLoading: false,
            error: failure.message,
          ),
          (user) => state = state.copyWith(
            isLoading: false,
            user: user,
          ),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    final result = await logoutUseCase(NoParams());

    result.fold(
          (failure) => state = state.copyWith(
            isLoading: false,
            error: failure.message,
          ),
          (_) => state = AuthState.initial(),
    );
  }
}
