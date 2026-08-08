package com.patrickconroy.mvcframework.libs
{
   public class Inflector
   {
      
      public function Inflector()
      {
         super();
      }
      
      public static function camelize(param1:String) : String
      {
         var _loc2_:String = param1.charAt(0);
         var _loc3_:String = param1.slice(1,param1.length);
         return _loc2_.toUpperCase() + _loc3_;
      }
   }
}

