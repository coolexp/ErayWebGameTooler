package com.coolexp.managers
{
	import com.coolexp.ExpConfig;
	import com.coolexp.ExpStringUtils;
	import com.coolexp.vo.BaseFileVO;
	import com.coolexp.vo.ExpCompileVO;
	import com.coolexp.winw.ExpPackLoadingWin;
	
	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	
	import spark.components.Application;
	
	public class ExpToolerManager extends EventDispatcher
	{
		private var config:ExpConfig;
		public function ExpToolerManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		private static var _instance:ExpToolerManager;
		private static const COMPILE_XML_PATH:String = "\\code\\src\\compile\\config.xml";
		private static const BUILD_PER_FILE:String = "assets/antfiles/build.txt";
		private static const TEMPLATE_BUILD_XML:String = "assets/antfiles/template.xml";
		private static const BUILD_XML:String = "\\build.xml";
		private static const BUILD_PER:String = "\\build.properties";
		public static const BAT_EXCEL_FILE:String = "\\packexcel.bat";
		public static const JAR_EXCEL_FILE:String = "\\PackageXLSTooler.jar";
		private static const DEFINE_STRING:String = '<define name="{0}" value="{1}"/>';
		private static const MAIN_SWF:String = "\\release\\DOTA_Main.swf";
		public var fileId:int

		public function get compileList():Array
		{
			return _compileList;
		}

		public function set compileList(value:Array):void
		{
			_compileList = value;
		}
		public function updateCompileByKey(key:String,value:String):void{
			for(var i:int = 0;i<_compileList.length;i++){
				var obj:ExpCompileVO = _compileList[i];
				if(obj.name ==key){
					obj.value = value;
					break;
				}
			}
		}
		public static function getInstance():ExpToolerManager{
			if(_instance==null){
				_instance = new ExpToolerManager();
			}
			return _instance;
		}
		public function getConfig():ExpConfig{
			return config;
		}
		private var application:Application;
		private var _compileList:Array;
		private var loadingWin:IFlexDisplayObject;
		public function publishHandler(c:ExpConfig,app:Application):void{
			this.config = c;
			application = app;
//			application.enabled = false;
			ExpLogManager.getInstance().log("开始发布");
			ExpLogManager.getInstance().showStatus("发布...");
//			readComipleXMLandCreateBuildXML();
//			ExpPackQueneManager.getInstance().start();
		}
		public function showPackWin():void{
			loadingWin = PopUpManager.createPopUp(application,ExpPackLoadingWin,true);
			PopUpManager.centerPopUp(loadingWin);
		}
		public function hidePackWin():void{
			if(loadingWin){
				PopUpManager.removePopUp(loadingWin);
			}
			loadingWin = null;
		}
		public function publishSuccess(val:int=1):void{
			if(val==1){
				ExpLogManager.getInstance().log("发布结束");
				setTimeout(function():void{
//					application.enabled = true;
					ExpLogManager.getInstance().showStatus(" ");
					hidePackWin();
					Alert.show("发布成功");
				},1000);
			}else{
				ExpLogManager.getInstance().log("取消发布");
				application.enabled = true;
				hidePackWin();
			}
		}
		public function exitApp():void{
			if(config){
				var batFile:File = new File(config.sourcePath+BAT_EXCEL_FILE);
				var jarFile:File = new File(config.sourcePath+JAR_EXCEL_FILE);
				var buildPerFile:File = new File(config.sourcePath+BUILD_PER);
				var buildXMLFIle:File = new File(config.sourcePath+BUILD_XML);
				if(batFile.exists){
					batFile.deleteFile();
				}
				if(jarFile.exists){
					jarFile.deleteFile();
				}
				if(buildPerFile.exists){
					buildPerFile.deleteFile();
				}
				if(buildXMLFIle.exists){
					buildXMLFIle.deleteFile();
				}
			}
		}
		public  function readComipleXMLandCreateBuildXML():void{
			var str:String = getPertyFile();
//			var a:Array = getCompileList();
			var a:Array = this.compileList;
			var templateXML:XML = getTemplateXML();
			for each(var node:XML in templateXML.children()){
				var attr:String = node.attribute("name");
				if(attr=="compile"){
					for(var i:int = 0;i<a.length;i++){
						var x:XML = new XML(ExpStringUtils.formate(DEFINE_STRING,a[i].name,a[i].value));
						node.mxmlc.appendChild(x);
					}
				}
			}
			var dependString:String = "init";
			if(config.outputCreateRole){
				dependString+=",compile_createrole";
			}
			if(config.outputMain){
				dependString+=",compile_main_pro";
			}
			if(config.outputFrame){
				dependString+=",compile_main";
			}
			for each(var n:XML in templateXML.children()){
				var na:String = n.attribute("name");
				if(na=="build"){
					n.@depends = dependString;
					break;
				}
			}
			var buildperFile:File = new File(config.sourcePath+BUILD_PER);
			var ba:ByteArray = new ByteArray();
			ba.writeMultiByte(str,"utf-8");
			saveFile(ba,buildperFile);
			var buildXMLFile:File = new File(config.sourcePath+BUILD_XML);
			var baNew:ByteArray = new ByteArray();
			baNew.writeMultiByte(templateXML.toString(),"utf-8");
			saveFile(baNew,buildXMLFile);
			if(dependString!="init"){
				ExpProcessManager.getInstance().publishSWF(config);
			}else{
//				ExpProcessManager.getInstance().publicExcelData();
				ExpPackQueneManager.getInstance().next();
			}
		}
		public function encodeMainProSWF():void{
			if(config.isRelease&&config.outputMain){
				var swfFile:File = new File(config.targetPath+MAIN_SWF);
				if(swfFile.exists){
					ExpLogManager.getInstance().log("开始加密主程序");
					var ba:ByteArray = this.getFileBA(swfFile);
					swfFile.deleteFile();
					var secert:int = config.key_1*config.key_2;
					for(var i:int = 0,l:int = ba.length;i<l;++i){
						var ch:int = ba[i];
						ch = ch ^secert;
						ba[i] = ch;
					}
					var encodeSWFFile:File = new File(config.targetPath+MAIN_SWF);
					this.saveFile(ba,encodeSWFFile);
					ExpLogManager.getInstance().log("加密主程序结束");
//					ExpToolerManager.getInstance().publishSuccess();
					ExpPackQueneManager.getInstance().next();
				}else{
//					ExpToolerManager.getInstance().publishSuccess();
					ExpPackQueneManager.getInstance().next();
				}
			}else{
//				ExpToolerManager.getInstance().publishSuccess();
				ExpPackQueneManager.getInstance().next();
			}
		}
		private function getTemplateXML():XML{
			var file:File = File.applicationDirectory.resolvePath(TEMPLATE_BUILD_XML);
			var ba:ByteArray = this.getFileBA(file);
			var xml:XML = new XML(ba.toString());
			return xml;
		}
		public function getCompileList():Array{
			var a:Array = [];
			var compileXMLFile:File = new File(config.sourcePath+COMPILE_XML_PATH);
			if(compileXMLFile.exists){
				var ba:ByteArray = getFileBA(compileXMLFile);
				var xml:XML = new XML(ba.toString());
				for each(var node:XML in xml.compiler.children()){
					if(node.name().localName == "define"){
						var na:String = node.name;
						var va:String = node.value;
						var obj:ExpCompileVO =new ExpCompileVO();
						obj.name = na;
						obj.value = va;
						a.push(obj);
					}
				}
			}
			return a;
		}
		private function getPertyFile():String{
			var file:File = File.applicationDirectory.resolvePath(BUILD_PER_FILE);
			var ba:ByteArray = getFileBA(file);
			var perFileString:String = ba.toString();
			var saveString:String = ExpStringUtils.formatGang(ExpStringUtils.formate(perFileString,config.targetPath+"/release",config.flexSDKPath));
			return saveString;
		}
		public function saveFile(ba:ByteArray,file:File):void{
			var fs:FileStream= new FileStream();
			fs.open(file,FileMode.WRITE);
			fs.writeBytes(ba);
			fs.close();
		}
		public function getFileBA(file:File):ByteArray{
			var fs:FileStream = new FileStream();
			fs.open(file,FileMode.READ);
			var ba:ByteArray = new ByteArray();
			fs.readBytes(ba);
			fs.close();
			return ba;
		}
		public function isEncode(ba:ByteArray):Boolean{
			ba.position = 0;
			if(ba.length>BaseFileVO.fileHeadStrLength){
				var fileHeadString:String = ba.readUTFBytes(BaseFileVO.fileHeadStrLength);
				if(fileHeadString==BaseFileVO.FILE_HEAD_STR){
					ba.position = 0;
					return true;
				}
			}
			ba.position = 0;
			return false;
		}
	}
}