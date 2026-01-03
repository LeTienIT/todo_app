import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/member_chip.dart';

class MemberChipModel {
  final String id;
  final String displayName;

  MemberChipModel({
    required this.id,
    required this.displayName,
  });

  factory MemberChipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final displayName = data['displayName'] as String? ?? 'Unknown User';
    return MemberChipModel(
      id: doc.id,
      displayName: displayName,
    );
  }
  MemberChip toEntity() {
    return MemberChip(id, displayName);
  }

  factory MemberChipModel.fromEntity(MemberChip entity) {
    return MemberChipModel(id: entity.id, displayName: entity.displayName);
  }
}