package com.patrickconroy.mvcframework.libs.view
{
   import com.patrickconroy.mvcframework.config.Config;
   import com.patrickconroy.mvcframework.config.Memory;
   import com.patrickconroy.mvcframework.libs.notifier.Notifier;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class Layout extends View
   {
      
      public function Layout()
      {
         super();
      }
      
      override protected function init(param1:Event) : void
      {
         super.init(param1);
      }
      
      override public function mouseOut(param1:MouseEvent) : void
      {
         super.mouseOut(param1);
         Notifier.notify(Memory.application,Config.APP_MOUSE_OUT);
      }
      
      override public function mouseOver(param1:MouseEvent) : void
      {
         super.mouseOver(param1);
         Notifier.notify(Memory.application,Config.APP_MOUSE_OVER);
      }
      
      override public function get width() : Number
      {
         if(this.mask != null)
         {
            return this.mask.width;
         }
         return super.width;
      }
      
      override public function get height() : Number
      {
         if(this.mask != null)
         {
            return this.mask.height;
         }
         return super.height;
      }
   }
}

