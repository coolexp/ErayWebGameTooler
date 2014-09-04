package com.coolexp.responder
{
	public class ExpPackItem implements IExpResponder
	{
		private var method:Function;
		private var key:String;
		private var info:String;
		public function ExpPackItem(key:String,info:String,exec:Function)
		{
			this.key = key;
			this.info = info;
			this.method = exec;
		}
		public function start():void{
			if(this.method!=null){
				this.method.apply(null);
			}
		}
		public function getInfo():String{
			return info;
		}
		public static function create(key:String,info:String,exec:Function):ExpPackItem{
			var expItem:ExpPackItem = new ExpPackItem(key,info,exec);
			return expItem;
		}
	}
}