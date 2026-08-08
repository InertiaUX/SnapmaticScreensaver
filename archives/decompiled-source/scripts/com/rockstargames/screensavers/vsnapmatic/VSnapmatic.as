package com.rockstargames.screensavers.vsnapmatic
{
   import com.patrickconroy.mvcframework.Application;
   import com.patrickconroy.mvcframework.config.Memory;
   import com.rockstargames.screensavers.vsnapmatic.config.AppBootstrap;
   import com.rockstargames.screensavers.vsnapmatic.config.AppConfig;
   import com.rockstargames.screensavers.vsnapmatic.config.FauxRegistry;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.system.Security;
   
   public class VSnapmatic extends Application
   {
      
      private var bootstrap:AppBootstrap = new AppBootstrap();
      
      private var fauxRegistry:FauxRegistry;
      
      public function VSnapmatic(... rest)
      {
         super();
         Security.allowDomain("*");
         Security.loadPolicyFile("http://prod.cloud.rocdsfkstargames.com/crossdomain.xml");
         Security.allowInsecureDomain("*");
         AppConfig.init(rest);
      }
      
      override protected function init(param1:Event) : void
      {
         super.init(param1);
         this.bootstrap.setStage(stage,StageScaleMode.NO_SCALE,StageAlign.TOP_LEFT,60);
         this.bootstrap.boot(this,this.appBooted);
      }
      
      private function appBooted(param1:Boolean) : void
      {
         this.platform.contextMenu = Memory.get("contextMenu");
         Memory.application.addChild(platform);
         if(param1)
         {
            if(Memory.config.config.cloudStatus == 1)
            {
               dispatcher.dispatch("mosaic/index");
            }
            else
            {
               dispatcher.dispatch("error/cloud");
            }
         }
         else
         {
            dispatcher.dispatch("error/io");
         }
      }
   }
}

