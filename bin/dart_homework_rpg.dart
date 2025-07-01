import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() {
  List<Monster> monsters = loadMonsterStats();
  int killedMonsters = 0;
  Game game = Game(monsters, killedMonsters);

  print('캐릭터의 이름을 입력하세요!');
  //이름: 입력받기
  String inputName = stdin.readLineSync(encoding: Encoding.getByName('utf-8')!) ?? '이름없음';
  //이름: 정규표현식 검사
  RegExp nameReg = RegExp(r'^[a-zA-Z가-힣]+$');
  if (nameReg.hasMatch(inputName)) {
    //이름: character에 넣고 스탯불러오기
    game.character = loadCharacterStats(inputName);
    //게임 결과값
    int gameResult = game.startGame();
    switch (gameResult) {
      //결과값1: 캐릭터체력이 0 이하였을때 처리
      case 1:
        print('캐릭터의 체력이 0이 되었습니다. 게임을 종료합니다.');
        break;
      //결과값2: 게임 종료 처리
      case 2:
        print('게임을 종료합니다.');
        break;
      //결과값2: 몬스터를 전부 물리쳤을때 처리
      case 3:
        print('게임에서 승리하셨습니다! 게임을 종료합니다.');
        break;
    }
  } else {
    print('이름에는 한글, 영문 대소문자만 사용할 수 있습니다.');
  }
}

//Game클래스
class Game {
  late Character character;
  List<Monster> monsters;
  int killedMonsters;
  Game(this.monsters, this.killedMonsters);

  //게임시작 메서드
  int startGame() {
    if (character.health <= 0) {
      //결과값1: 캐릭터 체력이 0이하일때
      return 1;
    } else {
      //캐릭터체력이 1이상일때
      do{
        battle();
        print('다음 몬스터와 대결하시겠습니까? (y/n)');
        String inputAsk = stdin.readLineSync() ?? 'n';
        if(inputAsk=='n'){
          return 2;
        }
      }while(killedMonsters < monsters.length);
      return 3;
    }
  }

  //전투진행 메서드
  void battle() {
    print('게임을 시작합니다!');
    character.showStatus();
    
    //몬스터불러오기
    Monster thisturnMonster = getRandomMonster();
    print('새로운 몬스터가 나타났습니다!');
    print('${thisturnMonster.name} - 체력: ${thisturnMonster.health}, 공격력: ${thisturnMonster.attack}');

    while(true){
      print('${character.name}의 턴');
      print('행동을 선택하세요 (1: 공격, 2: 방어)');
      String inputBattle = stdin.readLineSync() ?? '1';
      if(inputBattle=='1'){
        //공격
        character.attackMonster(thisturnMonster);
      }else if(inputBattle=='2'){
        //방어
        character.defend();
      }else{
        print('입력값이 올바르지 않습니다!');
      }
    }
  }

  //랜덤으로 몬스터를 불러오는 메서드
  Monster getRandomMonster() {
    Random rand = Random();
    var thisMonster = monsters[rand.nextInt(monsters.length)];
    return(Monster(thisMonster.name, thisMonster.health, thisMonster.attack));
  }
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
  showStatus() {
    print('$name - 체력: $health, 공격력: $attack, 방어력$defense');
  }
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

    return loadMonster;
  } catch (e) {
    print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
    exit(1);
  }
}
