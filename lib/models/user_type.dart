/// User types in the SafePlay system
enum UserType {
  parent,
  juniorChild, // Ages 6-8
  brightChild, // Ages 9-12
  teacher,
  counselor,
  admin,
  guest;

  bool get isChild => this == juniorChild || this == brightChild;
  bool get isAdult =>
      this == parent || this == teacher || this == counselor || this == admin;
  bool get isJunior => this == juniorChild;
  bool get isBright => this == brightChild;
}

/// Age group classification
enum AgeGroup {
  junior(6, 8),
  bright(9, 12);

  const AgeGroup(this.minAge, this.maxAge);

  final int minAge;
  final int maxAge;

  bool isValidAge(int age) => age >= minAge && age <= maxAge;

  static AgeGroup? fromAge(int age) {
    if (junior.isValidAge(age)) return junior;
    if (bright.isValidAge(age)) return bright;
    return null;
  }
}

