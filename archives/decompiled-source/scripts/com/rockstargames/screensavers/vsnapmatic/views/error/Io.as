package com.rockstargames.screensavers.vsnapmatic.views.error
{
   import com.greensock.TweenMax;
   import com.patrickconroy.mvcframework.config.Memory;
   import com.patrickconroy.mvcframework.libs.view.View;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class Io extends View
   {
      
      private var noInternet:Class = Io_noInternet;
      
      private var img:DisplayObject;
      
      public function Io()
      {
         super();
      }
      
      override protected function init(param1:Event) : void
      {
         var timer:Timer;
         var e:Event = param1;
         super.init(e);
         this.img = new this.noInternet();
         addChild(this.img);
         timer = new Timer(10000);
         timer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
         {
            var e:TimerEvent = param1;
            TweenMax.to(img,0.3,{
               "alpha":0,
               "ease":"linear",
               "onComplete":function():void
               {
                  TweenMax.to(img,0.2,{
                     "delay":0.2,
                     "alpha":1,
                     "ease":"linear"
                  });
               }
            });
         });
         timer.start();
         this.resize(null);
      }
      
      override protected function resize(param1:Event) : void
      {
         super.resize(param1);
         if(this.img === null)
         {
            return;
         }
         this.img.x = (Memory.stage.stageWidth - this.img.width) * 0.5;
         this.img.y = (Memory.stage.stageHeight - this.img.height) * 0.5;
      }
   }
}

