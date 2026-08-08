package com.patrickconroy.mvcframework.libs.events
{
   import com.patrickconroy.mvcframework.libs.controller.AppController;
   import flash.events.Event;
   
   public class DispatchEvent extends Event
   {
      
      public static const DISPATCHED:String = "DISPATCHED";
      
      public static const ACTION_RENDERED:String = "ACTION_RENDERED";
      
      public var url:Object;
      
      public var controller:AppController;
      
      public function DispatchEvent(param1:String, param2:Object = null, param3:AppController = null, param4:Boolean = false, param5:Boolean = false)
      {
         super(param1,param4,param5);
         this.url = param2;
         this.controller = param3;
      }
   }
}

