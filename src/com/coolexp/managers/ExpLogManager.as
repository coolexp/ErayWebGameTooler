package com.coolexp.managers
{
	
	import spark.components.Label;
	import spark.components.TextArea;

	public class ExpLogManager
	{
		public function ExpLogManager()
		{
		}
		private static var _instance:ExpLogManager;
		public static function getInstance():ExpLogManager{
			if(_instance==null){
				_instance = new ExpLogManager();
			}
			return _instance;
		}
		private var txt:TextArea;
		private var statusLabel:Label;
		public function init(t:TextArea,st:Label):void{
			txt = t;
			statusLabel = st;
		}
		public function log(...args):void{
			txt.appendText(args.join(" ")+"\n");
		}
		public function showStatus(value:String):void{
			if(value!=""){
				statusLabel.text = value;
				statusLabel.visible = true;
			}else{
				statusLabel.visible = false;
			}
		}
		
	}
}