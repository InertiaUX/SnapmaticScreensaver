package com.patrickconroy.mvcframework.libs
{
   import com.patrickconroy.mvcframework.config.Memory;
   import flash.display.Sprite;
   import flash.external.ExternalInterface;
   
   public dynamic class PObject extends Sprite
   {
      
      private var arrListeners:Array = new Array();
      
      public var props:Object = {};
      
      public function PObject()
      {
         super();
      }
      
      public function debug(param1:Object) : void
      {
         var _loc2_:* = undefined;
         for(_loc2_ in param1)
         {
         }
      }
      
      public function log(param1:*) : void
      {
         ExternalInterface.call("console.log",param1);
      }
      
      public function mergeObjects(param1:Object, param2:Object) : Object
      {
         var _loc4_:* = undefined;
         var _loc3_:Object = {};
         for(_loc4_ in param1)
         {
            _loc3_[_loc4_] = param1[_loc4_];
         }
         for(_loc4_ in param2)
         {
            _loc3_[_loc4_] = param2[_loc4_];
         }
         return _loc3_;
      }
      
      public function toRealString(param1:Object) : String
      {
         var _loc3_:* = undefined;
         var _loc2_:String = "";
         for(_loc3_ in param1)
         {
            _loc2_ += _loc3_ + ":" + param1[_loc3_];
         }
         return _loc2_;
      }
      
      public function listenForNotification(param1:String, param2:Function) : void
      {
         this.addEventListener(param1,param2);
      }
      
      public function stopListeningForNotification(param1:String, param2:Function) : void
      {
         var _loc3_:Number = NaN;
         if(this.arrListeners !== null)
         {
            _loc3_ = 0;
            while(_loc3_ < this.arrListeners.length)
            {
               if(this.arrListeners[_loc3_].type === param1 && this.arrListeners[_loc3_].listener === param2)
               {
                  this.arrListeners[_loc3_].listener = null;
               }
               _loc3_++;
            }
         }
         super.removeEventListener(param1,param2);
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         super.addEventListener(param1,param2,param3,param4,true);
         if(this.arrListeners == null)
         {
            this.arrListeners = new Array();
         }
         this.arrListeners.push({
            "type":param1,
            "listener":param2
         });
      }
      
      private function _clearAllEvents() : void
      {
         if(this.arrListeners == null)
         {
            return;
         }
         var _loc1_:Number = 0;
         while(_loc1_ < this.arrListeners.length)
         {
            this.removeEventListener(this.arrListeners[_loc1_].type,this.arrListeners[_loc1_].listener);
            _loc1_++;
         }
         this.arrListeners = null;
      }
      
      public function reset() : void
      {
         this._clearAllEvents();
      }
      
      public function requestAction(param1:String) : *
      {
         return Memory.application.dispatcher._requestAction(param1,this);
      }
   }
}

