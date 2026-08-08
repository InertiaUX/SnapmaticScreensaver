package com.patrickconroy.mvcframework.libs.events
{
   import flash.events.Event;
   
   public class ControllerEvent extends Event
   {
      
      public static const MODELS_LOADED:String = "MODELS_LOADED";
      
      public static const RENDERED:String = "RENDERED";
      
      public function ControllerEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

