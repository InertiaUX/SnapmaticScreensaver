package com.patrickconroy.mvcframework.libs
{
   import com.patrickconroy.mvcframework.libs.view.Layout;
   import com.patrickconroy.mvcframework.libs.view.View;
   
   public class Platform extends UIObject
   {
      
      private var _view:View;
      
      private var _layout:Layout;
      
      public function Platform()
      {
         super();
      }
      
      public function set layout(param1:Layout) : void
      {
         try
         {
            this.removeChild(this.layout);
            this.layout.removeChild(this.view);
            this.view.kill(null);
            this.layout.kill(null);
         }
         catch(e:Error)
         {
         }
         if(param1 === null)
         {
            return;
         }
         if(param1.onStage === false)
         {
            this.addChild(param1);
         }
         this._layout = param1;
      }
      
      public function get layout() : Layout
      {
         return this._layout;
      }
      
      public function get view() : View
      {
         return this._view;
      }
      
      public function set view(param1:View) : void
      {
         if(this.layout === null)
         {
            return;
         }
         this._view = param1;
         this.layout.addChild(param1);
      }
   }
}

