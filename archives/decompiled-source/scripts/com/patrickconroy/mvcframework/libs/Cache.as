package com.patrickconroy.mvcframework.libs
{
   import com.patrickconroy.mvcframework.config.Memory;
   
   public class Cache extends PObject
   {
      
      public static var dump:Object = {};
      
      public function Cache()
      {
         super();
      }
      
      public static function setup(param1:Function) : void
      {
         Cache.dump[Memory.get("CACHE_KEY")] = {};
         if(param1 != null)
         {
            param1();
         }
      }
      
      public static function set(param1:String, param2:*) : void
      {
         Cache.dump[Memory.get("CACHE_KEY")][param1] = param2;
      }
      
      public static function get(param1:String) : *
      {
         var key:String = param1;
         try
         {
            return Cache.dump[Memory.get("CACHE_KEY")][key];
         }
         catch(e:Error)
         {
            return null;
         }
      }
   }
}

