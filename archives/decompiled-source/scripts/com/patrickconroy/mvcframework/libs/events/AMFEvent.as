package com.patrickconroy.mvcframework.libs.events
{
   import flash.events.Event;
   
   public class AMFEvent extends Event
   {
      
      public static const AMFComplete:String = "AMFComplete";
      
      public static const AMFError:String = "AMFError";
      
      public var data:*;
      
      public var dataKey:String;
      
      public function AMFEvent(param1:String, param2:*, param3:String, param4:Boolean = false, param5:Boolean = false)
      {
         super(param1,param4,param5);
         this.data = param2;
         this.dataKey = param3;
      }
   }
}

