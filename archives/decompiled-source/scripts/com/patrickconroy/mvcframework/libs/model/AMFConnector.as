package com.patrickconroy.mvcframework.libs.model
{
   import com.patrickconroy.mvcframework.libs.events.AMFEvent;
   import flash.events.EventDispatcher;
   import flash.net.NetConnection;
   import flash.net.Responder;
   
   public class AMFConnector extends EventDispatcher
   {
      
      private static const XMLROOT:String = "<data></data>";
      
      private var _nc:NetConnection;
      
      private var _gateway:String;
      
      private var _class:String;
      
      private var _service:String;
      
      private var _params:Array;
      
      private var _dataKey:String;
      
      private var _filter:Object;
      
      public function AMFConnector(param1:String, param2:Object, param3:Array, param4:Object)
      {
         super();
         this._dataKey = param1;
         this._gateway = param2._gateway;
         this._class = param2._class;
         this._service = param2._service;
         this._params = param3;
         this._filter = param4;
      }
      
      public function connect() : void
      {
         this._nc = new NetConnection();
         this._nc.connect(this._gateway);
         switch(this._params.length)
         {
            case 1:
               this._nc.call(this._class + "." + this._service,new Responder(this._dataReceived,this._onError),this._params[0]);
               break;
            case 2:
               this._nc.call(this._class + "." + this._service,new Responder(this._dataReceived,this._onError),this._params[0],this._params[1]);
               break;
            case 3:
               this._nc.call(this._class + "." + this._service,new Responder(this._dataReceived,this._onError),this._params[0],this._params[1],this._params[2]);
               break;
            case 4:
               this._nc.call(this._class + "." + this._service,new Responder(this._dataReceived,this._onError),this._params[0],this._params[1],this._params[2],this._params[3]);
               break;
            case 5:
               this._nc.call(this._class + "." + this._service,new Responder(this._dataReceived,this._onError),this._params[0],this._params[1],this._params[2],this._params[3],this._params[4]);
               break;
            default:
               this._nc.call(this._class + "." + this._service,new Responder(this._dataReceived,this._onError));
         }
      }
      
      private function _dataReceived(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:XML = null;
         var _loc4_:uint = 0;
         var _loc5_:String = null;
         try
         {
            _loc3_ = new XML(AMFConnector.XMLROOT);
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc2_ = "";
               _loc2_ += "<item>";
               for(_loc5_ in param1[_loc4_])
               {
                  _loc2_ += "<" + _loc5_ + ">";
                  _loc2_ += "<![CDATA[" + param1[_loc4_][_loc5_] + "]]>";
                  _loc2_ += "</" + _loc5_ + ">";
               }
               _loc2_ += "</item>";
               _loc3_.appendChild(new XMLList(_loc2_));
               _loc4_++;
            }
         }
         catch(e:Error)
         {
         }
         if(this._filter != null)
         {
            _loc3_ = this._filterResponse(_loc3_);
         }
         dispatchEvent(new AMFEvent(AMFEvent.AMFComplete,_loc3_,this._dataKey));
      }
      
      private function _filterResponse(param1:XML) : XML
      {
         var g:String = null;
         var x:XML = param1;
         var data:XML = new XML(AMFConnector.XMLROOT);
         for(g in this._filter)
         {
            data.appendChild(new XMLList(x.item.(child(g) == this._filter[g])));
         }
         return data;
      }
      
      private function _onError(param1:Object) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in param1)
         {
         }
         dispatchEvent(new AMFEvent(AMFEvent.AMFError,param1,this._dataKey));
      }
   }
}

