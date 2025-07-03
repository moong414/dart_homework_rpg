import 'character.dart';
import 'monster.dart';
import 'dart:io';

//캐릭터 스탯불러오기
Character loadCharacterStats(String name) {
  try {
    final file = File('data/characters.txt');
    final contents = file.readAsStringSync();
    final stats = contents.split(',');
    if (stats.length != 3) throw FormatException('Invalid character data');
    int health = int.parse(stats[0]);
    int attack = int.parse(stats[1]);
    int defense = int.parse(stats[2]);
    //캐릭터 객체를 리턴
    return Character(name, health, attack, defense);
  } catch (e) {
    print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
    exit(1);
  }
}

//몬스터 스탯불러오기
List<Monster> loadMonsterStats() {
  try {
    final file = File('data/monsters.txt');
    final contents = file.readAsStringSync();
    //한줄씩 나누기
    var lines = contents.split('\n');
    String name;
    int health;
    int attack;
    List<Monster> loadMonster = [];
    //나눈값을 리스트로 만들기
    for (var line in lines) {
      var mon = line.split(',');
      name = mon[0];
      health = int.parse(mon[1]);
      attack = int.parse(mon[2]);
      loadMonster.add(Monster(name, health, attack));
    }
    //몬스터 클래스를 데이터값으로 가진 리스트를 리턴
    return loadMonster;
  } catch (e) {
    print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
    exit(1);
  }
}
