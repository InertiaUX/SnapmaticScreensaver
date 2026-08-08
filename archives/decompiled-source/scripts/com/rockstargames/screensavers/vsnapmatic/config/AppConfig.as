package com.rockstargames.screensavers.vsnapmatic.config
{
   import com.patrickconroy.mvcframework.Bootstrap;
   import com.patrickconroy.mvcframework.config.Config;
   import com.patrickconroy.mvcframework.config.Memory;
   import com.stimuli.Printf;
   
   public class AppConfig extends Config
   {
      
      public function AppConfig()
      {
         super();
      }
      
      public static function init(param1:Array) : void
      {
         Memory.set(Bootstrap.CONFIG,Printf.printf("http://%s.rockstargames.com/social_club/social_club_global_services/snapmaticScreensaver.xml",param1[0]));
      }
   }
}

