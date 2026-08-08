package com.patrickconroy.mvcframework
{
   import com.patrickconroy.mvcframework.libs.Platform;
   import com.patrickconroy.mvcframework.libs.UIObject;
   
   public dynamic class Application extends UIObject
   {
      
      public var platform:Platform = new Platform();
      
      public var dispatcher:Dispatcher = new Dispatcher();
      
      public function Application()
      {
         super();
      }
   }
}

