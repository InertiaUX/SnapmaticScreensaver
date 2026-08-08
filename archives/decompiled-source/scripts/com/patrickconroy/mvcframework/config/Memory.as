package com.patrickconroy.mvcframework.config
{
   import com.patrickconroy.mvcframework.Application;
   import com.patrickconroy.mvcframework.libs.Cache;
   import com.patrickconroy.mvcframework.libs.PObject;
   import flash.display.BitmapData;
   import flash.display.Stage;
   import flash.geom.Rectangle;
   import flash.text.StyleSheet;
   import flash.utils.getQualifiedClassName;
   
   public class Memory extends PObject
   {
      
      private static var _application:Application;
      
      private static var _config:XML;
      
      private static var _stage:Stage;
      
      private static const BITMAP_KEY:String = "bitmapID";
      
      private static const DICT_KEY:String = "Dictionary_";
      
      private static var _bitmaps:Array = new Array();
      
      private static var _urls:Array = new Array();
      
      private static var _dictionary:Array = new Array();
      
      private static var _css:StyleSheet = new StyleSheet();
      
      private static var _items:Object = new Object();
      
      public function Memory()
      {
         super();
      }
      
      public static function get(param1:String) : *
      {
         return Memory._items[param1];
      }
      
      public static function set(param1:String, param2:*) : *
      {
         Memory._items[param1] = param2;
         return param2;
      }
      
      public static function __CACHE_getBitmap(param1:String) : BitmapData
      {
         var _loc6_:uint = 0;
         var _loc2_:Object = Cache.get(Memory.BITMAP_KEY + param1);
         if(_loc2_ == null)
         {
            return null;
         }
         return null;
      }
      
      public static function __CACHE__setBitmap(param1:String, param2:BitmapData) : void
      {
         Memory._bitmaps[param1] = {
            "w":param2.width,
            "h":param2.height,
            "p":param2.getPixels(new Rectangle(0,0,param2.width,param2.height))
         };
         Cache.set(Memory.BITMAP_KEY + param1,Memory._bitmaps[param1]);
      }
      
      public static function getBitmap(param1:String) : BitmapData
      {
         return Memory._bitmaps[param1];
      }
      
      public static function getURL(param1:String) : *
      {
         return Memory._urls[param1];
      }
      
      public static function bitmapExists(param1:String) : Boolean
      {
         if(Cache.get(Memory.BITMAP_KEY + param1) != undefined)
         {
            return true;
         }
         return false;
      }
      
      public static function setBitmap(param1:String, param2:BitmapData) : void
      {
         Memory._bitmaps[param1] = param2;
      }
      
      public static function setURL(param1:String, param2:*) : void
      {
         Memory._urls[param1] = param2;
      }
      
      public static function deleteURL(param1:String) : void
      {
         delete Memory._urls[param1];
      }
      
      public static function getPhrase(param1:String) : String
      {
         if(Memory._dictionary[param1] != null)
         {
            return Memory._dictionary[param1];
         }
         return param1;
      }
      
      public static function setPhrase(param1:String, param2:String) : void
      {
         Memory._dictionary[param1] = param2;
      }
      
      public static function set application(param1:Application) : void
      {
         Paths.APPLICATION_PACKAGE = getQualifiedClassName(param1).split("::")[0];
         Memory._application = param1;
      }
      
      public static function get application() : Application
      {
         return Memory._application;
      }
      
      public static function get css() : StyleSheet
      {
         return Memory._css;
      }
      
      public static function set config(param1:XML) : void
      {
         Memory._config = param1;
      }
      
      public static function get config() : XML
      {
         return Memory._config;
      }
      
      public static function set stage(param1:Stage) : void
      {
         Memory._stage = param1;
      }
      
      public static function get stage() : Stage
      {
         return Memory._stage;
      }
   }
}

