import 'dart:io';

void main() {
  List<Monster> monsters = loadMonsterStats();
  int killedMonsters = 0;
  Game game = Game(monsters, killedMonsters);
  
  game.startGame();


  print(monsters[0].name);
}

//Game클래스
class Game {
  late Character character;
  List<Monster> monsters;
  int killedMosters;
  Game(this.monsters, this.killedMosters);

  //게임시작 메서드
  void startGame() {
    // String name = getCharacterName();
    // character = loadCharacterStats(name);
  }

  //전투진행 메서드
  void battle() {}

  //랜덤으로 몬스터를 불러오는 메서드
  void getRandomMonster() {}
}

//Character클래스
class Character {
  String name;
  int health;
  int attack;
  int defense;
  Character(this.name, this.health, this.attack, this.defense);

  //공격메서드
  attackMonster(Monster monster) {}

  //방어메서드
  defend() {}

  //상태출력메서드
  showStatus() {}
}

//Monster클래스
class Monster {
  String name;
  int health;
  int attack;
  int defense;
  Monster(this.name, this.health, this.attack) : defense = 0;

  //공격 메서드
  attackCharacter(Character character) {}

  //상태를출력하는 메서드
  showStatus() {}
}

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

    //String name = getCharacterName();
    return Character(name, health, attack, defense);
  } catch (e) {
    print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
    exit(1);
  }
}

//캐릭터이름입력함수
// String getCharacterName() {
//   print('캐릭터 이름을 입력하세요:');
//   String inputName = stdin.readLineSync();

// }

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
    //나눈값을 맵으로 만들기
    for(var line in lines){
      var mon = line.split(',');
      name = mon[0];
      health = int.parse(mon[1]);
      attack = int.parse(mon[2]);
      loadMonster.add(Monster(name, health, attack));
    }

    return loadMonster;

  } catch (e) {
    print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
    exit(1);
  }
}
