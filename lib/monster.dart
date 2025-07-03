import 'dart:math';
import 'unit.dart';
import 'character.dart';

//Monster클래스
class Monster extends Unit {
  Monster(String name, int health, int attack)
    : super(name, health, attack, 0); // defense는 0으로 고정

  //몬스터 공격 메서드
  int attackCharacter(Character character) {
    Random rand = Random(); //랜덤함수
    var thisAttack = rand.nextInt(attack); //랜덤한 공격력 추출
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

