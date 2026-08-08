package com.patrickconroy.mvcframework.libs
{
   import flash.display.Sprite;
   
   public class Registry extends Sprite
   {
      
      public static var CONTROLLER:String = "controller_";
      
      public static var MODEL:String = "model_";
      
      private static var _objects:Object = {};
      
      public function Registry()
      {
         super();
      }
      
      public static function setup() : void
      {
      }
      
      public static function getObject(param1:String = "") : *
      {
         var _loc2_:* = _objects[param1];
         if(!_loc2_)
         {
            return null;
         }
         return _loc2_;
      }
      
      public static function setObject(param1:Object, param2:String) : *
      {
         return _objects[param2] = param1;
      }
      
      public static function removeObject(param1:String) : void
      {
         var _loc2_:Object = _objects[param1];
         if(_loc2_ === null)
         {
            return;
         }
         _loc2_ = null;
      }
   }
}

