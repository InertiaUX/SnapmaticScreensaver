package com.rockstargames.screensavers.vsnapmatic.controllers
{
   import com.patrickconroy.mvcframework.libs.controller.AppController;
   import com.patrickconroy.mvcframework.libs.view.View;
   import com.rockstargames.screensavers.vsnapmatic.views.mosaic.Index;
   
   public class MosaicController extends AppController
   {
      
      public function MosaicController()
      {
         super();
      }
      
      public function index(param1:Array) : View
      {
         return new Index();
      }
   }
}

