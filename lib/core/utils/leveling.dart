/// Simple leveling curve, shared by Profile and Quest Board so both
/// screens always show the same level/XP, computed from the same source.
///
/// A fresh user starts at Level 1 with 0 XP. Levels up every [xpPerLevel]
/// XP earned from completing quests.
class Leveling {
  static const int xpPerLevel = 400;

  static int levelForXp(int xp) => (xp ~/ xpPerLevel) + 1;
  static int xpIntoCurrentLevel(int xp) => xp % xpPerLevel;
  static const int xpForNextLevel = xpPerLevel;
}