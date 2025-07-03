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