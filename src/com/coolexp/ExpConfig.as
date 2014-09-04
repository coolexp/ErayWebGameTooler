package com.coolexp
{
	public class ExpConfig
	{
		public function ExpConfig()
		{
		}
		public var flexSDKPath:String;
		public var sourcePath:String;
		public var targetPath:String;
		public var isRelease:Boolean;
		public var autoCreate:Boolean;
		public var outputMain:Boolean;
		public var outputCreateRole:Boolean;
		public var outputFrame:Boolean;
		public var outImgs:Boolean;
		public var outAnimations:Boolean;
		public var outUIFiles:Boolean;
		public var packExcel:Boolean;
		public var updateResVersion:Boolean;
		public var isPackGameResData:Boolean;
		public var key_1:int;
		public var key_2:int;
		
		public static function create(sdkPath:String,s:String,t:String,_isRelease:Boolean,_autoCreate:Boolean,_outputMain:Boolean,_outputCreateRole:Boolean,_outputFrame:Boolean,_outImgs:Boolean,_outAnimations:Boolean,_outUIFiles:Boolean,_packExcel:Boolean,_updateResVersion:Boolean,_isPackGameResData:Boolean,k1:int,k2:int):ExpConfig{
			var c:ExpConfig = new ExpConfig();
			c.flexSDKPath = sdkPath;
			c.sourcePath = s;
			c.targetPath = t;
			c.isRelease = _isRelease;
			c.autoCreate = _autoCreate;
			c.outputMain = _outputMain;
			c.outputCreateRole = _outputCreateRole;
			c.outputFrame = _outputFrame;
			c.outImgs = _outImgs;
			c.outAnimations = _outAnimations;
			c.outUIFiles = _outUIFiles;
			c.packExcel = _packExcel;
			c.updateResVersion = _updateResVersion;
			c.isPackGameResData = _isPackGameResData;
			c.key_1 = k1;
			c.key_2 = k2;
			return c;
		}
	}
}