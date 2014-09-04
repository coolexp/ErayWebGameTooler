:: 参数为6个,第一个为数据源，如果不传，默认读取D盘里的data目录，第二个为true,false,均可．第三个是否输出数据文件,第四个是否输出AS类文件,第五个是否输出Java类文件，第六个为输出的类文件所在的包路径  第７个为输出C++类文件 第八个是否输出每个Sheet的DAT
:: 1表示输出,0或者其他表示不输出
java -jar PackageXLSTooler.jar D:\data 1 1 0 0 "com.eray.data.vo" 0 0 0 1 D:\outputdata\xml D:\outputdata\dat > log.txt
pause