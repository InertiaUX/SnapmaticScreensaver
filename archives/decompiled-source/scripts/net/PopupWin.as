package net
{
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class PopupWin
   {
      
      public static var baseURL:String = "";
      
      private static var browserName:String = "";
      
      public function PopupWin()
      {
         super();
      }
      
      public static function open(param1:String, param2:String = "_blank", param3:String = "") : void
      {
         var _loc4_:String = "window.open";
         if(PopupWin.baseURL != "")
         {
            param1 = PopupWin.baseURL + param1;
         }
         var _loc5_:URLRequest = new URLRequest(param1);
         if(PopupWin.browserName == "")
         {
            PopupWin.browserName = PopupWin.getBrowserName();
         }
         switch(PopupWin.browserName)
         {
            case "Firefox":
            case "IE":
               ExternalInterface.call(_loc4_,param1,param2,param3);
               break;
            case "--IE":
               ExternalInterface.call("function setWMWindow() {window.open(\'" + param1 + "\', \'" + param2 + "\', \'" + param3 + "\');}");
               break;
            case "Safari":
            case "Opera":
            default:
               navigateToURL(_loc5_,param2);
         }
      }
      
      private static function getBrowserName() : String
      {
         var _loc1_:String = null;
         var _loc2_:String = ExternalInterface.call("function getBrowser(){return navigator.userAgent;}");
         if(_loc2_ != null && _loc2_.indexOf("Firefox") >= 0)
         {
            _loc1_ = "Firefox";
         }
         else if(_loc2_ != null && _loc2_.indexOf("Safari") >= 0)
         {
            _loc1_ = "Safari";
         }
         else if(_loc2_ != null && _loc2_.indexOf("MSIE") >= 0)
         {
            _loc1_ = "IE";
         }
         else if(_loc2_ != null && _loc2_.indexOf("Opera") >= 0)
         {
            _loc1_ = "Opera";
         }
         else
         {
            _loc1_ = "Undefined";
         }
         return _loc1_;
      }
      
      public static function showHelp(param1:String = "home") : void
      {
         PopupWin.open(param1,"_help");
      }
   }
}

