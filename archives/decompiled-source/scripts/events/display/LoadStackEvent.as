package events.display
{
   import flash.display.BitmapData;
   import flash.events.Event;
   
   public class LoadStackEvent extends Event
   {
      
      public static const ThingLoaded:String = "ThingLoaded";
      
      public static const ThingLoading:String = "ThingLoading";
      
      public var _loader:*;
      
      public var _target:*;
      
      public var _type:String;
      
      public var _bitmap:BitmapData;
      
      public var bytesLoaded:Number;
      
      public var bytesTotal:Number;
      
      public var e:Event;
      
      public function LoadStackEvent(param1:String, param2:*, param3:*, param4:String, param5:BitmapData = null, param6:Number = 0, param7:Number = 0, param8:Event = null, param9:Boolean = false, param10:Boolean = false)
      {
         super(param1);
         this._target = param3;
         this._loader = param2;
         this._type = param4;
         this._bitmap = param5;
         this.bytesLoaded = param6;
         this.bytesTotal = param7;
         this.e = param8;
      }
   }
}

