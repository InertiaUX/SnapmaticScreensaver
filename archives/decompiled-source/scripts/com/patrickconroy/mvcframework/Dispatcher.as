package com.patrickconroy.mvcframework
{
   import com.patrickconroy.mvcframework.config.Config;
   import com.patrickconroy.mvcframework.config.Memory;
   import com.patrickconroy.mvcframework.libs.Router;
   import com.patrickconroy.mvcframework.libs.UIObject;
   import com.patrickconroy.mvcframework.libs.controller.*;
   import com.patrickconroy.mvcframework.libs.events.ControllerEvent;
   import com.patrickconroy.mvcframework.libs.events.DispatchEvent;
   import com.patrickconroy.mvcframework.libs.notifier.Notifier;
   import com.patrickconroy.mvcframework.libs.view.View;
   import flash.events.TimerEvent;
   import flash.utils.getDefinitionByName;
   
   public class Dispatcher extends UIObject
   {
      
      private var _scope:*;
      
      private var _invocationQueue:Array = new Array();
      
      private var _invocationIndex:int = 0;
      
      private var _currentInvoking:Boolean = false;
      
      public function Dispatcher()
      {
         super();
      }
      
      public function updateURL(param1:String) : void
      {
      }
      
      public function _requestAction(param1:String, param2:*, param3:Boolean = false) : *
      {
         return this.dispatch(param1,"auto",param2,param3,"_requestAction");
      }
      
      public function dispatch(param1:String, param2:String = "", param3:* = null, param4:Boolean = true, param5:String = "") : View
      {
         var triad:Object;
         var controller:AppController = null;
         var url:String = param1;
         var render:String = param2;
         var scope:* = param3;
         var clearLayout:Boolean = param4;
         var origin:String = param5;
         Notifier.notify(Memory.application,Config.DISPATCHER_DISPATCHED,[url]);
         triad = Router.translateToTriad(url);
         try
         {
            controller = new (getDefinitionByName(triad.Controller))();
         }
         catch(e:Error)
         {
         }
         return this._invoke(controller,triad.action,triad.params,render,scope);
      }
      
      private function _invoke(param1:AppController, param2:*, param3:*, param4:String = "", param5:* = null) : View
      {
         if(!param1)
         {
            return null;
         }
         this._invocationIndex = 0;
         this._invocationQueue = new Array();
         this._invocationQueue.push({
            "controller":param1,
            "action":param2,
            "params":param3,
            "render":param4,
            "scope":param5
         });
         if(param4 == "auto")
         {
            return param1[param2](param3);
         }
         return this._invocationCycle();
      }
      
      private function _invocationCycle(param1:TimerEvent = null) : View
      {
         if(this._currentInvoking)
         {
            return null;
         }
         if(this._invocationIndex == this._invocationQueue.length)
         {
            return null;
         }
         this._currentInvoking = true;
         this.invocation.controller.addEventListener(ControllerEvent.MODELS_LOADED,this.controllerModelsLoaded);
         this.invocation.controller.constructClasses();
         return null;
      }
      
      private function controllerModelsLoaded(param1:ControllerEvent) : void
      {
         var _loc2_:AppController = this.invocation.controller as AppController;
         _loc2_.removeEventListener(ControllerEvent.MODELS_LOADED,this.controllerModelsLoaded);
         _loc2_.startupProcess();
         _loc2_.output = this.invocation.controller[this.invocation.action](this.invocation.params);
         _loc2_.render();
         _loc2_.shutdownProcess();
         dispatchEvent(new DispatchEvent(DispatchEvent.DISPATCHED,null,_loc2_));
         this._currentInvoking = false;
         ++this._invocationIndex;
         this._invocationCycle();
      }
      
      private function get invocation() : *
      {
         return this._invocationQueue[this._invocationIndex];
      }
   }
}

