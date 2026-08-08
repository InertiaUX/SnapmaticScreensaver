package display
{
   import events.display.LoadStackEvent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.StyleSheet;
   import net.FontLoader;
   
   public dynamic class LoadStack extends MovieClip
   {
      
      public var queue:Array = [];
      
      public var index:Number = 0;
      
      public var _loader:*;
      
      public var type:String;
      
      private var context:LoaderContext;
      
      public function LoadStack()
      {
         super();
         this.reset();
      }
      
      public function reset() : void
      {
         this.queue = new Array();
         this.index = 0;
      }
      
      public function addToLoader(param1:String, param2:Object) : void
      {
         var _loc3_:Object = param2;
         this.queue.push([param1,_loc3_]);
      }
      
      public function init() : void
      {
         this.load();
      }
      
      public function setFonts(param1:XMLList) : void
      {
         var _loc2_:uint = 0;
         while(_loc2_ < param1.font.length())
         {
            this.addToLoader(param1.font[_loc2_].@src,{"type":"font"});
            _loc2_++;
         }
      }
      
      public function setCSS(param1:StyleSheet, param2:XMLList) : void
      {
         var _loc3_:Object = null;
         var _loc6_:uint = 0;
         var _loc4_:String = "";
         var _loc5_:uint = 0;
         while(_loc5_ < param2.style.length())
         {
            _loc3_ = new Object();
            _loc6_ = 0;
            while(_loc6_ < param2.style[_loc5_].attribute.length())
            {
               _loc4_ = param2.style[_loc5_].attribute[_loc6_].@name;
               _loc3_[_loc4_] = param2.style[_loc5_].attribute[_loc6_].@value;
               _loc6_++;
            }
            param1.setStyle(param2.style[_loc5_].@name,_loc3_);
            _loc5_++;
         }
      }
      
      public function load() : void
      {
         var request:URLRequest;
         if(this.queue.length === 0)
         {
            this.allDone();
            return;
         }
         request = new URLRequest(this.queue[this.index][0]);
         this.context = new LoaderContext();
         this.context.checkPolicyFile = true;
         switch(this.queue[this.index][1].type)
         {
            case "css":
               this._loader = new URLLoader();
               this._loader.load(request);
               this._loader.addEventListener(Event.COMPLETE,this.done);
               break;
            case "xml":
               this._loader = new URLLoader();
               this._loader.dataFormat = URLLoaderDataFormat.TEXT;
               this._loader.load(request);
               this._loader.addEventListener(Event.COMPLETE,this.done);
               break;
            case "font":
               this._loader = new FontLoader();
               this._loader.load(request);
               this._loader.addEventListener(Event.COMPLETE,this.done);
               break;
            case "tlad_bitmap":
            case "bmp":
               this._loader = new Loader();
               this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.done);
               this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.skip);
               this._loader.load(request,this.context);
               break;
            case "swf":
               this._loader = new Loader();
               this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.skip);
               this._loader.load(request,this.context);
               this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.done);
               this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.progress);
               break;
            default:
               this._loader = new Loader();
               this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.skip);
               try
               {
                  this._loader.load(request,this.context);
               }
               catch(error:Error)
               {
               }
               this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.done);
               this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.progress);
         }
      }
      
      private function skip(param1:IOErrorEvent) : void
      {
         this.queue[this.index][0] = "http://media.rockstargames.com/products/rockstar/media%20player/assets/images/404-mcla.jpg?";
         this.load();
      }
      
      private function progress(param1:ProgressEvent) : void
      {
         dispatchEvent(new LoadStackEvent(LoadStackEvent.ThingLoading,this._loader,this.queue[this.index][2],this.queue[this.index][1].type,null,param1.bytesLoaded,param1.bytesTotal));
      }
      
      private function done(param1:Event) : void
      {
         var _loc2_:Bitmap = null;
         var _loc3_:BitmapData = null;
         switch(this.queue[this.index][1].type)
         {
            case "tlad_bitmap":
            case "bitmap":
            case "bmp":
               _loc3_ = new BitmapData(this._loader.width,this._loader.height,true,16777215);
               _loc3_.draw(this._loader);
         }
         dispatchEvent(new LoadStackEvent(LoadStackEvent.ThingLoaded,this._loader,this.queue[this.index][1].target,this.queue[this.index][1].type,_loc3_,0,0,param1));
         ++this.index;
         if(this.queue.length == this.index)
         {
            this.allDone();
         }
         else
         {
            this.load();
         }
      }
      
      private function allDone() : void
      {
         this.reset();
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

