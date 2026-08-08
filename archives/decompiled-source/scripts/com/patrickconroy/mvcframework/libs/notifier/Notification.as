package com.patrickconroy.mvcframework.libs.notifier
{
   import flash.events.Event;
   
   public class Notification extends Event
   {
      
      public var params:Array;
      
      public function Notification(param1:String, param2:Array = null)
      {
         super(param1,bubbles,cancelable);
         this.params = param2;
      }
   }
}

