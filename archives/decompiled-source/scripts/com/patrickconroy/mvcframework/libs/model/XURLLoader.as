package com.patrickconroy.mvcframework.libs.model
{
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class XURLLoader extends URLLoader
   {
      
      public var URL:String = "";
      
      public function XURLLoader(param1:URLRequest = null)
      {
         super(param1);
      }
   }
}

