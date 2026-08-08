package com.rockstargames.screensavers.vsnapmatic.events
{
   import flash.events.Event;
   
   public class SnapImageEvent extends Event
   {
      
      public static const INCREMENT:String = "increment";
      
      public static const UPDATE_INDEX:String = "update index";
      
      public function SnapImageEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

