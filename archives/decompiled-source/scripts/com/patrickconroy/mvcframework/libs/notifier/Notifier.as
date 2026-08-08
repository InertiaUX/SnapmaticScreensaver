package com.patrickconroy.mvcframework.libs.notifier
{
   import flash.events.EventDispatcher;
   
   public class Notifier extends EventDispatcher
   {
      
      public function Notifier()
      {
         super();
      }
      
      public static function notify(param1:*, param2:String, param3:Array = null) : void
      {
         if(param1 == null)
         {
            return;
         }
         param1.dispatchEvent(new Notification(param2,param3));
      }
   }
}

