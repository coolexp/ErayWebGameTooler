package com.coolexp.managers
{
	import com.coolexp.ExpConfig;
	import com.coolexp.ExpStringUtils;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;

	public class ExpProcessManager
	{
		public function ExpProcessManager()
		{
		}
		private static var _instance:ExpProcessManager;
		private static const CMD_PATH_FILE:String = "c:/windows/system32/cmd.exe";
		public static function getInstance():ExpProcessManager{
			if(_instance==null){
				_instance = new ExpProcessManager();
			}
			return _instance;
		}
		public function publishSWF(config:ExpConfig):void{
			var nativeProcess:NativeProcess;
			var npInfo:NativeProcessStartupInfo;
			var arg:Vector.<String> = new Vector.<String>;
			arg.push("cd");
			arg.push("/d");
			arg.push(config.sourcePath);
			if(nativeProcess==null){
				npInfo = new NativeProcessStartupInfo();
				npInfo.executable = new File(CMD_PATH_FILE);
				nativeProcess = new NativeProcess();
				nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onStandardOutputData);
				nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onStandardError);
				nativeProcess.addEventListener(Event.STANDARD_OUTPUT_CLOSE,onClose);
			}
			try{
				nativeProcess.start(npInfo);
				nativeProcess.standardInput.writeUTFBytes(arg.join(" ") + "\n");
				nativeProcess.standardInput.writeUTFBytes("\""+File.applicationDirectory.resolvePath("assets/ANT/bin/ant.bat").nativePath+"\"" + "\n");
			}catch(e:Error){
				ExpLogManager.getInstance().log(e.toString());
			}
		}
		public function publicExcelData():void{
			var config:ExpConfig = ExpToolerManager.getInstance().getConfig();
			if(config.packExcel){
				ExpLogManager.getInstance().log("开始打包表格:");
				var nativeProcess:NativeProcess;
				var npInfo:NativeProcessStartupInfo;
				var cdarg:Vector.<String> = new Vector.<String>;
				cdarg.push("cd");
				cdarg.push("/d");
				cdarg.push(config.sourcePath);
				createPackExcelBat(config);
				
				if(nativeProcess==null){
					npInfo = new NativeProcessStartupInfo();
					npInfo.executable = new File(CMD_PATH_FILE);
					nativeProcess = new NativeProcess();
					nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, excelOutDataHandler);
					nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onStandardError);
					nativeProcess.addEventListener(Event.STANDARD_OUTPUT_CLOSE,onClose);
				}
				try{
					nativeProcess.start(npInfo);
					nativeProcess.standardInput.writeUTFBytes(cdarg.join(" ") + "\n");
					nativeProcess.standardInput.writeUTFBytes(config.sourcePath+"\\packexcel.bat" + "\n");
				}catch(e:Error){
					ExpLogManager.getInstance().log(e.toString());
				}
			}else{
				ExpLogManager.getInstance().log("不需要打包表格数据");
//				ExpGameResDataManager.getInstance().pack();
				ExpPackQueneManager.getInstance().next();
			}
		}
		
		private function createPackExcelBat(config:ExpConfig):void{
			var f:File = new File(config.sourcePath+ExpToolerManager.JAR_EXCEL_FILE);
			if(!f.exists){
				File.applicationDirectory.resolvePath("assets/exceltooler/PackageXLSTooler.jar").copyTo(f);
			}
			var templateBatFile:File = File.applicationDirectory.resolvePath("assets/exceltooler/packexcel.template");
			var ba:ByteArray = ExpToolerManager.getInstance().getFileBA(templateBatFile);
			var str:String = ExpStringUtils.formate(ba.toString(),config.sourcePath+"\\");
			var batFile:File = new File(config.sourcePath+ExpToolerManager.BAT_EXCEL_FILE);
			var batBytes:ByteArray = new ByteArray();
			batBytes.writeMultiByte(str,"utf-8");
			ExpToolerManager.getInstance().saveFile(batBytes,batFile);
		}
		protected function excelOutDataHandler(event:ProgressEvent):void
		{
			// TODO Auto-generated method stub
			var nativeProcess:NativeProcess = event.currentTarget as NativeProcess;
			var str:String = nativeProcess.standardOutput.readUTFBytes(nativeProcess.standardOutput.bytesAvailable);
			ExpLogManager.getInstance().log(str);
			if(str.indexOf("PackExcelSuccess")>=0){
//				ExpGameResDataManager.getInstance().pack();
				ExpPackQueneManager.getInstance().next();
			}
		}
		
		protected function onClose(event:Event):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function onStandardError(event:ProgressEvent):void
		{
			// TODO Auto-generated method stub
			ExpLogManager.getInstance().log("调用程序出错");
		}
		
		protected function onStandardOutputData(event:ProgressEvent):void
		{
			// TODO Auto-generated method stub
			var nativeProcess:NativeProcess = event.currentTarget as NativeProcess;
			var str:String = nativeProcess.standardOutput.readUTFBytes(nativeProcess.standardOutput.bytesAvailable);
			ExpLogManager.getInstance().log(str);
			if(str.indexOf("BUILD SUCCESSFUL")>=0){
//				ExpProcessManager.getInstance().publicExcelData();
				ExpPackQueneManager.getInstance().next();
			}
		}
	}
}