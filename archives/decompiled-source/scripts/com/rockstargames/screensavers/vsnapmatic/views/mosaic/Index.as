package com.rockstargames.screensavers.vsnapmatic.views.mosaic
{
   import com.patrickconroy.mvcframework.config.Memory;
   import com.patrickconroy.mvcframework.libs.view.View;
   import com.rockstargames.screensavers.vsnapmatic.events.SnapImageEvent;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class Index extends View
   {
      
      private var boxes:Sprite = new Sprite();
      
      private var boxWidth:Number = 640;
      
      private var boxHeight:Number = 360;
      
      private var _imageIndex:Number = 0;
      
      public function Index()
      {
         super();
      }
      
      override protected function init(param1:Event) : void
      {
         var _loc4_:Box = null;
         super.init(param1);
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         var _loc5_:Number = Number(Memory.config.config.numCols);
         var _loc6_:Number = Number(Memory.config.config.numCols) + 1;
         var _loc7_:Number = Number(Memory.config.config.numCols) * _loc6_;
         addChild(this.boxes);
         var _loc8_:uint = 0;
         while(_loc8_ < _loc7_)
         {
            _loc3_ = _loc8_ % _loc5_;
            if(_loc3_ === 0)
            {
               _loc2_++;
            }
            _loc4_ = new Box(_loc2_ - 1,_loc3_,_loc8_,this.boxWidth,this.boxHeight);
            _loc4_.addEventListener(SnapImageEvent.INCREMENT,this._increment);
            this.boxes.addChildAt(_loc4_,0);
            _loc8_++;
         }
      }
      
      private function _increment(param1:SnapImageEvent) : void
      {
         this.imageIndex = this.imageIndex + 1 === Memory.config.images.image.length() - 1 ? 0 : this.imageIndex + 1;
      }
      
      public function get imageIndex() : Number
      {
         return this._imageIndex;
      }
      
      public function set imageIndex(param1:Number) : void
      {
         this._imageIndex = param1;
      }
      
      override protected function resize(param1:Event) : void
      {
         this.boxes.scaleX = this.boxes.scaleY = Memory.stage.stageWidth / (Number(Memory.config.config.numCols) * this.boxWidth);
      }
   }
}

import com.greensock.TweenMax;
import com.greensock.easing.*;
import com.patrickconroy.mvcframework.config.Memory;
import com.patrickconroy.mvcframework.libs.UIObject;
import com.rockstargames.screensavers.vsnapmatic.events.SnapImageEvent;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.Timer;

final class Box extends UIObject
{
   
   private var row:Number;
   
   private var col:Number;
   
   private var index:Number;
   
   private var w:Number;
   
   private var h:Number;
   
   private var placed:Boolean = false;
   
   private var box0:Sprite = new Sprite();
   
   private var box1:Sprite = new Sprite();
   
   private var currentBox:Sprite;
   
   private var oldBox:Sprite;
   
   private var url:String = "";
   
   private var contentId:String = "";
   
   private var animationTypes:Array = new Array("flash","fade","swipeLeft","swipeRight","swipeDown","swipeUp");
   
   public function Box(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number)
   {
      super();
      this.row = param1;
      this.col = param2;
      this.index = param3;
      this.w = param4;
      this.h = param5;
   }
   
   override protected function init(param1:Event) : void
   {
      super.init(param1);
      this.alpha = 0;
      this.graphics.beginFill(0,1);
      this.graphics.drawRect(0,0,this.w,this.h);
      var _loc2_:Sprite = new Sprite();
      _loc2_.graphics.beginFill(16750848,1);
      _loc2_.graphics.drawRect(0,0,this.w,this.h);
      addChild(_loc2_);
      this.mask = _loc2_;
      this.box0.name = "box0";
      this.box1.name = "box1";
      this.currentBox = this.box0;
      addChild(this.box0);
      addChild(this.box1);
      this.resize(null);
      this.loadImage();
   }
   
   private function loadImage(param1:TimerEvent = null) : void
   {
      var loader:Loader;
      var context:LoaderContext;
      var e:TimerEvent = param1;
      if(e !== null)
      {
         Timer(e.target).stop();
      }
      loader = new Loader();
      context = new LoaderContext(true);
      this.url = String(XMLList(Memory.config.images.image[Index(this.parent.parent).imageIndex]).url);
      this.contentId = String(XMLList(Memory.config.images.image[Index(this.parent.parent).imageIndex]).contentId);
      this.dispatchEvent(new SnapImageEvent(SnapImageEvent.INCREMENT));
      loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.imageLoaded);
      loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function():void
      {
         loadImage(null);
      });
      try
      {
         loader.load(new URLRequest(this.url),context);
      }
      catch(e:Error)
      {
         loadImage(null);
      }
   }
   
   private function imageLoaded(param1:Event) : void
   {
      var animationDelay:Number;
      var animationType:String;
      var nextTimer:Timer;
      var e:Event = param1;
      var imgContent:LoaderInfo = LoaderInfo(e.target);
      var bitmap:Bitmap = Bitmap(imgContent.content);
      var bd:BitmapData = new BitmapData(this.w,this.h,false);
      bd.draw(bitmap);
      this.currentBox = Sprite(this.getChildByName(this.currentBox.name === "box0" ? "box1" : "box0"));
      this.oldBox = Sprite(this.getChildByName(this.currentBox.name === "box0" ? "box1" : "box0"));
      this.setChildIndex(this.currentBox,this.numChildren - 1);
      this.setChildIndex(this.oldBox,0);
      this.currentBox.graphics.clear();
      this.currentBox.graphics.beginBitmapFill(bd,null,false,true);
      this.currentBox.graphics.drawRect(0,0,bd.width,bd.height);
      animationDelay = 10 + Math.floor(Math.random() * 10);
      animationType = this.animationTypes[Math.floor(Math.random() * this.animationTypes.length)];
      nextTimer = new Timer(animationDelay * 1000);
      nextTimer.addEventListener(TimerEvent.TIMER,this.loadImage);
      if(!this.placed)
      {
         this.place();
      }
      else
      {
         TweenMax.to(this.currentBox,0,{"colorMatrixFilter":{}});
         this.currentBox.alpha = this.oldBox.alpha = 1;
         this.currentBox.x = this.currentBox.y = 0;
         switch(animationType)
         {
            case "flash":
               this.currentBox.alpha = 0;
               TweenMax.to(this.oldBox,0.2,{
                  "colorMatrixFilter":{
                     "colorize":16777215,
                     "amount":1,
                     "brightness":4
                  },
                  "onComplete":function():void
                  {
                     currentBox.alpha = 1;
                     TweenMax.to(currentBox,0,{"colorMatrixFilter":{
                        "colorize":16777215,
                        "amount":1,
                        "brightness":4
                     }});
                     TweenMax.to(currentBox,1,{"colorMatrixFilter":{"amount":1}});
                  }
               });
               break;
            case "fade":
               this.currentBox.alpha = 0;
               TweenMax.to(this.oldBox,1,{
                  "alpha":0,
                  "ease":"linear"
               });
               TweenMax.to(this.currentBox,1,{
                  "alpha":1,
                  "ease":"linear"
               });
               break;
            case "swipeLeft":
               this.currentBox.alpha = this.oldBox.alpha = 1;
               this.currentBox.x = this.w;
               TweenMax.to(this.oldBox,1,{
                  "x":-this.w,
                  "ease":Expo.easeOut
               });
               TweenMax.to(this.currentBox,1,{
                  "x":0,
                  "ease":Expo.easeOut
               });
               break;
            case "swipeRight":
               this.currentBox.x = -this.w;
               TweenMax.to(this.oldBox,1,{
                  "x":this.w,
                  "ease":Expo.easeOut
               });
               TweenMax.to(this.currentBox,1,{
                  "x":0,
                  "ease":Expo.easeOut
               });
               break;
            case "swipeDown":
               this.currentBox.y = -this.h;
               TweenMax.to(this.oldBox,1,{
                  "y":this.h,
                  "ease":Expo.easeOut
               });
               TweenMax.to(this.currentBox,1,{
                  "y":0,
                  "ease":Expo.easeOut
               });
               break;
            case "swipeUp":
               this.currentBox.y = this.h;
               TweenMax.to(this.oldBox,1,{
                  "y":-this.h,
                  "ease":Expo.easeOut
               });
               TweenMax.to(this.currentBox,1,{
                  "y":0,
                  "ease":Expo.easeOut
               });
         }
      }
      nextTimer.start();
   }
   
   private function place() : void
   {
      this.placed = true;
      TweenMax.to(this,0.25,{
         "delay":this.index * 0.1,
         "x":this.col * this.width,
         "y":this.row * this.height,
         "ease":Expo.easeOut
      });
      TweenMax.to(this,0.25,{
         "delay":this.index * 0.1,
         "alpha":1,
         "ease":"linear"
      });
   }
   
   override protected function resize(param1:Event) : void
   {
      super.resize(param1);
      if(!this.placed)
      {
         this.x = (Memory.stage.stageWidth / this.parent.scaleX - this.width) * 0.5;
         this.y = (Memory.stage.stageHeight / this.parent.scaleY - this.height) * 0.5;
      }
   }
}
