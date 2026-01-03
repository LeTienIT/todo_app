import 'package:equatable/equatable.dart';
class Project extends Equatable{
  String? id;
  String name;
  List<String> members;
  DateTime deadline;
  String creator;

  Project({this.id, required this.name, required this.members, required this.deadline, required this.creator});

  @override
  // TODO: implement props
  List<Object?> get props => [id, name, members, deadline, creator];

  Project copyWith({String? id, String? name, List<String>? members, DateTime? deadline, String? creator}){
    return Project(
        id: id ?? this.id,
        name: name ?? this.name,
        members: members ?? this.members,
        deadline: deadline ?? this.deadline,
        creator: creator ?? this.creator
    );
  }
}