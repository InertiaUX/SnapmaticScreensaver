package com.rockstargames.screensavers.vsnapmatic.controllers
{
   import com.patrickconroy.mvcframework.libs.controller.AppController;
   import com.patrickconroy.mvcframework.libs.view.View;
   import com.rockstargames.screensavers.vsnapmatic.views.error.Cloud;
   import com.rockstargames.screensavers.vsnapmatic.views.error.Io;
   
   public class ErrorController extends AppController
   {
      
      public function ErrorController()
      {
         super();
      }
      
      public function io(param1:Array) : View
      {
         return new Io();
      }
      
      public function cloud(param1:Array) : View
      {
         return new Cloud();
      }
   }
}

