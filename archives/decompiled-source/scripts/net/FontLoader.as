package net
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.text.Font;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   
   public class FontLoader extends EventDispatcher
   {
      
      private static const SWF_HEADER:ByteArray = new ByteArray();
      
      private static const CLASS_CODE:ByteArray = new ByteArray();
      
      private static const CLASS_NAME_PREFIX:String = "Font$";
      
      private static const TAG_DO_ABC:uint = 72 << 6 | 0x3F;
      
      private static const TAG_SYMBOL_CLASS:uint = 76 << 6 | 0x3F;
      
      private static var _initialized:Boolean = false;
      
      private const _loader:URLLoader = new URLLoader();
      
      private var _libLoader:Loader;
      
      private var _fontCount:uint;
      
      private var _autoRegister:Boolean = true;
      
      private const _fonts:Array = new Array();
      
      public function FontLoader(param1:URLRequest = null, param2:Boolean = true)
      {
         super();
         FontLoader.init();
         this._loader.dataFormat = URLLoaderDataFormat.BINARY;
         this._loader.addEventListener(Event.COMPLETE,this.handler_complete);
         this._loader.addEventListener(Event.OPEN,this.handler_redirect);
         this._loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.handler_redirect);
         this._loader.addEventListener(IOErrorEvent.IO_ERROR,this.handler_redirect);
         this._loader.addEventListener(ProgressEvent.PROGRESS,this.handler_redirect);
         this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handler_redirect);
         if(param1)
         {
            this.load(param1,param2);
         }
      }
      
      private static function init() : void
      {
         if(FontLoader._initialized)
         {
            return;
         }
         var _loc1_:SWFByteArray = new SWFByteArray();
         _loc1_.writeBytesFromString("7800055F00000FA000000C01004411080000004302FFFFFFBF150B0000000100466F6E744C69620000" + "BF1461020000010000000010002E00000000191272752E657463732E7574696C733A466F6E7400432F" + "55736572732F6574632F4465736B746F702F50726F6A656374732F466F6E744C6F616465724C69622F" + "7372633B72752F657463732F7574696C733B466F6E742E61731772752E657463732E7574696C733A46" + "6F6E742F466F6E74175B4F626A65637420466F6E7420666F6E744E616D653D2208666F6E744E616D65" + "0D2220666F6E745374796C653D2209666F6E745374796C650C2220666F6E74547970653D2208666F6E" + "745479706502225D1B72752E657463732E7574696C733A466F6E742F746F537472696E670653747269" + "6E6708746F537472696E67175F5F676F5F746F5F646566696E6974696F6E5F68656C700466696C6543" + "2F55736572732F6574632F4465736B746F702F50726F6A656374732F466F6E744C6F616465724C6962" + "2F7372632F72752F657463732F7574696C732F466F6E742E617303706F73033636380D72752E657463" + "732E7574696C7304466F6E740A666C6173682E74657874064F626A6563740335373006050116021614" + "161618010201030A07020607020807020A07020D07020E070315070415091501070217040000020000" + "00040000040C0000000200020F02101211130F02101211180106070905000101054100020100000001" + "030106440000010104000101040503D03047000001010105060EF103F018D030F019D04900F01A4700" + "00020201050620F103F01CD0302C05F01DD00401A02C07A0D00402A02C09A0D00403A02C0BA0480000" + "030201010421D030F103F0165D085D096609305D076607305D07660758001D1D6806F103F00B470000");
         _loc1_.position = 0;
         _loc1_.readBytes(FontLoader.SWF_HEADER);
         _loc1_.length = 0;
         _loc1_.writeBytesFromString("392F55736572732F6574632F4465736B746F702F50726F6A656374732F466F6E744C6F616465724C69" + "622F7372633B3B466F6E743030302E61730568656C6C6F2B48656C6C6F2C20776F726C642120497320" + "616E79626F647920686572653F2057686F27732074686572653F0F466F6E743030302F466F6E743030" + "300D72752E657463732E7574696C7304466F6E74064F626A6563740A666C6173682E74657874175F5F" + "676F5F746F5F646566696E6974696F6E5F68656C700466696C65382F55736572732F6574632F446573" + "6B746F702F50726F6A656374732F466F6E744C6F616465724C69622F7372632F466F6E743030302E61" + "7303706F73023534060501160216071801160A00050702010703080702090705080300000200000006" + "0000000200010B020C0E0D0F0101020904000100000001020101440100010003000101050603D03047" + "0000010102060719F103F006D030EF01040008F007D049002C05F00885D5F009470000020201010527" + "D030F103F00465005D036603305D046604305D026602305D02660258001D1D1D6801F103F002470000");
         _loc1_.position = 0;
         _loc1_.readBytes(FontLoader.CLASS_CODE);
         _loc1_.length = 0;
         FontLoader._initialized = true;
      }
      
      public function set autoRegister(param1:Boolean) : void
      {
         if(this._autoRegister == param1)
         {
            return;
         }
         this._autoRegister = param1;
         if(param1)
         {
            this.registerFonts();
         }
      }
      
      public function get autoRegister() : Boolean
      {
         return this._autoRegister;
      }
      
      public function get bytesLoaded() : uint
      {
         return this._loader.bytesLoaded;
      }
      
      public function get bytesTotal() : uint
      {
         return this._loader.bytesTotal;
      }
      
      public function get fonts() : Array
      {
         return this._fonts.concat();
      }
      
      public function load(param1:URLRequest, param2:Boolean = true) : void
      {
         this.close();
         this._fonts.length = 0;
         this._fontCount = 0;
         this._loader.load(param1);
         this._autoRegister = param2;
      }
      
      public function close() : void
      {
         try
         {
            this._loader.close();
         }
         catch(error:Error)
         {
         }
         if(this._libLoader)
         {
            this._libLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.handler_libComplete);
            try
            {
               this._libLoader.close();
            }
            catch(error:Error)
            {
            }
            try
            {
               this._libLoader.unload();
            }
            catch(error:Error)
            {
            }
            this._libLoader = null;
         }
      }
      
      public function registerFonts() : void
      {
         var font:Font = null;
         for each(font in this._fonts)
         {
            try
            {
            }
            catch(e:*)
            {
            }
         }
      }
      
      private function handler_complete(param1:Event) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:Number = NaN;
         var _loc9_:ByteArray = null;
         var _loc10_:ByteArray = null;
         var _loc11_:ByteArray = new SWFByteArray(this._loader.data as ByteArray);
         var _loc12_:Object = new Object();
         var _loc13_:uint = FontLoader.CLASS_CODE.length;
         while(_loc11_.bytesAvailable)
         {
            _loc6_ = _loc11_.readUnsignedShort();
            _loc4_ = uint(_loc6_ >> 6);
            _loc7_ = (_loc6_ & 0x3F) == 63 ? _loc11_.readUnsignedInt() : uint(_loc6_ & 0x3F);
            _loc8_ = _loc11_.position;
            switch(_loc4_)
            {
               case 13:
               case 48:
               case 62:
               case 73:
               case 75:
               case 88:
                  _loc5_ = _loc11_.readUnsignedShort();
                  _loc9_ = _loc12_[_loc5_] as ByteArray;
                  if(!_loc9_)
                  {
                     _loc9_ = new ByteArray();
                     _loc9_.endian = Endian.LITTLE_ENDIAN;
                     _loc12_[_loc5_] = _loc9_;
                  }
                  if((_loc6_ & 0x3F) == 63)
                  {
                     _loc9_.writeShort(_loc4_ << 6 | 0x3F);
                     _loc9_.writeUnsignedInt(_loc7_);
                  }
                  else
                  {
                     _loc9_.writeShort(_loc4_ << 6 | _loc7_ & 0x3F);
                  }
                  _loc9_.writeShort(_loc5_);
                  _loc9_.writeBytes(_loc11_,_loc11_.position,_loc7_ - 2);
            }
            _loc11_.position = _loc8_ + _loc7_;
         }
         _loc9_ = new ByteArray();
         _loc9_.endian = Endian.LITTLE_ENDIAN;
         _loc9_.writeBytes(FontLoader.SWF_HEADER);
         _loc4_ = 0;
         for(_loc2_ in _loc12_)
         {
            _loc11_ = _loc12_[_loc2_] as ByteArray;
            if(_loc11_)
            {
               _loc3_ = _loc4_.toString();
               while(_loc3_.length < 3)
               {
                  _loc3_ = "0" + _loc3_;
               }
               _loc3_ = FontLoader.CLASS_NAME_PREFIX + _loc3_;
               _loc9_.writeShort(FontLoader.TAG_DO_ABC);
               _loc9_.writeUnsignedInt(10 + _loc3_.length + _loc13_);
               _loc9_.writeUnsignedInt(3014672);
               _loc9_.writeUnsignedInt(268435456);
               _loc9_.writeByte(_loc3_.length);
               _loc9_.writeUTFBytes(_loc3_);
               _loc9_.writeByte(0);
               _loc9_.writeBytes(FontLoader.CLASS_CODE);
               _loc9_.writeBytes(_loc11_);
               _loc9_.writeShort(FontLoader.TAG_SYMBOL_CLASS);
               _loc9_.writeUnsignedInt(5 + _loc3_.length);
               _loc9_.writeShort(1);
               _loc9_.writeShort(_loc2_ as uint);
               _loc9_.writeUTFBytes(_loc3_);
               _loc9_.writeByte(0);
               _loc4_++;
            }
         }
         this._fontCount = _loc4_;
         if(this._fontCount)
         {
            _loc9_.writeUnsignedInt(64);
            _loc10_ = new ByteArray();
            _loc10_.endian = Endian.LITTLE_ENDIAN;
            _loc10_.writeUTFBytes("FWS");
            _loc10_.writeByte(9);
            _loc10_.writeUnsignedInt(_loc9_.length + 8);
            _loc10_.writeBytes(_loc9_);
            this._libLoader = new Loader();
            this._libLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.handler_libComplete);
            this._libLoader.loadBytes(_loc10_);
         }
         else
         {
            this.close();
            super.dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      private function handler_libComplete(param1:Event) : void
      {
         var id:String = null;
         var i:uint = 0;
         var fontClass:Class = null;
         var font:Font = null;
         var event:Event = param1;
         i = 0;
         for(; i < this._fontCount; i++)
         {
            id = i.toString();
            while(id.length < 3)
            {
               id = "0" + id;
            }
            id = FontLoader.CLASS_NAME_PREFIX + id;
            if(this._libLoader.contentLoaderInfo.applicationDomain.hasDefinition(id))
            {
               fontClass = this._libLoader.contentLoaderInfo.applicationDomain.getDefinition(id) as Class;
               font = new fontClass() as Font;
               if(Boolean(font) && Boolean(font.fontName))
               {
                  this._fonts.push(font);
                  if(this._autoRegister)
                  {
                     try
                     {
                        Font.registerFont(fontClass);
                     }
                     catch(e:*)
                     {
                     }
                     continue;
                  }
               }
            }
         }
         this.close();
         super.dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function handler_redirect(param1:Event) : void
      {
         super.dispatchEvent(param1);
      }
   }
}

import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Endian;

class SWFByteArray extends ByteArray
{
   
   private static const TAG_SWF:String = "FWS";
   
   private static const TAG_SWF_COMPRESSED:String = "CWS";
   
   private var _bitIndex:uint;
   
   private var _version:uint;
   
   private var _frameRate:Number;
   
   private var _rect:Rectangle;
   
   public function SWFByteArray(param1:ByteArray = null)
   {
      var _loc2_:String = null;
      var _loc3_:String = null;
      super();
      super.endian = Endian.LITTLE_ENDIAN;
      if(param1)
      {
         _loc2_ = param1.endian;
         param1.endian = Endian.LITTLE_ENDIAN;
         if(param1.bytesAvailable > 26)
         {
            _loc3_ = param1.readUTFBytes(3);
            if(!(_loc3_ == SWFByteArray.TAG_SWF || _loc3_ == SWFByteArray.TAG_SWF_COMPRESSED))
            {
               throw new ArgumentError("Error #2124: Loaded file is an unknown type.");
            }
            this._version = param1.readUnsignedByte();
            param1.readUnsignedInt();
            param1.readBytes(this);
            if(_loc3_ == SWFByteArray.TAG_SWF_COMPRESSED)
            {
               super.uncompress();
            }
            this.readHeader();
         }
         param1.endian = _loc2_;
      }
   }
   
   public function get version() : uint
   {
      return this._version;
   }
   
   public function get frameRate() : Number
   {
      return this._frameRate;
   }
   
   public function get rect() : Rectangle
   {
      return this._rect;
   }
   
   public function writeBytesFromString(param1:String) : void
   {
      var _loc4_:String = null;
      var _loc5_:uint = 0;
      var _loc2_:uint = uint(param1.length);
      var _loc3_:uint = 0;
      while(_loc3_ < _loc2_)
      {
         _loc4_ = param1.substr(_loc3_,2);
         _loc5_ = parseInt(_loc4_,16);
         writeByte(_loc5_);
         _loc3_ += 2;
      }
   }
   
   public function readRect() : Rectangle
   {
      var _loc1_:uint = uint(super.position);
      var _loc2_:uint = uint(this[_loc1_]);
      var _loc3_:uint = uint(_loc2_ >> 3);
      var _loc4_:Number = this.readBits(_loc3_,5) / 20;
      var _loc5_:Number = this.readBits(_loc3_) / 20;
      var _loc6_:Number = this.readBits(_loc3_) / 20;
      var _loc7_:Number = this.readBits(_loc3_) / 20;
      super.position = _loc1_ + Math.ceil((_loc3_ * 4 - 3) / 8) + 1;
      return new Rectangle(_loc4_,_loc6_,_loc5_ - _loc4_,_loc7_ - _loc6_);
   }
   
   public function readBits(param1:uint, param2:int = -1) : Number
   {
      if(param2 < 0)
      {
         param2 = int(this._bitIndex);
      }
      this._bitIndex = param2;
      var _loc3_:uint = uint(this[super.position]);
      var _loc4_:Number = 0;
      var _loc5_:Number = 0;
      var _loc6_:uint = 8 - param2;
      var _loc7_:Number = param1 - _loc6_;
      if(_loc7_ > 0)
      {
         var _loc8_:SWFByteArray = this;
         var _loc9_:Number = _loc8_.super.position + 1;
         _loc8_.super.position = _loc9_;
         _loc4_ = this.readBits(_loc7_,0) | (_loc3_ & (1 << _loc6_) - 1) << _loc7_;
      }
      else
      {
         _loc4_ = _loc3_ >> 8 - param1 - param2 & (1 << param1) - 1;
         this._bitIndex = (param2 + param1) % 8;
         if(param2 + param1 > 7)
         {
            _loc8_ = this;
            _loc9_ = _loc8_.super.position + 1;
            _loc8_.super.position = _loc9_;
         }
      }
      return _loc4_;
   }
   
   public function traceArray(param1:ByteArray) : String
   {
      var _loc5_:String = null;
      var _loc2_:String = "";
      var _loc3_:uint = param1.position;
      var _loc4_:uint = 0;
      param1.position = 0;
      while(param1.bytesAvailable)
      {
         _loc5_ = param1.readUnsignedByte().toString(16).toUpperCase();
         _loc5_ = _loc5_.length < 2 ? "0" + _loc5_ : _loc5_;
         _loc2_ += _loc5_ + " ";
      }
      param1.position = _loc3_;
      return _loc2_;
   }
   
   private function readFrameRate() : void
   {
      var _loc1_:Number = NaN;
      if(this._version < 8)
      {
         this._frameRate = super.readUnsignedShort();
      }
      else
      {
         _loc1_ = super.readUnsignedByte() / 255;
         this._frameRate = super.readUnsignedByte() + _loc1_;
      }
   }
   
   private function readHeader() : void
   {
      this._rect = this.readRect();
      this.readFrameRate();
      super.readShort();
   }
}
