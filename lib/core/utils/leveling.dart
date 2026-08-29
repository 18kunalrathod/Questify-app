/// Simple leveling curve, shared by Profile and Quest Board so both
/// screens always show the same level/XP, computed from the same source.
///
/// [baselineXp] represents progress from "before" live tracking existed —
/// this is temporary scaffolding, removed once Phase B gives us real
/// historical XP data from a database instead of an in-memory guess.
class Leveling {
  static const int baselineXp = 2400;
  static const int xpPerLevel = 400;

  static int totalXp(int liveXp) => baselineXp + liveXp;
  static int levelForXp(int xp) => (xp ~/ xpPerLevel) + 1;
  static int xpIntoCurrentLevel(int xp) => xp % xpPerLevel;
  static const int xpForNextLevel = xpPerLevel;
}