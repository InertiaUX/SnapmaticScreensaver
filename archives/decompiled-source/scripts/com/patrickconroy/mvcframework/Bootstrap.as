package com.patrickconroy.mvcframework
{
   import com.asual.swfaddress.SWFAddress;
   import com.asual.swfaddress.SWFAddressEvent;
   import com.patrickconroy.mvcframework.config.AppWide;
   import com.patrickconroy.mvcframework.config.Config;
   import com.patrickconroy.mvcframework.config.Memory;
   import com.patrickconroy.mvcframework.libs.Cache;
   import com.patrickconroy.mvcframework.libs.Registry;
   import com.patrickconroy.mvcframework.libs.notifier.Notifier;
   import com.rockstargames.VariableParser;
   import display.LoadStack;
   import events.display.LoadStackEvent;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class Bootstrap extends AppWide
   {
      
      public static const CONFIG:String = "config";
      
      protected var japanFontNeeded:Boolean = false;
      
      public var _swfaddress:Boolean;
      
      private var _callback:Function;
      
      private var configFallbackTried:Boolean = false;
      
      public function Bootstrap()
      {
         super();
      }
      
      public function boot(param1:Application, param2:Function) : void
      {
         this._callback = param2;
         Memory.application = param1;
         Registry.setup();
         Cache.setup(this._cacheReady);
      }
      
      private function _cacheReady() : void
      {
         if(Cache.get("config") != undefined)
         {
            return this._setConfig(Cache.get("config"));
         }
         if(Memory.get(Bootstrap.CONFIG) != Bootstrap.CONFIG && Memory.get(Bootstrap.CONFIG) !== undefined)
         {
            this.loadConfig(Memory.get(Bootstrap.CONFIG));
         }
         else
         {
            this._booted(null);
         }
      }
      
      private function loadConfig(param1:String) : void
      {
         var url:String = param1;
         var u:URLLoader = new URLLoader();
         var request:URLRequest = new URLRequest(url);
         u.addEventListener(Event.COMPLETE,function(param1:Event):void
         {
            _setConfig(new XML(param1.currentTarget.data));
         });
         u.addEventListener(IOErrorEvent.IO_ERROR,function(param1:IOErrorEvent):void
         {
            if(configFallbackTried)
            {
               return;
            }
            var _loc2_:String = Memory.get(Bootstrap.CONFIG + "_fallback");
            if(_loc2_ !== null)
            {
               loadConfig(_loc2_);
               configFallbackTried = true;
               return;
            }
            return _booted(null,false);
         });
         u.load(request);
      }
      
      protected function _setConfig(param1:XML) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc6_:Object = null;
         var _loc7_:uint = 0;
         Memory.config = param1;
         Cache.set("config",Memory.config);
         this.removeEventListener(Event.COMPLETE,this._setConfig);
         var _loc2_:LoadStack = new LoadStack();
         _loc2_.addEventListener(Event.COMPLETE,this._booted);
         _loc2_.addEventListener(LoadStackEvent.ThingLoaded,this.loadStackThingLoaded);
         var _loc5_:uint = 0;
         while(_loc5_ < Memory.config.bitmaps.bitmap.length())
         {
            _loc4_ = String(Memory.config.bitmaps.bitmap[_loc5_].@id);
            if(!Memory.bitmapExists(_loc4_))
            {
               _loc3_ = String(Memory.config.bitmaps.bitmap[_loc5_].@src);
               _loc3_ = VariableParser.str_replace("{root}",String(Memory.config.bitmaps.@root),_loc3_);
               _loc3_ = VariableParser.str_replace("{skin}",String(Memory.get("skin")),_loc3_);
               _loc3_ = VariableParser.str_replace("{size}",String(Memory.get(Config.SIZE)),_loc3_);
               _loc3_ = VariableParser.str_replace("{locale}",String(Memory.get(Config.LOCALE)),_loc3_);
               _loc2_.addToLoader(_loc3_,{
                  "type":"bmp",
                  "target":_loc4_
               });
            }
            _loc5_++;
         }
         Memory.css.parseCSS(Memory.config.css);
         if(this.japanFontNeeded)
         {
            delete XMLList(Memory.config.fonts).font;
            XMLList(Memory.config.fonts).appendChild(XML(<font src='http://media.rockstargames.com/fonts/JPfont2.swf'/>));
            _loc7_ = 0;
            while(_loc7_ < Memory.css.styleNames.length)
            {
               _loc6_ = Memory.css.getStyle(Memory.css.styleNames[_loc7_]);
               if(_loc6_.fontFamily != null)
               {
                  _loc6_.fontFamily = "Hiragino Maru Gothic Pro W4";
                  Memory.css.setStyle(Memory.css.styleNames[_loc7_],_loc6_);
               }
               _loc7_++;
            }
         }
         _loc2_.setFonts(Memory.config.fonts);
         _loc2_.init();
      }
      
      private function loadStackThingLoaded(param1:LoadStackEvent) : void
      {
         switch(param1._type)
         {
            case "bmp":
               Memory.setBitmap(param1._target,param1._bitmap);
         }
      }
      
      public function setStage(param1:Stage, param2:String, param3:String, param4:Number) : void
      {
         Memory.stage = param1;
         Memory.stage.scaleMode = param2;
         Memory.stage.align = param3;
         Memory.stage.frameRate = param4;
      }
      
      public function set swfaddress(param1:Boolean) : void
      {
         this._swfaddress = param1;
         SWFAddress.removeEventListener(SWFAddressEvent.EXTERNAL_CHANGE,this._swfAddressChange);
         SWFAddress.removeEventListener(SWFAddressEvent.INTERNAL_CHANGE,this._swfAddressChange);
         SWFAddress.removeEventListener(SWFAddressEvent.CHANGE,this._swfAddressChange);
         SWFAddress.addEventListener(SWFAddressEvent.EXTERNAL_CHANGE,this._swfAddressChange);
         SWFAddress.addEventListener(SWFAddressEvent.INTERNAL_CHANGE,this._swfAddressChange);
         SWFAddress.addEventListener(SWFAddressEvent.CHANGE,this._swfAddressChange);
      }
      
      public function get swfaddress() : Boolean
      {
         return this._swfaddress;
      }
      
      private function _swfAddressChange(param1:SWFAddressEvent) : void
      {
         Notifier.notify(Memory.application,"SWFAddressEvent",[param1]);
      }
      
      private function _booted(param1:Event, param2:Boolean = true) : void
      {
         this._callback(param2);
      }
   }
}

