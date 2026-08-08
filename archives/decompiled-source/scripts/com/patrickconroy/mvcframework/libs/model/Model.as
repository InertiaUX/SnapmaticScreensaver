package com.patrickconroy.mvcframework.libs.model
{
   import com.adobe.serialization.json.JSON;
   import com.gsolo.encryption.MD5;
   import com.patrickconroy.mvcframework.config.Memory;
   import com.patrickconroy.mvcframework.libs.Cache;
   import com.patrickconroy.mvcframework.libs.Overloadable;
   import com.patrickconroy.mvcframework.libs.events.AMFEvent;
   import com.patrickconroy.mvcframework.libs.events.ModelEvent;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
   public class Model extends Overloadable
   {
      
      public var type:String = "";
      
      private var _started:Boolean = false;
      
      private var _data:Array = new Array();
      
      public var AMF:Object = {};
      
      public var settings:Object = {};
      
      public var URL:String;
      
      public var data:Object = {};
      
      public function Model()
      {
         super();
      }
      
      public function init() : void
      {
         if(this._started)
         {
            return;
         }
         this._started = true;
      }
      
      public function find(param1:Object = null) : void
      {
         this.beforeFind(param1);
         var _loc2_:String = MD5.encrypt(this.toRealString(param1));
         var _loc3_:XML = this.getDataByKey(_loc2_);
         if(_loc3_ != null)
         {
            dispatchEvent(new ModelEvent(ModelEvent.DATA_SET,_loc3_));
            return;
         }
         switch(this.type)
         {
            case "URL":
               this.setLoaderForURL(this.settings.URL);
               break;
            case "AMF":
               this.setAMFConnection(_loc2_,this.mergeObjects(param1,this.AMF),param1.conditions,param1.filter);
               break;
            case "Bitmap":
               this.setLoaderForBitmap(param1.conditions[0]);
         }
      }
      
      protected function setAMFConnection(param1:String, param2:Object, param3:Array = null, param4:Object = null) : AMFConnector
      {
         var _loc5_:AMFConnector = new AMFConnector(param1,param2,param3,param4);
         _loc5_.addEventListener(AMFEvent.AMFComplete,this._amfComplete);
         _loc5_.connect();
         if(!_loc5_)
         {
            return null;
         }
         return _loc5_;
      }
      
      protected function setLoaderForURL(param1:String) : *
      {
         if(Memory.getURL(param1))
         {
            return dispatchEvent(new ModelEvent(ModelEvent.DATA_SET,Memory.getURL(param1)));
         }
         var _loc2_:LoaderContext = new LoaderContext(true);
         var _loc3_:XURLLoader = new XURLLoader();
         _loc3_.URL = param1;
         var _loc4_:URLRequest = new URLRequest(param1);
         _loc3_.addEventListener(Event.COMPLETE,this._loaderCompleteURL);
         _loc3_.addEventListener(IOErrorEvent.IO_ERROR,this._loaderError);
         _loc3_.load(_loc4_);
      }
      
      protected function setLoaderForBitmap(param1:String) : *
      {
         if(Memory.getBitmap(param1))
         {
            return dispatchEvent(new ModelEvent(ModelEvent.DATA_SET,Memory.getBitmap(param1)));
         }
         var _loc2_:LoaderContext = new LoaderContext(true);
         var _loc3_:Loader = new Loader();
         var _loc4_:URLRequest = new URLRequest(param1);
         _loc3_.contentLoaderInfo.addEventListener(Event.COMPLETE,this._loaderCompleteBitmap);
         _loc3_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this._loaderError);
         _loc3_.load(_loc4_,_loc2_);
      }
      
      private function _amfComplete(param1:AMFEvent) : void
      {
         param1.data.@key = param1.dataKey;
         this.setData(param1.dataKey,param1.data);
         this.afterFind(param1.data);
         dispatchEvent(new ModelEvent(ModelEvent.DATA_SET,this.getDataByKey(param1.dataKey)));
      }
      
      protected function afterFind(param1:*) : void
      {
      }
      
      protected function beforeFind(param1:Object) : void
      {
      }
      
      private function _loaderCompleteURL(param1:Event) : void
      {
         var data:* = undefined;
         var e:Event = param1;
         var url:String = XURLLoader(e.currentTarget).URL;
         switch(String(this.settings.TYPE))
         {
            case "json":
               try
               {
                  data = com.adobe.serialization.json.JSON.decode(e.currentTarget.data);
               }
               catch(e:Error)
               {
               }
         }
         Memory.setURL(url,data);
         this.afterFind(data);
         dispatchEvent(new ModelEvent(ModelEvent.DATA_SET,data));
      }
      
      private function _loaderCompleteBitmap(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.currentTarget as LoaderInfo;
         var _loc3_:BitmapData = new BitmapData(_loc2_.content.width,_loc2_.content.height,true,16777215);
         _loc3_.draw(_loc2_.content);
         Memory.setBitmap(_loc2_.url,_loc3_);
         dispatchEvent(new ModelEvent(ModelEvent.DATA_SET,_loc3_));
      }
      
      private function _loaderError(param1:IOErrorEvent) : void
      {
         var _loc2_:String = XURLLoader(param1.currentTarget).URL;
         var _loc3_:* = this.settings.FALLBACK;
         if(_loc3_ !== undefined)
         {
            Memory.setURL(_loc2_,_loc3_);
            this.afterFind(_loc3_);
            dispatchEvent(new ModelEvent(ModelEvent.DATA_SET,_loc3_));
         }
      }
      
      private function setData(param1:String, param2:*) : *
      {
         this._data[param1] = param2;
         Cache.set(param1,param2);
         return param2;
      }
      
      public function getDataByKey(param1:String) : XML
      {
         if(Cache.get(param1) != null)
         {
            return Cache.get(param1);
         }
         return this._data[param1];
      }
   }
}

