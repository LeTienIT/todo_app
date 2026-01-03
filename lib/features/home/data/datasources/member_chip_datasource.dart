import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/error/exceptions.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/member_chip.dart';
import '../model/member_chip_model.dart';

class MemberChipDatasource{
  final FirebaseFirestore firestore;

  MemberChipDatasource(this.firestore);

  Future<List<MemberChip>> getMemberChips(List<String> ids) async {
    try {
      if (ids.isEmpty) {
        return <MemberChip>[];
      }

      final List<List<String>> batches = [];
      for (int i = 0; i < ids.length; i += 10) {
        final end = i + 10 < ids.length ? i + 10 : ids.length;
        batches.add(ids.sublist(i, end));
      }

      final List<MemberChip> memberChips = [];
      for (final batch in batches) {
        final snapshot = await firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in snapshot.docs) {
          final model = MemberChipModel.fromFirestore(doc);
          memberChips.add(model.toEntity());
        }
      }

      // Sort theo thứ tự gốc
      memberChips.sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));

      return memberChips;
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Firestore query failed: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }
}