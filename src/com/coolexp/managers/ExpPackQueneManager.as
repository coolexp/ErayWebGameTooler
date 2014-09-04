package com.coolexp.managers
{
	import com.coolexp.responder.ExpPackItem;
	import com.coolexp.responder.IExpResponder;

	public class ExpPackQueneManager
	{
		private static var _instance:ExpPackQueneManager;
		private var position:int = 0;
		public function ExpPackQueneManager()
		{
			packList = [];
		}
		public static function getInstance():ExpPackQueneManager{
			if(_instance==null){
				_instance = new ExpPackQueneManager();
			}
			return _instance;
		}
		private var packList:Array;
		public function registerPackItem(item:IExpResponder):void{
			packList.push(item);
		}
		public function start():void{
			position = 0;
			next();
		}
		public function next():void{
			if(position>=packList.length){
				ExpToolerManager.getInstance().publishSuccess();
			}else{
				var expPackItem:ExpPackItem = packList[position];
				position++;
				ExpLogManager.getInstance().showStatus(expPackItem.getInfo()+" "+position+"/"+packList.length);
				expPackItem.start();
			}
		}
	}
}