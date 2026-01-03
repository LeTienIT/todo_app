import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/error/failures.dart';
import 'package:riverpod_todo_app/features/home/data/datasources/member_chip_datasource.dart';
import 'package:riverpod_todo_app/features/home/domain/entities/member_chip.dart';
import 'package:riverpod_todo_app/features/home/domain/repository/member_chip_repository.dart';

class MemberChipRepositoryImpl implements MemberChipRepository{
  final MemberChipDatasource memberChipDatasource;

  MemberChipRepositoryImpl(this.memberChipDatasource);

  @override
  Future<Either<Failure, List<MemberChip>>> getMemberChip(List<String> ids) async {
    try{
      final rs = await memberChipDatasource.getMemberChips(ids);

      return Right(rs);
    }
    catch (e){
      return Left(ServerFailure("Error"));
    }

  }


}