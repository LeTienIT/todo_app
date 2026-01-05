import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import 'package:riverpod_todo_app/features/home/domain/entities/member_chip.dart';
import 'package:riverpod_todo_app/features/home/domain/repository/member_chip_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class GetMemberChipByNameUsecase implements UseCase<MemberChip, String>{
  final MemberChipRepository memberChipRepository;

  GetMemberChipByNameUsecase(this.memberChipRepository);

  @override
  Future<Either<Failure, MemberChip>> call(String params) {
    return memberChipRepository.getMemberChipByName(params);
  }
}