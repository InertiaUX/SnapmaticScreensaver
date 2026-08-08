package com.rockstargames.screensavers.vsnapmatic.config
{
   import com.greensock.plugins.BlurFilterPlugin;
   import com.greensock.plugins.ColorTransformPlugin;
   import com.greensock.plugins.TintPlugin;
   import com.greensock.plugins.TweenPlugin;
   import com.patrickconroy.mvcframework.Application;
   import com.patrickconroy.mvcframework.Bootstrap;
   import com.patrickconroy.mvcframework.config.Memory;
   import flash.events.ContextMenuEvent;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import net.PopupWin;
   
   public class AppBootstrap extends Bootstrap
   {
      
      public function AppBootstrap()
      {
         super();
      }
      
      override public function boot(param1:Application, param2:Function) : void
      {
         var cm:ContextMenu;
         var rockstarLink:ContextMenuItem;
         var application:Application = param1;
         var callback:Function = param2;
         TweenPlugin.activate([BlurFilterPlugin]);
         TweenPlugin.activate([TintPlugin,ColorTransformPlugin]);
         cm = new ContextMenu();
         cm.hideBuiltInItems();
         rockstarLink = new ContextMenuItem("Rockstar Games");
         rockstarLink.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function():void
         {
            PopupWin.open("http://www.rockstargames.com");
         });
         cm.customItems.push(rockstarLink);
         Memory.set("contextMenu",cm);
         super.boot(application,callback);
      }
   }
}

