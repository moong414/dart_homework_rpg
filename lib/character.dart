import 'dart:math';
import 'unit.dart';
import 'monster.dart';

//Character클래스
class Character extends Unit {
  //Character(String name, int health, int attack, int defense) : super(name, health, attack, defense);
  Character(super.name, super.health, super.attack, super.defense);
  //무기 아이템사용여부변수
  bool usedItem = true;
  //독 아이템 사용 여부 변수
  bool usedPoison = true;

  //캐릭터 공격메서드
  attackMonster(Monster monster) {
    Random rand = Random(); //랜덤함수
    var thisAttack = rand.nextInt(attack); //랜덤한 공격력 추출
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
