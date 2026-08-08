package
{
   import com.rockstargames.screensavers.vsnapmatic.VSnapmatic;
   import flash.display.Sprite;
   
   public class VSnapmaticScreensaver extends Sprite
   {
      
      public function VSnapmaticScreensaver()
      {
         super();
         var _loc1_:VSnapmatic = new VSnapmatic(root.loaderInfo.parameters.domain || "www",root.loaderInfo.parameters.searchHash || "");
         addChild(_loc1_);
      }
   }
}

