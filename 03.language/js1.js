https://www.jianshu.com/p/2ef9549c23f4

1.变量类型：值类型和引用类型
值类型：
引用类型：数组、函数和对象。//引用类型公共空间是指针
var a=
{
	age:200
};
var b=a;
b.age=21;
console.log(a.age) //21

2.typeof只能区分值类型的详细类型，对应用类型无能为力，但可以区分出函数来
typeof undefined; //undefined
typeof 'abc'; //string
typeof true; //boolean
typeof {}; //object
typeof []; //object
typeof null; //object
typeof console.log; //function
//js 数组元素的索引是从0开始的

3.强制类型转换
***字符串拼接
var a=100+10; //110
var b=100+'10'; //'10010'
***==运算符
100 == '100'; //true
0 == ''; //true
null == undefined; //true
***if语句
var a=true;
var b=100;
var c='';
if (a) {}
if (b) {}
if (c) {}
***逻辑运算
console.log(10&&0) //0
console.log(''||'abc') //abc
var a=100;
console.log(!!a) //true

*练习题
if (obj.a==null){
	//这里相当于obj.a===null||obj.b===undefined,简写形式
	//这是jquery源码中推荐的方法，其他的都用===
}
JS中有哪些内置函数的数据封装类对象
//js作为单纯语言的内置函数
Object
Array
Boolean
Number
String
Function 
Date 
RegExp
Error
//Global浏览器内置对象
//Math是对象，不是函数
//JSON只是一个对象
JSON.stringfy({a:10, b:20});
JSON.parse('{"a":10, "b":20}');
注意：JS中为false的为 0 NaN null undefined '' false

https://www.cnblogs.com/gcywj/p/8975616.html

4.变量的作用域: 同 lua
5.一行代码调用多个语句: var a=1,b,c='nu';
6.变量的声明 与 赋值: var 声明变量，未赋值的变量类型为undefined
7.数据类型
undefined, var声明，但未赋值的变量
Boolean 
Number
String
null, 表示空引用
Object 对象（数组 统称为对象）
function () {函数}

8.常用数值函数
isNaN用于检测一个变量，是不是一个非数值。（调用Number函数，尝试将变量转为数值类型）
Number函数,用于将各种类型转为数据类型
undefined NaN
null 0
true false 1 0
纯数值字符串，可以；否则 NaN; 
如果字符串‘’ 0；‘ ’ 0；
parseInt()将字符串转为数值，和Number有区别
typeof() 六种一共

9.
alter() 弹框输出
prompt() 弹框输入：参数都可省略：输入提示内容；输入框的默认文本；
document.write(); 在浏览器屏幕上打印
console.log(); 浏览器控制台打印
var str = prompt("请输入一句话", "你真帅")
alter(str);
=== == !== != ^异或
& | 只能进行按位运算，如果两边不是数值类型，将转为数值类型运算

10.
console.log(NaN===NaN);//false
typeof(NaN); //??? 
for (var i = 0; i < Things.length; i++) {
	Things[i]
}
if () {} else {}
var num = 1; //switch结构的（）可以放各种数据类型，采用===判断。
switch(num)
{
	case '1':
	break;
	default:
	break;
}
while(condition)
{
	//run
}

11.js函数的声明与调用
function xx_(p0, p1)
{
	return true;
}
没返回值，接收为undefined
函数声明调用，没有先后之分
func()
function func(){}
返回值个数？？

12.匿名函数，一定要先声明
var func = function(){}
func()
直接将匿名函数赋值给一个事件：
windows.onload=function(){}//加载后直接执行
自执行函数：
//https://segmentfault.com/a/1190000006813113
//开头用！表示这是自执行函数。 推荐
//用() 将匿名函数声明与调用包裹在一起。 推荐
//用()将匿名函数声明语句进行包裹。


12.js代码的执行顺序
检查编译阶段：检查语法错误，变量的声明，函数的声明等
代码执行阶段：变量的赋值、函数的调用等执行语句

https://blog.csdn.net/qq_37321858/article/details/82143427

13.js中数组和对象的区别和操作
对象 属性-值 的集合；数组 值 的集合；
var obj = {};
var arr = [];
obj[2] = 'a';
arr[2] = 'a';
console.log(obj[2]);//a
console.log(arr[2]);//a
console.log(obj.length);//undefined
console.log(arr.length);//3
for (var i in stu)
{
}
var arr = [1,2,3,4,5,6]
var stu =
{
	name:"a",
	sex:'ss',
}
数组和对象，里面什么类型都可以放

14.js基础的三座大山
原型 原型链
作用域 闭包
异步 单线程

https://www.jianshu.com/p/dee9f8b14771

15.普通对象与函数对象
Object Function 是js自带的函数对象
var o1 = {};
var o2 = new Object();
var o3 = new f1();
function f1() {};
var f2 = function () {};
var f3 = new Function('str', 'console.log(str)');
o1 o2 o3 为普通对象
f1 f2 f3 为函数

16.构造函数
o3.constructor == f1。o3是构造函数f1的实例
function Person(name, age, job) {
 this.name = name;
 this.age = age;
 this.job = job;
 this.sayName = function() { alert(this.name) } 
}
var person1 = new Person('Zaxlct', 28, 'Software Engineer');
var person2 = new Person('Mick', 23, 'Doctor');

17.原型对象
每当定义一个对象（函数也是对象），对象中都会包含一些预定义的属性。
其中每个函数对象都有一个属性prototype，这个属性只想函数的原型对象。
function Person () {}
Person.prototype.name = "aaa"
Person.prototype.xxfunc = function() {
	console.log(this.name)
}
var persion1 = new Person()
person1.xxfunc()
**每个对象都有__proto__属性，但只有函数对象才有 prototype 属性 

18.原型对象
function Person () {}
Person.prototype = 
{
   name:  'Zaxlct',
   age: 28,
   job: 'Software Engineer',
   sayName: function() {
     alert(this.name);
   }
}
规定 Person.prototype.constructor == Person
在 Person 创建的时候，创建了一个它的实例对象并赋值给它的 prototype
结论：原型对象（Person.prototype）是 构造函数（Person）的一个实例。

原型对象其实就是普通对象（但 Function.prototype 除外，它是函数对象，
但它很特殊，他没有prototype属性（前面说道函数对象都有prototype属性））


19.那原型对象是用来做什么的呢？主要作用是用于继承。
  var Person = function(name){
    this.name = name; // tip: 当函数执行时这个 this 指的是谁？
  };
  Person.prototype.getName = function(){
    return this.name;  // tip: 当函数执行时这个 this 指的是谁？
  }
  var person1 = new person('Mick');
  person1.getName(); //Mick









