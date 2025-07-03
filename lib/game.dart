import 'dart:io';
import 'dart:math';
import 'character.dart';
import 'monster.dart';

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
      print('==========================================================================');
      print('🏆 ${character.name}(이/가) 몬스터와의 대결에서 승리했습니다! 🏆');
      print('🔥 다음 몬스터와 대결하시겠습니까? (y/n) 🔥');
      String inputAsk = stdin.readLineSync() ?? 'n';
      //결과값2: 몬스터와 재대결 n을 선택할 경우
      if (inputAsk == 'n') {
        return 2;
      }
      //독아이템사용-안함으로 변경
      character.usedPoison = true;
    }
  }

  //전투진행 메서드
  void battle() {
    //전투진행메서드: 게임시작 & 캐릭터 상태 출력
    print('==========================================================================');
    print('💥 게임을 시작합니다! 💥');
    //게임시작후 보너스체력 이벤트
    Random rand = Random();
    double chance = rand.nextDouble();
    if (chance < 0.3) {
      //30퍼센트 확률로 이벤트 발생
      character.health += 10;
      print('--------------------------------------------------------------------------');
      print('💪 보너스 체력을 얻었습니다! 현재 체력: ${character.health} 💪');
    }
    character.showStatus();
    //몬스터불러오기 메서트 호출 후 thisMonster객체에 전달 & 몬스터 상태 출력
    Monster thisturnMonster = getRandomMonster();
    print('==========================================================================');
    print('😈새로운 몬스터가 나타났습니다!😈');
    print(
      '${thisturnMonster.name} - 체력: ${thisturnMonster.health}, 공격력: ${thisturnMonster.attack}',
    );
    //몬스터가 입힐 데미지 변수
    int? damage;
    //몬스터 방어력 증가 확인 카운터
    int monDefCounter = 0;
    //독 아이템 공격력변수
    int thisPoison = 0;
    //전투진행메서드: 캐릭터의 턴
    while (true) {
      //캐릭터의 초기 공격력
      int originAttack = character.attack;
      //캐리ㅣ터의 턴('======================================================================');
      print('==========================================================================');
      print('🧝 ${character.name}의 턴 🧝');
      print('행동을 선택하세요 (1: 공격, 2: 방어, 3: 무기 아이템사용, 4: 독 아이템 사용)');
      print('==========================================================================');
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
        //무기아이템사용
        if(character.usedItem){
          character.attack *= 2;
          print('	🔫 ${character.name}(이/가) 무기 아이템을 사용하였습니다. 공격력이 2배가 됩니다. 현재공격력: ${character.attack} 🔫');
          character.usedItem = false;
        }else{
          print('이미 아이템을 사용하셨습니다!');
        }
        character.attackMonster(thisturnMonster);
        character.attack = originAttack;
      } else if (inputBattle == '4') {
        //독 아이템 사용
        if(character.usedPoison){
          thisPoison = rand.nextInt(5) + 1; 
          print('🧪 ${character.name}(이/가) 독 아이템을 사용하였습니다. 몬스터가 독에 걸렸습니다!! 🧪');
          character.usedPoison = false;
        }else{
          print('이미 아이템을 사용하셨습니다!');
        }
      }else {
        //공격&방어 외를 선택했을 경우→턴 넘어감
        print('입력값이 올바르지 않습니다!');
      }
      //독에 걸려있을경우
      if(character.usedPoison == false){
        print('--------------------------------------------------------------------------');
        thisturnMonster.health -= thisPoison;
        print('🧪 공격력: $thisPoison 의 독이 작용하고 있습니다! 현재 몬스터의 체력: ${thisturnMonster.health} 🧪');
      }
      //몬스터의 턴======================================================================
      print('==========================================================================');
      print('${thisturnMonster.name}의 턴');
      //몬스터의 방어력증가 처리
      monDefCounter++;
      if(monDefCounter % 3 == 0){
        thisturnMonster.defense += 2;
        print('🛡️ ${thisturnMonster.name}의 방어력이 증가했습니다! 현재 방어력: ${thisturnMonster.defense} 🛡️');
        monDefCounter = 0;
      }
      //몬스터 데미지 메서드/상태메서드 호출
      damage = thisturnMonster.attackCharacter(character);
      print('--------------------------------------------------------------------------');
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



