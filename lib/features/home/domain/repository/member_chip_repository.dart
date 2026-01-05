import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/error/failures.dart';
import 'package:riverpod_todo_app/features/home/domain/entities/member_chip.dart';

abstract class MemberChipRepository{
  Future<Either<Failure, List<MemberChip>>> getMemberChip(List<String> ids);

  Future<Either<Failure, MemberChip>> getMemberChipByName(String name);
}