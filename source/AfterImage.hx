//all credits to nebula for doing this!! very cool person go check them out
//also modified this a bit to look more like the original (and be compatible with already added characters)
package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;

class AfterImage extends FlxSprite {
  public function new(character:Character){
    super();

    frames = character.frames;
    var curAnim = character.animation.curAnim;
    alpha = .5;
    setGraphicSize(Std.int(character.width),Std.int(character.height));
    scrollFactor.set(character.scrollFactor.x,character.scrollFactor.y);
    updateHitbox();
    animation.add("current",curAnim.frames,0,false);
    flipX = character.flipX;
    flipY = character.flipY;
    animation.play('current',true);
    animation.curAnim.curFrame=curAnim.curFrame;
    x = character.x + FlxG.random.int(-30, 50);
    y = character.y + FlxG.random.int(-30, 50);
    offset.x = character.offset.x;
    offset.y = character.offset.y;
    antialiasing = true;
    switch(character.curCharacter)
    {
      case 'gf' | 'gf-christmas' | 'gf-car' | 'gf-pixel':
        color = 0xFFa5004d;
      case 'dad':
        color = 0xFFaf66ce;
      case 'spooky':
        color = 0xFFd57e00;
      case 'mom' | 'mom-car':
        color = 0xFFd8558e;
      case 'monster' | 'monster-christmas':
        color = 0xFFf3ff6e;
      case 'pico':
        color =  0xFFb7d855;
      case 'bf' | 'bf-car' | 'bf-christmas':
        color = 0xFF31b0d1;
      case 'bf-pixel':
        color = 0xFF7bd6f6;
      case 'senpai' | 'senpai-angry':
        color = 0xFFffaa6f;
      case 'spirit':
        color = 0xFFff3c6e;
      case 'parents-christmas':
        color = 0xFFc555d7;
      case 'sarvente':
        color = 0xFFf691c5; 
      case 'sarvente-dark':
        color = 0xFFff60b2;
      case 'ruv':
        color = 0xFF978aa6;
      case 'sarvente-lucifer':
        color = 0xFFda317d;
      case 'selever':
        color = 0xFF972651;
      default:
        color = 0xAAAAAA;
    }

    var increment = FlxG.random.float(.075,.1);
    new FlxTimer().start(.025, function(tmr:FlxTimer)
    {
      alpha -= increment;
      if(alpha>0){
        tmr.reset(.025);
      }else{
        kill();
        destroy();
      }
    });


  }
}
