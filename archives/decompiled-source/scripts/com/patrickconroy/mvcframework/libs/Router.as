package com.patrickconroy.mvcframework.libs
{
   import com.patrickconroy.mvcframework.config.Paths;
   
   public class Router extends PObject
   {
      
      public function Router()
      {
         super();
      }
      
      public static function translateToTriad(param1:String) : Object
      {
         if(Paths.APPLICATION_PACKAGE === null)
         {
            throw new Error("Paths.APPLICATION_PACKAGE not set!!!");
         }
         var _loc2_:Object = new Object();
         var _loc3_:Array = param1.split("/");
         var _loc4_:Number = 0;
         var _loc5_:uint = 0;
         while(_loc5_ < _loc3_.length)
         {
            switch(_loc5_)
            {
               case 0:
                  _loc2_.Controller = Paths.APPLICATION_PACKAGE + ".controllers." + Inflector.camelize(_loc3_[_loc5_]) + "Controller";
                  break;
               case 1:
                  _loc2_.action = _loc3_[_loc5_];
                  break;
               default:
                  if(!_loc2_.params)
                  {
                     _loc2_.params = new Array();
                  }
                  _loc2_.params[_loc4_] = _loc3_[_loc5_];
                  _loc4_++;
            }
            _loc5_++;
         }
         return _loc2_;
      }
   }
}

