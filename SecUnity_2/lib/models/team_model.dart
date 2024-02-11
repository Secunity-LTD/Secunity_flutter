class Team {
  final String uid;
  final String name;
  final String city;
  final String leaderUid;
  final List<String> members;
  bool alert = false;

  Team(this.uid, this.name, this.city, this.leaderUid, this.members,
      this.alert);
}