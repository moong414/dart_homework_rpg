import 'dart:convert';
import 'dart:io';
import 'package:dart_homework_rpg/game.dart';
import 'package:dart_homework_rpg/monster.dart';
import 'package:dart_homework_rpg/loader.dart';

void main() {
  List<Monster> monsters = loadMonsterStats();
  int killedMonsters = 0;
  Game game = Game(monsters, killedMonsters);
  File file = File('data/result.txt');

  print('🧝 캐릭터의 이름을 입력하세요! 🧝');
  //이름: 입력받기
  String inputName = stdin.readLineSync(encoding: Encoding.getByName('utf-8')!) ?? '이름없음';
  //이름: 정규표현식 검사
  RegExp nameReg = RegExp(r'^[a-zA-Z가-힣]+$');

  //정규표현식에 맞으면 게임시작
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
        print('💀 캐릭터의 체력이 0이 되었습니다. 게임을 종료합니다. 💀');
        winOrLose = '패';
        break;
      //결과값2: 게임 종료 처리
      case 2:
        print('🏳️ 게임을 종료합니다. 🏳️');
        winOrLose = '기권';
        break;
      //결과값2: 몬스터를 전부 물리쳤을때 처리
      case 3:
        print(r'''
          ╔═══════════════════════════════╗
          ║ 🎉 게임에서 승리하셨습니다! 🎉║
          ╚═══════════════════════════════╝
                    ＼(＾▽＾)／
          ''');

        print('🏆 게임을 종료합니다. 🏆');
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


