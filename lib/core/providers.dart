import 'package:get_it/get_it.dart';
import 'package:riverpod_todo_app/features/chat/data/datasoures/message_datasource.dart';
import 'package:riverpod_todo_app/features/chat/data/datasoures/message_datasource_impl.dart';
import 'package:riverpod_todo_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:riverpod_todo_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:riverpod_todo_app/features/chat/domain/usecases/deleteMessage.dart';
import 'package:riverpod_todo_app/features/chat/domain/usecases/load_more_message.dart';
import 'package:riverpod_todo_app/features/chat/domain/usecases/send_message.dart';
import 'package:riverpod_todo_app/features/chat/domain/usecases/stream_message.dart';
import 'package:riverpod_todo_app/features/home/data/datasources/member_chip_datasource.dart';
import 'package:riverpod_todo_app/features/home/data/repositories/member_chip_repository_impl.dart';
import 'package:riverpod_todo_app/features/home/domain/repository/member_chip_repository.dart';
import 'package:riverpod_todo_app/features/home/domain/usecases/delete_project_usecase.dart';
import 'package:riverpod_todo_app/features/home/domain/usecases/get_member_chip_usecase.dart';
import 'package:riverpod_todo_app/features/task/data/datasource/task_remote_datasource.dart';
import 'package:riverpod_todo_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:riverpod_todo_app/features/task/domain/repositories/task_repository.dart';
import 'package:riverpod_todo_app/features/task/domain/usecases/create_task_usecase.dart';
import 'package:riverpod_todo_app/features/task/domain/usecases/delete_task_usecase.dart';
import 'package:riverpod_todo_app/features/task/domain/usecases/get_task_usecase.dart';
import 'package:riverpod_todo_app/features/task/domain/usecases/toggle_task_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_user_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/sign_in_usecase.dart';
import '../features/auth/domain/usecases/sign_out_usecase.dart';
import '../features/home/data/datasources/project_remote_datasource.dart';
import '../features/home/data/repositories/project_repository_impl.dart';
import '../features/home/domain/repository/project_repository.dart';
import '../features/home/domain/usecases/create_project_usecase.dart';
import '../features/home/domain/usecases/project_list_usecase.dart';
import '../features/home/domain/usecases/update_project_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  // DI AUTHEN
  sl.registerLazySingleton<AuthenticationRemoteDataSource>(
          () => AuthenticationRemoteDataSource(firebaseAuth: sl(), firestore: sl())
  );
  sl.registerLazySingleton<AuthenticationLocalDataSource>(
          () => AuthenticationLocalDataSource()
  );
  sl.registerLazySingleton<AuthRepository>(
          () => AuthenticationRepositoryImpl(remoteDataSource: sl(), localDataSource: sl())
  );
  sl.registerLazySingleton<RegisterUseCase>(
          () => RegisterUseCase(sl())
  );
  sl.registerLazySingleton<SignInUseCase>(
          () => SignInUseCase(sl())
  );
  sl.registerLazySingleton<SignOutUseCase>(
          () => SignOutUseCase(sl())
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
          () => GetCurrentUserUseCase(sl())
  );
  // DI PROJECT
  sl.registerLazySingleton<ProjectRemoteDataSource>(
          () => ProjectRemoteDataSource(sl<FirebaseFirestore>())
  );
  sl.registerLazySingleton<ProjectRepository>(
          () => ProjectRepositoryImpl(sl())
  );
  sl.registerLazySingleton<CreateProjectsUseCase>(
          () => CreateProjectsUseCase(sl())
  );
  sl.registerLazySingleton<GetProjectsUseCase>(
          () => GetProjectsUseCase(sl())
  );
  sl.registerLazySingleton<DeleteProjectsUseCase>(
          () => DeleteProjectsUseCase(sl())
  );
  sl.registerLazySingleton<UpdateProjectsUseCase>(
          () => UpdateProjectsUseCase(sl())
  );
  // DI MEMBER CHIP
  sl.registerLazySingleton<MemberChipDatasource>(
          () => MemberChipDatasource(sl())
  );
  sl.registerLazySingleton<MemberChipRepository>(
          () => MemberChipRepositoryImpl(sl())
  );
  sl.registerLazySingleton<GetMemberChipUsecase>(
          () => GetMemberChipUsecase(sl())
  );

  // DI TASK
  sl.registerLazySingleton<TaskRemoteDataSource>(
          () => TaskRemoteDataSource(sl<FirebaseFirestore>())
  );
  sl.registerLazySingleton<TaskRepository>(
          () => TaskRepositoryImpl(sl())
  );
  sl.registerLazySingleton<CreateTaskUsecase>(
          () => CreateTaskUsecase(sl())
  );
  sl.registerLazySingleton<GetTaskUsecase>(
          () => GetTaskUsecase(sl())
  );
  sl.registerLazySingleton<ToggleTaskUsecase>(
          () => ToggleTaskUsecase(sl())
  );
  sl.registerLazySingleton<DeleteTaskUsecase>(
          () => DeleteTaskUsecase(sl())
  );

  // DI chat
  sl.registerLazySingleton<MessageDataSource>(() => MessageDataSourceImpl(sl()));
  sl.registerLazySingleton<MessageRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerLazySingleton(() => StreamMessage(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => LoadMoreMessages(sl()));
  sl.registerLazySingleton(() => DeleteMessage(sl()));

}