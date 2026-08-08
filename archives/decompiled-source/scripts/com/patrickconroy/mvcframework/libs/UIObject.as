package com.patrickconroy.mvcframework.libs
{
   import com.patrickconroy.mvcframework.config.Memory;
   import com.patrickconroy.mvcframework.libs.notifier.Notifier;
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import net.PopupWin;
   
   public class UIObject extends PObject
   {
      
      public static const INIT:String = "init";
      
      private var _config:XMLList;
      
      public var _bitmap:XMLList;
      
      private var _properties:XMLList;
      
      public var onStage:Boolean;
      
      public var hovering:Boolean = false;
      
      public var shouldClear:Boolean = true;
      
      public function UIObject()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.init);
      }
      
      protected function init(param1:Event) : void
      {
         this.onStage = true;
         removeEventListener(Event.ADDED_TO_STAGE,this.init);
         addEventListener(Event.REMOVED_FROM_STAGE,this.kill);
         addEventListener(MouseEvent.ROLL_OVER,this.mouseOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.mouseOut);
         addEventListener(MouseEvent.CLICK,this.mouseClick);
         stage.addEventListener(Event.RESIZE,this.resize);
         if(this._bitmap != null)
         {
            this.mouseOut(null);
         }
         this.setProperties();
         Notifier.notify(this,UIObject.INIT);
         this.resize(null);
      }
      
      public function setProperties() : void
      {
         var _loc2_:String = null;
         var _loc3_:* = undefined;
         if(this._properties == null)
         {
            return;
         }
         var _loc1_:XMLList = this._properties.attributes();
         var _loc4_:uint = 0;
         while(_loc4_ < _loc1_.length())
         {
            _loc2_ = _loc1_[_loc4_].name();
            _loc3_ = _loc1_[_loc4_];
            if(this._hasOwnProperty(_loc2_))
            {
               this[_loc2_.toString()] = _loc3_;
            }
            _loc4_++;
         }
      }
      
      public function clearObject(param1:*) : void
      {
         var _loc2_:* = undefined;
         try
         {
            while(param1.numChildren)
            {
               _loc2_ = param1.getChildAt(0);
               if(_loc2_.numChildren > 0)
               {
                  this.clearObject(_loc2_);
               }
               param1.removeChild(_loc2_);
            }
         }
         catch(e:ReferenceError)
         {
         }
      }
      
      protected function updateBitmap(param1:Number = 0, param2:Number = 0, param3:Number = 0, param4:Number = 0, param5:BitmapData = null, param6:Boolean = false) : void
      {
         var _loc7_:Matrix = new Matrix();
         _loc7_.tx = param1;
         _loc7_.ty = param2;
         this.graphics.clear();
         this.graphics.beginBitmapFill(param5,_loc7_,param6,true);
         this.graphics.drawRect(0,0,param3,param4);
      }
      
      public function centerChildren() : void
      {
         var _loc2_:* = undefined;
         var _loc1_:UIObject = new UIObject();
         _loc1_.name = "graphics";
         _loc1_.graphics.copyFrom(this.graphics);
         addChildAt(_loc1_,0);
         this.graphics.clear();
         var _loc3_:uint = 0;
         while(_loc3_ < this.numChildren)
         {
            _loc2_ = this.getChildAt(_loc3_);
            if(_loc2_.name != "graphics")
            {
               _loc2_.x = -this.width / 2;
               _loc2_.y = -this.height / 2;
            }
            _loc3_++;
         }
         _loc1_.x = -this.width / 2;
         _loc1_.y = -this.height / 2;
         this.x -= _loc1_.x;
         this.y -= _loc1_.y;
      }
      
      public function dimensions(param1:Number, param2:Number) : void
      {
         if(this.getChildByName("mask") != null)
         {
            this.removeChild(this.getChildByName("mask"));
         }
         var _loc3_:UIObject = new UIObject();
         _loc3_.name = "mask";
         _loc3_.shouldClear = true;
         addChild(_loc3_);
         _loc3_.graphics.clear();
         _loc3_.graphics.beginFill(16750848,1);
         _loc3_.graphics.drawRect(0,0,param1,param2);
         this.mask = _loc3_;
      }
      
      public function background(param1:Graphics, param2:Number = 0, param3:Number = 0) : UIObject
      {
         if(this.getChildByName("bg") != null)
         {
            this.removeChild(this.getChildByName("bg"));
         }
         var _loc4_:UIObject = new UIObject();
         _loc4_.name = "bg";
         _loc4_.x = param2;
         _loc4_.y = param3;
         _loc4_.shouldClear = true;
         _loc4_.graphics.copyFrom(param1);
         addChildAt(_loc4_,0);
         return _loc4_;
      }
      
      public function kill(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.init);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.kill);
         removeEventListener(MouseEvent.ROLL_OVER,this.mouseOver);
         removeEventListener(MouseEvent.ROLL_OUT,this.mouseOut);
         removeEventListener(MouseEvent.CLICK,this.mouseClick);
         Memory.stage.removeEventListener(Event.RESIZE,this.resize);
         this.reset();
         this.clearObject(this);
      }
      
      protected function resize(param1:Event) : void
      {
         this.setProperties();
      }
      
      public function mouseOver(param1:MouseEvent) : void
      {
         if(this._bitmap == null)
         {
            return;
         }
         if(String(this._bitmap.@x_hover).length == 0)
         {
            return;
         }
         this.hovering = true;
         if(this._bitmap != null)
         {
            this.updateBitmap(Number(this._bitmap.@x_hover),Number(this._bitmap.@y_hover),Number(this._bitmap.@width),Number(this._bitmap.@height),Memory.getBitmap(this._bitmap.@id));
         }
      }
      
      public function mouseOut(param1:MouseEvent) : void
      {
         this.hovering = false;
         if(this._bitmap != null)
         {
            this.updateBitmap(Number(this._bitmap.@x),Number(this._bitmap.@y),Number(this._bitmap.@width),Number(this._bitmap.@height),Memory.getBitmap(this._bitmap.@id));
         }
      }
      
      protected function mouseClick(param1:MouseEvent) : void
      {
      }
      
      public function get config() : XMLList
      {
         return this._config;
      }
      
      public function set config(param1:XMLList) : void
      {
         var _loc2_:XMLList = null;
         var _loc3_:XMLList = null;
         try
         {
            _loc2_ = XMLList(param1._bitmap);
            _loc3_ = XMLList(param1._properties);
            if(String(_loc2_.@id).length > 0)
            {
               this._bitmap = _loc2_;
            }
            if(_loc3_.attributes().length() > 0)
            {
               this._properties = _loc3_;
            }
            this.setProperties();
         }
         catch(e:Error)
         {
         }
         this._config = param1;
      }
      
      public function set link(param1:String) : void
      {
         var href:String = param1;
         this.addEventListener(MouseEvent.CLICK,function():void
         {
            if(Memory.stage.displayState === StageDisplayState.FULL_SCREEN)
            {
               Memory.stage.displayState = StageDisplayState.NORMAL;
            }
            PopupWin.open(href,"_blank");
         });
         this.mouseEnabled = true;
         this.buttonMode = true;
         this.mouseChildren = false;
      }
      
      public function get bitmap() : XMLList
      {
         return this._bitmap;
      }
      
      public function set bitmap(param1:XMLList) : void
      {
         this._bitmap = param1;
         this.mouseOver(null);
         this.mouseOut(null);
      }
      
      override public function set x(param1:Number) : void
      {
         super.x = int(param1);
      }
      
      override public function set y(param1:Number) : void
      {
         super.y = int(param1);
      }
      
      public function _hasOwnProperty(param1:* = null) : Boolean
      {
         if(param1 == "_x")
         {
            return true;
         }
         return super.hasOwnProperty(param1);
      }
      
      public function set _x(param1:*) : void
      {
      }
      
      public function set _y(param1:*) : void
      {
      }
   }
}

