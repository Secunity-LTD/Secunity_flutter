class Team {
  final String uid;
  final String name;
  final String city;
  final String leaderUid;
  final List<String> members;
  final List<String> position;
  bool alert = false;

  Team(this.uid, this.name, this.city, this.leaderUid, this.members,
      this.position, this.alert);

  toJson() {
    return {
      'squad_name': name,
      'city': city,
      'leader': leaderUid,
      'members': members,
      'position': position,
      'alert': alert,
    };
  }
}
