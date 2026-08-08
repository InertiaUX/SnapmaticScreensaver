package com.asual.swfaddress
{
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.Capabilities;
   import flash.utils.Timer;
   
   public class SWFAddress
   {
      
      public static var onInit:Function;
      
      public static var onChange:Function;
      
      private static var _init:Boolean = false;
      
      private static var _initChange:Boolean = false;
      
      private static var _initChanged:Boolean = false;
      
      private static var _strict:Boolean = true;
      
      private static var _value:String = "";
      
      private static var _queue:Array = new Array();
      
      private static var _queueTimer:Timer = new Timer(10);
      
      private static var _initTimer:Timer = new Timer(10);
      
      private static var _availability:Boolean = ExternalInterface.available;
      
      private static var _dispatcher:EventDispatcher = new EventDispatcher();
      
      private static var _initializer:Boolean = _initialize();
      
      public function SWFAddress()
      {
         super();
         throw new IllegalOperationError("SWFAddress cannot be instantiated.");
      }
      
      private static function _initialize() : Boolean
      {
         if(_availability)
         {
            try
            {
               _availability = ExternalInterface.call("function() { return (typeof SWFAddress != \"undefined\"); }") as Boolean;
               ExternalInterface.addCallback("getSWFAddressValue",function():String
               {
                  return _value;
               });
               ExternalInterface.addCallback("setSWFAddressValue",_setValue);
            }
            catch(e:Error)
            {
               _availability = false;
            }
         }
         _queueTimer.addEventListener(TimerEvent.TIMER,_callQueue);
         _initTimer.addEventListener(TimerEvent.TIMER,_check);
         _initTimer.start();
         return true;
      }
      
      private static function _check(param1:TimerEvent) : void
      {
         if((typeof SWFAddress["onInit"] == "function" || _dispatcher.hasEventListener(SWFAddressEvent.INIT)) && !_init)
         {
            SWFAddress._setValueInit(_getValue());
            SWFAddress._init = true;
         }
         if(typeof SWFAddress["onChange"] == "function" || _dispatcher.hasEventListener(SWFAddressEvent.CHANGE) || typeof SWFAddress["onExternalChange"] == "function" || _dispatcher.hasEventListener(SWFAddressEvent.EXTERNAL_CHANGE))
         {
            _initTimer.stop();
            SWFAddress._init = true;
            SWFAddress._setValueInit(_getValue());
         }
      }
      
      private static function _strictCheck(param1:String, param2:Boolean) : String
      {
         if(SWFAddress.getStrict())
         {
            if(param2)
            {
               if(param1.substr(0,1) != "/")
               {
                  param1 = "/" + param1;
               }
            }
            else if(param1 == "")
            {
               param1 = "/";
            }
         }
         return param1;
      }
      
      private static function _getValue() : String
      {
         var _loc1_:String = null;
         var _loc3_:Array = null;
         var _loc2_:String = null;
         if(_availability)
         {
            _loc1_ = ExternalInterface.call("SWFAddress.getValue") as String;
            _loc3_ = ExternalInterface.call("SWFAddress.getIds") as Array;
            if(_loc3_ != null)
            {
               _loc2_ = _loc3_.toString();
            }
         }
         if(_loc2_ == null || !_availability || _initChanged)
         {
            _loc1_ = SWFAddress._value;
         }
         else if(_loc1_ == "undefined" || _loc1_ == null)
         {
            _loc1_ = "";
         }
         return _strictCheck(_loc1_ || "",false);
      }
      
      private static function _setValueInit(param1:String) : void
      {
         SWFAddress._value = param1;
         if(!_init)
         {
            _dispatchEvent(SWFAddressEvent.INIT);
         }
         else
         {
            _dispatchEvent(SWFAddressEvent.CHANGE);
            _dispatchEvent(SWFAddressEvent.EXTERNAL_CHANGE);
         }
         _initChange = true;
      }
      
      private static function _setValue(param1:String) : void
      {
         if(param1 == "undefined" || param1 == null)
         {
            param1 = "";
         }
         if(SWFAddress._value == param1 && SWFAddress._init)
         {
            return;
         }
         if(!SWFAddress._initChange)
         {
            return;
         }
         SWFAddress._value = param1;
         if(!_init)
         {
            SWFAddress._init = true;
            if(typeof SWFAddress["onInit"] == "function" || _dispatcher.hasEventListener(SWFAddressEvent.INIT))
            {
               _dispatchEvent(SWFAddressEvent.INIT);
            }
         }
         _dispatchEvent(SWFAddressEvent.CHANGE);
         _dispatchEvent(SWFAddressEvent.EXTERNAL_CHANGE);
      }
      
      private static function _dispatchEvent(param1:String) : void
      {
         if(_dispatcher.hasEventListener(param1))
         {
            _dispatcher.dispatchEvent(new SWFAddressEvent(param1));
         }
         param1 = param1.substr(0,1).toUpperCase() + param1.substring(1);
         if(typeof SWFAddress["on" + param1] == "function")
         {
            SWFAddress["on" + param1]();
         }
      }
      
      private static function _callQueue(param1:TimerEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(_queue.length != 0)
         {
            _loc2_ = "";
            _loc3_ = 0;
            while(true)
            {
               _loc4_ = _queue[_loc3_];
               if(!_loc4_)
               {
                  break;
               }
               if(_loc4_.param is String)
               {
                  _loc4_.param = "\"" + _loc4_.param + "\"";
               }
               _loc2_ += _loc4_.fn + "(" + _loc4_.param + ");";
               _loc3_++;
            }
            _queue = new Array();
            navigateToURL(new URLRequest("javascript:" + _loc2_ + "void(0);"),"_self");
         }
         else
         {
            _queueTimer.stop();
         }
      }
      
      private static function _call(param1:String, param2:Object = "") : void
      {
         if(_availability)
         {
            if(Capabilities.os.indexOf("Mac") != -1)
            {
               if(_queue.length == 0)
               {
                  _queueTimer.start();
               }
               _queue.push({
                  "fn":param1,
                  "param":param2
               });
            }
            else
            {
               ExternalInterface.call(param1,param2);
            }
         }
      }
      
      public static function back() : void
      {
         _call("SWFAddress.back");
      }
      
      public static function forward() : void
      {
         _call("SWFAddress.forward");
      }
      
      public static function up() : void
      {
         var _loc1_:String = SWFAddress.getPath();
         SWFAddress.setValue(_loc1_.substr(0,_loc1_.lastIndexOf("/",_loc1_.length - 2) + (_loc1_.substr(_loc1_.length - 1) == "/" ? 1 : 0)));
      }
      
      public static function go(param1:int) : void
      {
         _call("SWFAddress.go",param1);
      }
      
      public static function href(param1:String, param2:String = "_self") : void
      {
         if(_availability && Capabilities.playerType == "ActiveX")
         {
            ExternalInterface.call("SWFAddress.href",param1,param2);
            return;
         }
         navigateToURL(new URLRequest(param1),param2);
      }
      
      public static function popup(param1:String, param2:String = "popup", param3:String = "\"\"", param4:String = "") : void
      {
         if(_availability && (Boolean(Capabilities.playerType == "ActiveX") || Boolean(ExternalInterface.call("asual.util.Browser.isSafari"))))
         {
            ExternalInterface.call("SWFAddress.popup",param1,param2,param3,param4);
            return;
         }
         navigateToURL(new URLRequest("javascript:popup=window.open(\"" + param1 + "\",\"" + param2 + "\"," + param3 + ");" + param4 + ";void(0);"),"_self");
      }
      
      public static function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         _dispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public static function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         _dispatcher.removeEventListener(param1,param2,param3);
      }
      
      public static function dispatchEvent(param1:Event) : Boolean
      {
         return _dispatcher.dispatchEvent(param1);
      }
      
      public static function hasEventListener(param1:String) : Boolean
      {
         return _dispatcher.hasEventListener(param1);
      }
      
      public static function getBaseURL() : String
      {
         var _loc1_:String = null;
         if(_availability)
         {
            _loc1_ = String(ExternalInterface.call("SWFAddress.getBaseURL"));
         }
         return _loc1_ == null || _loc1_ == "null" || !_availability ? "" : _loc1_;
      }
      
      public static function getStrict() : Boolean
      {
         var _loc1_:String = null;
         if(_availability)
         {
            _loc1_ = ExternalInterface.call("SWFAddress.getStrict") as String;
         }
         return _loc1_ == null ? _strict : _loc1_ == "true";
      }
      
      public static function setStrict(param1:Boolean) : void
      {
         _call("SWFAddress.setStrict",param1);
         _strict = param1;
      }
      
      public static function getHistory() : Boolean
      {
         return _availability ? ExternalInterface.call("SWFAddress.getHistory") as Boolean : false;
      }
      
      public static function setHistory(param1:Boolean) : void
      {
         _call("SWFAddress.setHistory",param1);
      }
      
      public static function getTracker() : String
      {
         return _availability ? ExternalInterface.call("SWFAddress.getTracker") as String : "";
      }
      
      public static function setTracker(param1:String) : void
      {
         _call("SWFAddress.setTracker",param1);
      }
      
      public static function getTitle() : String
      {
         var _loc1_:String = _availability ? ExternalInterface.call("SWFAddress.getTitle") as String : "";
         if(_loc1_ == "undefined" || _loc1_ == null)
         {
            _loc1_ = "";
         }
         return decodeURI(_loc1_);
      }
      
      public static function setTitle(param1:String) : void
      {
         _call("SWFAddress.setTitle",encodeURI(decodeURI(param1)));
      }
      
      public static function getStatus() : String
      {
         var _loc1_:String = _availability ? ExternalInterface.call("SWFAddress.getStatus") as String : "";
         if(_loc1_ == "undefined" || _loc1_ == null)
         {
            _loc1_ = "";
         }
         return decodeURI(_loc1_);
      }
      
      public static function setStatus(param1:String) : void
      {
         _call("SWFAddress.setStatus",encodeURI(decodeURI(param1)));
      }
      
      public static function resetStatus() : void
      {
         _call("SWFAddress.resetStatus");
      }
      
      public static function getValue() : String
      {
         return decodeURI(_strictCheck(_value || "",false));
      }
      
      public static function setValue(param1:String) : void
      {
         if(param1 == "undefined" || param1 == null)
         {
            param1 = "";
         }
         param1 = encodeURI(decodeURI(_strictCheck(param1,true)));
         if(SWFAddress._value == param1)
         {
            return;
         }
         SWFAddress._value = param1;
         _call("SWFAddress.setValue",param1);
         if(SWFAddress._init)
         {
            _dispatchEvent(SWFAddressEvent.CHANGE);
            _dispatchEvent(SWFAddressEvent.INTERNAL_CHANGE);
         }
         else
         {
            _initChanged = true;
         }
      }
      
      public static function getPath() : String
      {
         var _loc1_:String = SWFAddress.getValue();
         if(_loc1_.indexOf("?") != -1)
         {
            return _loc1_.split("?")[0];
         }
         if(_loc1_.indexOf("#") != -1)
         {
            return _loc1_.split("#")[0];
         }
         return _loc1_;
      }
      
      public static function getPathNames() : Array
      {
         var _loc1_:String = SWFAddress.getPath();
         var _loc2_:Array = _loc1_.split("/");
         if(_loc1_.substr(0,1) == "/" || _loc1_.length == 0)
         {
            _loc2_.splice(0,1);
         }
         if(_loc1_.substr(_loc1_.length - 1,1) == "/")
         {
            _loc2_.splice(_loc2_.length - 1,1);
         }
         return _loc2_;
      }
      
      public static function getQueryString() : String
      {
         var _loc1_:String = SWFAddress.getValue();
         var _loc2_:Number = _loc1_.indexOf("?");
         if(_loc2_ != -1 && _loc2_ < _loc1_.length)
         {
            return _loc1_.substr(_loc2_ + 1);
         }
         return null;
      }
      
      public static function getParameter(param1:String) : Object
      {
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:Number = NaN;
         var _loc7_:Array = null;
         var _loc2_:String = SWFAddress.getValue();
         var _loc3_:Number = _loc2_.indexOf("?");
         if(_loc3_ != -1)
         {
            _loc2_ = _loc2_.substr(_loc3_ + 1);
            _loc4_ = _loc2_.split("&");
            _loc6_ = _loc4_.length;
            _loc7_ = new Array();
            while(_loc6_--)
            {
               _loc5_ = _loc4_[_loc6_].split("=");
               if(_loc5_[0] == param1)
               {
                  _loc7_.push(_loc5_[1]);
               }
            }
            if(_loc7_.length != 0)
            {
               return _loc7_.length != 1 ? _loc7_ : _loc7_[0];
            }
         }
         return null;
      }
      
      public static function getParameterNames() : Array
      {
         var _loc4_:Array = null;
         var _loc5_:Number = NaN;
         var _loc1_:String = SWFAddress.getValue();
         var _loc2_:Number = _loc1_.indexOf("?");
         var _loc3_:Array = new Array();
         if(_loc2_ != -1)
         {
            _loc1_ = _loc1_.substr(_loc2_ + 1);
            if(_loc1_ != "" && _loc1_.indexOf("=") != -1)
            {
               _loc4_ = _loc1_.split("&");
               _loc5_ = 0;
               while(_loc5_ < _loc4_.length)
               {
                  _loc3_.push(_loc4_[_loc5_].split("=")[0]);
                  _loc5_++;
               }
            }
         }
         return _loc3_;
      }
   }
}

