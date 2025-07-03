import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() {
  List<Monster> monsters = loadMonsterStats();
  int killedMonsters = 0;
  Game game = Game(monsters, killedMonsters);
  File file = File('data/result.txt');

  print('캐릭터의 이름을 입력하세요!');
  //이름: 입력받기
  String inputName =
      stdin.readLineSync(encoding: Encoding.getByName('utf-8')!) ?? '이름없음';
  //이름: 정규표현식 검사
  RegExp nameReg = RegExp(r'^[a-zA-Z가-힣]+$');
  if (nameReg.hasMatch(inputName)) {
    //이름: character에 넣고 스탯불러오기
    game.character = loadCharacterStats(inputName);
    //게임 결과값
    int gameResult = game.startGame();
    //게임결과값에 따른 승패유무
    String winOrLose = '';
    switch (gameResult) {
      //결과값1: 캐릭터체력이 0 이하였을때 처리
      case 1:
        print('캐릭터의 체력이 0이 되었습니다. 게임을 종료합니다.');
        winOrLose = '패';
        break;
      //결과값2: 게임 종료 처리
      case 2:
        print('게임을 종료합니다.');
        winOrLose = '기권';
        break;
      //결과값2: 몬스터를 전부 물리쳤을때 처리
      case 3:
        print('게임에서 승리하셨습니다! 게임을 종료합니다.');
        winOrLose = '승';
        break;
    }
    //결과를 result.txt에 기록
    file.writeAsStringSync(
      '캐릭터의 이름: ${game.character.name}, 남은체력:${game.character.health}, 게임 결과: $winOrLose \n',
      mode: FileMode.append, // 기존 내용 뒤에 추가
      encoding: utf8, // 인코딩 (기본값은 utf8)
      flush: true, // 디스크에 즉시 기록할지 여부 (기본값 false)
    );
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
    while (true) {
      //전투진행 메서드 출력
      battle();
      //전투 1회 진행 후 확인
      if (character.health <= 0) {
        //결과값 1: 캐릭터 체력이 0이하일때
        return 1;
      } else if (monsters.isEmpty) {
        //결과값 3: 몬스터리스트가 비어있을때
        return 3;
      }
      //↑↑ 위 사항 둘 다 아닐경우 재대결
      print('다음 몬스터와 대결하시겠습니까? (y/n)');
      String inputAsk = stdin.readLineSync() ?? 'n';
      //결과값2: 몬스터와 재대결 n을 선택할 경우
      if (inputAsk == 'n') {
        return 2;
      }
    }
  }

  //전투진행 메서드
  void battle() {
    //전투진행메서드: 게임시작 & 캐릭터 상태 출력
    print('===================================');
    print('게임을 시작합니다!');
    //게임시작후 보너스체력 이벤트
    Random rand = Random();
    double chance = rand.nextDouble();
    if (chance < 0.3) {
      //30퍼센트 확률로 이벤트 발생
      character.health += 10;
      print('보너스 체력을 얻었습니다! 현재 체력: ${character.health}');
    }
    character.showStatus();
    //몬스터불러오기 메서트 호출 후 thisMonster객체에 전달 & 몬스터 상태 출력
    Monster thisturnMonster = getRandomMonster();
    print('===================================');
    print('새로운 몬스터가 나타났습니다!');
    print(
      '${thisturnMonster.name} - 체력: ${thisturnMonster.health}, 공격력: ${thisturnMonster.attack}',
    );
    //몬스터가 입힐 데미지 변수
    int? damage;
    //몬스터 방어력 증가 확인 카운터
    int monDefCounter = 0;
    //전투진행메서드: 캐릭터의 턴
    while (true) {
      //캐릭터의 초기 공격력
      int originAttack = character.attack;
      print('===================================');
      print('${character.name}의 턴');
      print('행동을 선택하세요 (1: 공격, 2: 방어, 3: 아이템사용)');
      String inputBattle = stdin.readLineSync() ?? '1';
      //공격을 선택했을 경우
      if (inputBattle == '1') {
        //캐릭터의 attackMonster 호출
        character.attackMonster(thisturnMonster);
        //방어를 선택했을 경우
      } else if (inputBattle == '2') {
        //캐릭터의 defend 호출 & 캐릭터 상태 출력
        character.defend(damage ?? 0);
        character.showStatus();
      } else if (inputBattle == '3') {
        if(character.usedItem){
          character.attack *= 2;
          print('${character.name}이 아이템을 사용하였습니다. 공격력이 2배가 됩니다. 현재공격력: ${character.attack}');
          character.usedItem = false;
        }else{
          print('이미 아이템을 사용하셨습니다!');
        }
        character.attackMonster(thisturnMonster);
        character.attack = originAttack;
      } else {
        //공격&방어 외를 선택했을 경우→턴 넘어감
        print('입력값이 올바르지 않습니다!');
      }
      //몬스터의 턴==============================
      print('===================================');
      print('${thisturnMonster.name}의 턴');
      //몬스터의 방어력증가 처리
      monDefCounter++;
      if(monDefCounter % 3 == 0){
        thisturnMonster.defense += 2;
        print('${thisturnMonster.name}의 방어력이 증가했습니다! 현재 방어력: ${thisturnMonster.defense}');
        monDefCounter = 0;
      }
      //몬스터 데미지 메서드/상태메서드 호출
      damage = thisturnMonster.attackCharacter(character);
      character.showStatus();
      thisturnMonster.showStatus();
      //캐릭터와 몬스터 체력값 확인
      //캐릭터의 체력이 0이하일경우
      if (character.health <= 0) {
        //종료 후 게임시작메서드로 돌아감
        break;
      } else if (thisturnMonster.health <= 0) {
        //몬스터가 체력이 0이하일경우 리스트에서 삭제
        monsters.remove(thisturnMonster);
        //죽인 몬스터값 올리기
        killedMonsters++;
        //종료후 게임시작메서드로 돌아감
        break;
      }
    }
  }

  //랜덤으로 몬스터를 불러오는 메서드
  Monster getRandomMonster() {
    Random rand = Random(); //랜덤함수
    return monsters[rand.nextInt(monsters.length)];
  }
}

//추상화클래스 틀
abstract class Unit {
  String name;
  int health;
  int attack;
  int defense;
  Unit(this.name, this.health, this.attack, this.defense);

  //캐릭터 상태출력메서드
  showStatus() {
    print('$name - 체력: $health, 공격력: $attack, 방어력$defense');
  }
}

//Character클래스
class Character extends Unit {
  //Character(String name, int health, int attack, int defense) : super(name, health, attack, defense);
  Character(super.name, super.health, super.attack, super.defense);
  //아이템사용여부변수
  bool usedItem = true;
  //캐릭터 공격메서드
  attackMonster(Monster monster) {
    Random rand = Random(); //랜덤함수
    var thisAttack = rand.nextInt(attack); //랜덤한 공격력 추출
    
    print('현재공격: $thisAttack, 현재몬스터의 방어력: ${monster.defense}');

    thisAttack -= monster.defense; //공격력에서 캐릭터의 방어력을 뺌
    if (thisAttack <= 0) {
      thisAttack = 0; //캐릭터의 방어력을 뺀 값이 0이하면 0으로 만들기
    }
    
    monster.health -= thisAttack; //파라미터로 들어온 몬스터의 체력에서 깎음
    print('$name이가 ${monster.name}에게 $thisAttack의 데미지를 입혔습니다.');
  }

  //캐릭터 방어메서드
  defend(int damage) {
    health += damage;
    print('$name이가 방어태세를 취하여 $damage만큼 체력을 얻었습니다.');
  }

}

//Monster클래스
class Monster extends Unit {
  Monster(String name, int health, int attack)
    : super(name, health, attack, 0); // defense는 0으로 고정

  //몬스터 공격 메서드
  int attackCharacter(Character character) {
    Random rand = Random(); //랜덤함수
    var thisAttack = rand.nextInt(attack); //랜덤한 공격력 추출

    print('현재공격: $thisAttack, 현재캐릭터의 방어력: ${character.defense}');
    thisAttack -= character.defense; //공격력에서 캐릭터의 방어력을 뺌
    if (thisAttack <= 0) {
      thisAttack = 0; //캐릭터의 방어력을 뺀 값이 0이하면 0으로 만들기
    }

    

    character.health -= thisAttack; //파라미터로 들어온 캐릭터의 체력에서 깎음
    print('$name이가 ${character.name}에게 $thisAttack의 데미지를 입혔습니다.');
    //랜덤한 공격력을 리턴함
    return thisAttack;
  }

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
