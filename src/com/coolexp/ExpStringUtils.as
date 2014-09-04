package com.coolexp
{
	public class ExpStringUtils
	{
		public function ExpStringUtils()
		{
		}
		public static function formate(str:String, ...args):String{
			for(var i:int = 0; i<args.length; i++){
				str = str.replace(new RegExp("\\{" + i + "\\}", "gm"), args[i]);
			}
			return str;
		}
		public static function formatGang(str:String):String{
			str = str.replace(/\\/g,"/");
			return str;
		}
	}
}