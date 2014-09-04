package com.coolexp.managers
{
	import com.coolexp.ExpConfig;
	import com.coolexp.vo.BaseFileVO;
	import com.coolexp.vo.FileTypeVO;
	import com.coolexp.vo.GroupFileVO;
	import com.coolexp.vo.SimpleFileVO;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	public class ExpGameResDataManager extends EventDispatcher
	{
		private static const LIST_TXT_FILE:String = "\\res\\assets\\GameResData.xml";
		private static const FILE_PREFIX:String = "\\res\\assets\\";
		public function ExpGameResDataManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		private static var _instance:ExpGameResDataManager;
		public static function getInstance():ExpGameResDataManager{
			if(_instance==null){
				_instance = new ExpGameResDataManager();
			}
			return _instance;
		}
		public function pack(fileName:String="GameResdata.dat"):void{
			var config:ExpConfig = ExpToolerManager.getInstance().getConfig();
			if(config.isPackGameResData){
				var a:Array = getListFile(config);
				var f:File,fileVO:*;
				var fileList:Array = [];
				for(var i:int = 0,l:int = a.length;i<l;++i){
					var o:Object = a[i];
					f = new File(config.sourcePath+FILE_PREFIX+o.value);
					if(!f.exists){
						ExpLogManager.getInstance().log(f.nativePath+"不存在，不会打包进"+fileName);
						continue;
					}
					fileVO = SimpleFileVO.parseFile(f);
					if(fileVO!=null){
						if(fileVO is ByteArray){
							fileList.push(fileVO); 
							continue;
						}
					}else{
						fileVO = BaseFileVO.parse(ExpToolerManager.getInstance().getFileBA(f)) as SimpleFileVO;
					}
					fileList.push(fileVO);
				}
				if(a.length>0){
					var g:GroupFileVO = GroupFileVO.parseFile("assets.group",ExpToolerManager.getInstance().fileId++,FileTypeVO.GAME_G_TYPE,fileList);
					ExpToolerManager.getInstance().saveFile(g.toByteArray(),new File(config.sourcePath+FILE_PREFIX+fileName));
					ExpLogManager.getInstance().log("打包成功");
//					ExpToolerManager.getInstance().encodeMainProSWF();
					
					ExpPackQueneManager.getInstance().next();
				}else{
					ExpLogManager.getInstance().log("打包"+fileName+"出错,XML列表为空");
//					ExpToolerManager.getInstance().encodeMainProSWF();
					
					ExpPackQueneManager.getInstance().next();
				}
			}else{
				ExpLogManager.getInstance().log("不需要打包包"+fileName);
//				ExpToolerManager.getInstance().encodeMainProSWF();
				ExpPackQueneManager.getInstance().next();
			}
		}
		private function getListFile(config:ExpConfig):Array{
			var a:Array = [];
			var listFile:File = new File(config.sourcePath+LIST_TXT_FILE);
			if(listFile.exists){
				var ba:ByteArray = ExpToolerManager.getInstance().getFileBA(listFile);
				var xml:XML = new XML(ba.toString());
				for each(var node:XML in xml.children()){
					var o:Object = {};
					o.value = String(node.@value);
					a.push(o);
				}
			}
			return a;
		}
	}
}