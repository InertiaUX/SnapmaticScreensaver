package com.rockstargames
{
   public class VariableParser
   {
      
      public function VariableParser()
      {
         super();
      }
      
      public static function str_replace(param1:String, param2:String, param3:String) : String
      {
         var _loc4_:Array = param3.split(param1);
         return _loc4_.join(param2);
      }
   }
}

