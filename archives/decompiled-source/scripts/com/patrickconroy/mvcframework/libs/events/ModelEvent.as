package com.patrickconroy.mvcframework.libs.events
{
   import flash.events.Event;
   
   public class ModelEvent extends Event
   {
      
      public static const DATA_SET:String = "DATA_SET";
      
      public var data:*;
      
      public function ModelEvent(param1:String, param2:* = null, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.data = param2;
      }
   }
}

