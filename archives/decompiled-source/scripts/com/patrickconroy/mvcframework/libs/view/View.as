package com.patrickconroy.mvcframework.libs.view
{
   import com.patrickconroy.mvcframework.libs.UIObject;
   
   public dynamic class View extends UIObject
   {
      
      public function View()
      {
         super();
         this.shouldClear = true;
      }
      
      override public function set _x(param1:*) : void
      {
         switch(param1.toString())
         {
            case "center":
               this.x = (this.layout.width - this.width) * 0.5;
               break;
            case "right":
               this.x = this.layout.width - this.width;
         }
      }
      
      override public function set _y(param1:*) : void
      {
         switch(param1.toString())
         {
            case "center":
               this.y = (this.layout.height - this.height) * 0.5;
               break;
            case "bottom":
               this.y = this.layout.height - this.height;
         }
      }
      
      public function set backgroundColor(param1:String) : void
      {
      }
      
      public function set _marginBottom(param1:Number) : void
      {
         this.y -= param1;
      }
      
      public function set _marginTop(param1:Number) : void
      {
         this.y += param1;
      }
      
      public function set _marginRight(param1:Number) : void
      {
         this.x -= param1;
      }
      
      public function set _marginLeft(param1:Number) : void
      {
         var _loc2_:Number = this.x;
         _loc2_ += param1;
         this.x = param1;
      }
      
      public function get layout() : *
      {
         return this.parent.parent;
      }
   }
}

