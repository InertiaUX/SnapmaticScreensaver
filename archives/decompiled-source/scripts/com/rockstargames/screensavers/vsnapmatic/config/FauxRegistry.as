package com.rockstargames.screensavers.vsnapmatic.config
{
   import com.rockstargames.screensavers.vsnapmatic.controllers.ErrorController;
   import com.rockstargames.screensavers.vsnapmatic.controllers.MosaicController;
   import com.rockstargames.screensavers.vsnapmatic.views.layouts.Default;
   
   public class FauxRegistry
   {
      
      private var registry:Object = {
         "MosaicController":MosaicController,
         "ErrorController":ErrorController,
         "Default":Default
      };
      
      public function FauxRegistry()
      {
         super();
      }
   }
}

