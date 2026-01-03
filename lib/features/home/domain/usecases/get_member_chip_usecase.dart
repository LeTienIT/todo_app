import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import 'package:riverpod_todo_app/features/home/domain/entities/member_chip.dart';
import 'package:riverpod_todo_app/features/home/domain/repository/member_chip_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class GetMemberChipUsecase implements UseCase<List<MemberChip>, List<String>>{
  final MemberChipRepository memberChipRepository;

  GetMemberChipUsecase(this.memberChipRepository);

  @override
  Future<Either<Failure, List<MemberChip>>> call(List<String> params) {
    return memberChipRepository.getMemberChip(params);
  }
}