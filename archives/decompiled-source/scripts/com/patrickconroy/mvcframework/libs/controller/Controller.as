package com.patrickconroy.mvcframework.libs.controller
{
   import com.patrickconroy.mvcframework.config.Memory;
   import com.patrickconroy.mvcframework.config.Paths;
   import com.patrickconroy.mvcframework.libs.PObject;
   import com.patrickconroy.mvcframework.libs.Registry;
   import com.patrickconroy.mvcframework.libs.events.ControllerEvent;
   import com.patrickconroy.mvcframework.libs.model.AppModel;
   import com.patrickconroy.mvcframework.libs.model.Model;
   import com.patrickconroy.mvcframework.libs.view.Layout;
   import flash.utils.getDefinitionByName;
   
   public class Controller extends PObject
   {
      
      private var _layout_path:String = "Default";
      
      private var _models:Array = new Array();
      
      private var _loadedModels:Array = new Array();
      
      private var _modelsToLoad:Array = new Array();
      
      private var _model:AppModel;
      
      private var _output:*;
      
      public var autoRender:Boolean = true;
      
      public function Controller()
      {
         super();
      }
      
      public function render() : Boolean
      {
         var layout:Layout = null;
         try
         {
            layout = new (getDefinitionByName(Paths.APPLICATION_PACKAGE + ".views.layouts." + this._layout_path))();
         }
         catch(e:Error)
         {
         }
         Memory.application.platform.layout = layout;
         Memory.application.platform.view = this.output;
         dispatchEvent(new ControllerEvent(ControllerEvent.RENDERED));
         this.afterRender();
         return true;
      }
      
      public function set layout_path(param1:String) : void
      {
         this._layout_path = param1;
      }
      
      public function constructClasses() : void
      {
         if(this.models.length == 0)
         {
            return this._modelsLoaded();
         }
         this._modelsToLoad = new Array();
         var _loc1_:uint = 0;
         while(_loc1_ < this.models.length)
         {
            if(this.getModel(this.models[_loc1_]) === null)
            {
               this._modelsToLoad.push(this.models[_loc1_]);
            }
            _loc1_++;
         }
         if(this._modelsToLoad.length == 0)
         {
            return this._modelsLoaded();
         }
         _loc1_ = 0;
         while(_loc1_ < this._modelsToLoad.length)
         {
            this._loadModel(this._modelsToLoad[_loc1_]);
            _loc1_++;
         }
      }
      
      public function startupProcess() : Boolean
      {
         return true;
      }
      
      public function shutdownProcess() : Boolean
      {
         this.afterFilter();
         return true;
      }
      
      public function afterFilter() : void
      {
      }
      
      public function afterRender() : void
      {
      }
      
      private function _loadModel(param1:String) : Boolean
      {
         var _loc2_:AppModel = new (getDefinitionByName(Paths.APPLICATION_PACKAGE + ".models." + param1))();
         _loc2_.reset();
         Registry.setObject(_loc2_,Registry.MODEL + param1);
         this._loadedModels.push(_loc2_);
         if(this._loadedModels.length == this._modelsToLoad.length)
         {
            this._modelsLoaded();
         }
         return true;
      }
      
      public function getModel(param1:String) : Model
      {
         var _loc2_:AppModel = Registry.getObject(Registry.MODEL + param1) as AppModel;
         if(_loc2_ == null)
         {
            this._loadModel(param1);
            return this.getModel(param1);
         }
         return _loc2_;
      }
      
      private function _modelsLoaded() : void
      {
         dispatchEvent(new ControllerEvent(ControllerEvent.MODELS_LOADED));
      }
      
      public function set output(param1:*) : void
      {
         this._output = param1;
      }
      
      public function get output() : *
      {
         return this._output;
      }
      
      protected function set models(param1:Array) : void
      {
         this._models = param1;
      }
      
      protected function get models() : Array
      {
         return this._models;
      }
   }
}

