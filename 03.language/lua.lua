1.Lua 程序设计; Lua 5.1
特性
表
标准库
Lua C 关系

2.字符串 代码 转化
关于编码的字符串问题
手动复制nil与自动遗弃
字符串相关函数：string.gsub("one string", "one", "another")
字符串相关函数:	string.find, --https://www.jb51.net/article/58375.htm
lua 转义字符 \u ?
关于取模和取余 的不同
关于userdata 和 thread 使用
关于userdata 与 table 的使用
lua 垃圾收集器 garbage collector
关于 a = {} 逐渐插入数值到 a 时, 表的变化情况
关于字符串连接的效率问题 .. string.format()
引用类型：函数，表，

3.
nil boolean number function string userdata thread table 
false nil 
4 4.57e-3 0.3e12
"" ‘’ 都可
转义字符：" \a \b \f \n \r \t \v \\ \" \' "
字符串和数字，+-*/%..自动转换
#长度操作符：#“hello” = 5; #arr 数组长度  有间隔会导致有误 勿使用即可;
#长度操作符：为 5.1新函数，并不好用
使用 table.maxn(), 将返回一个table的最大正索引数
x, y = y, x;

4.
表 可以使用字符串或其他类型的值 除nil 来索引它
lua 也是通过table来表示 模块(module)/包(package)/对象(object)的.
a["x"] = a.x 

5.userdata类型，可以将任意的C语言数据存储到Lua变量中。
在Lua中，这种类型没有太多预定义操作，只能进行赋值和相等性测试。
userdata 用于表示一种由应用程序或C语言库所创建的新类型，
例如标准的I/O库就用userdata来表示文件。
稍后将在CAPI中详细讨论这种类型。

6.
math.pi 
math.random()
math.abs()
math.sin(0)
a % b = a - floor(a/b) * b;
x = x or 0
a ? b : c => a and b or c， 前提是b不为假，所以最好用if-slse
数组索引1开始

7.
程序块 chunk
do
	--严格控制某些局部变量的作用域
end
Lua 中，有一种习惯写法 local foo = foo; 保存值，加速访问
在需要时才声明变量，可以使变量初始化有意义，缩短变量作用域，有助于提高代码可读性

8.
if then elseif then else end 
lua 不支持switch, 但是可以自己构造个
数字for
math.huge 常量，当做循环上限
for i=1,10 do
	-- 不要在循环中修改控制变量的值
end
泛型for
for i,v in ipairs(table_name) do
	-- array , 到空隙, 索引中断停止遍历
end
for k,v in pairs(table_name) do 
	-- all
end

9.
冒号操作符，隐含底将o作为函数参数传入
多重返回值
(foo()) 将一个函数调用放入一对圆括号中，从而迫使它只返回一个结果
unpack: 它接手一个数组作为参数，并从下标1开始返回该数组的所有元素
a, b = unpack({10, 20, 30})
变长参数：
function add(...)
	local t = { ... }
end
-- select 这么使用，效率母鸡
for i=1,select("#", ...) do --参数个数
	local arg = select(i, ...) --得到第一个参数
end

10.深入函数
function foo(x) return 2*x end
foo = function(x) return 2*x end
table.sort() 
闭合函数
local newCounter = function ( ... )
	local i = 0;
	return function ( ... ) --匿名函数
		i = i + 1;
		return i;
	end
end
c1 = newCounter();
c2 = newCounter();
c1() -- 1
c1() -- 2
其中c1和c2同一个函数所创建的两个不同的closure, 他们各自拥有局部变量i的独立实例.
通过这种技术，可以在Lua的语言层面上就构建出一个安全的运行环境。

11.
local fact = function(n)
	if (n == 0) then 
		return 1;
	else
		return n*fact(n - 1) -- 错误
	end
end
local fact 
fact = function(n)
	if (n == 0) then 
		return 1;
	else
		return n*fact(n - 1)
	end
end
local function fact(n) -- 这个技巧对于间接递归的函数而言是无效的
	if (n == 0) then 
		return 1;
	else
		return n*fact(n - 1)
	end
end

12.尾调用，当一个函数调用是另一个函数的最后一个动作时
尾调用不会消费栈空间，所以一个程序可以拥有无数嵌套的尾调用。
举例，调用以下函数时，传入任何数字作为参数都不会造成栈溢出：
function foo (n)
	if (n > 0) then return foo(n - 1) end
end
错误举例：
function f(x) g(x) end
return g(x) + 1 
return x or g(x)
return (g(x))
在Lua中, 只有“return <func>(<args>)”才是。lua会在调用前对<func>及其参数求值。
--
闭包和尾调用, https://www.cnblogs.com/JensenCat/p/5112420.html

13.迭代器与泛型for: 编写使用泛型for的迭代器Iterator.
所谓迭代器就是一种可以遍历一种集合中所有元素的机制。
function values (t)
	local i = 0
	return function () i = i + 1; return t[i] end
end
t = {10, 20, 30}
-- iter = values(t)
-- while true do
-- 	local element = iter()
-- end
for element in values(t) do 
	print(element)
end

14.上述迭代器都有一个缺点，就是需要为每个新循环都创建一个新的closure。
泛型for再循环过程内部保存了迭代器函数。实际上它保存着3个值：一个迭代器函数、一个恒定状态和一个控制变量。
泛型for的语法如下：
for <var-list> in <exp-list> do 
	<body>
end
其中，<var-list>是一个或多个变量名的列表，以逗号分隔；<exp-list>是一个或多个表达式的列表，以同样以逗号分隔。
通常表达式列表只有一个元素，即一句对迭代器工作的调用。
例如，以下代码：
for k,v in pairs(t) do
	print(k,v)
end
其中变量列表是“k, v”, 表达式列表只有一个元素pairs(t)。一般来说变量列表中也只有一个变量。
在这里，迭代的状态就是需要遍历的table (一个恒定状态，它不会在循环中改变)及当前的索引值（控制变量）。
ipairs(工厂)和迭代器都非常简单
local function iter (a, i)
	i = i + 1;
	local v = a[i]
	if v then
		return i, v
	end
end
function ipairs(a)
	return iter, a, 0
end

15.迭代器与泛型for

16.编译、执行与错误
-- https://blog.csdn.net/hai200501019/article/details/52938863
dofile 是lua内置的函数，用于执行代码块。
loadfile 从一个文件加载lua代码块，但它不会运行代码，只是编译代码，然后将编译的结果作为一个函数返回
loadstring 类似于loadfile，它从一个字符串中读取代码，而非从文件读取。loadstring 总是在全局环境中编译他的字符串
-- f = loadstring("local i = 0; i = i + 1;")
-- dofile(f);
require 引入LUA代码
-- require("app.models.command")
-- package.loaded["app.models.parametertest"] = nil
package.loadlib 调用C代码
local libname = "/usr/local/lib/lua/5.1/socket.so"
local funcname = "luaopen_socket"
local f = package.loadlib(libname, funcname) 聚集了有关动态链接的功能，他有两个参数.
-- error assert pcall
--https://www.jianshu.com/p/744702f1b2ae
error("invalid input")
assert(v[,message]) v 是要检查是否有错误的一个参数.
--
pcall(f, arg1, ···) --无
xpcall(f, err) --自定义或 debug.debug() --debug.traceback([thread,][message[,level]])
pcall 函数会以一种保护模式来调用他的第一个参数，捕获函数中的错误，
local status, err = pcall(function() print("hello"); error({code=999}) end) )
print(status, err.code)
xpcall(main, traceback), 
--


17.协同程序 coroutine 
Lua将所有关于协同程序的函数放置在一个名为“coroutine”的table中。
函数create用于创建新的协同程序，它只有一个参数，就是一个函数。返回一个thread类型的值。
co = coroutine.create(function() 
	print("hi") 
end)
一个协同程序可以处于4种不同的状态：挂起suspended，运行running，死亡dead，正常normal。
当穿件一个协同程序时，它处于挂起状态。
print(coroutine.status(co)) --> suspended
函数coroutine.resume用于启动或再次启动一个协同程序的执行，并将其状态由挂起改为运行。
coroutine.resume(co) --> hi
打印“hi”后便终止了，然后它就处于死亡状态，也就再也无法返回了。
print(coroutine.resume(co)) --> false cannot resume dead coroutine.
注意：resume是在保护模式中运行的。因此，如果在一个协同程序的执行中发生任何错误，lua是不会显示错误消息的，
而是将执行权返回给resume调用。
--
co = coroutine.create(function() 
	for i=1,10 do
		print("hi") 
		coroutine.yield()
	end
end)
coroutine.resume(co) --> hi
当唤醒这个协同程序时，它就会开始执行，直到第一个yield。之后处于挂起状态，因此可以再次恢复其运行。

18.管道（pipe）与过滤器（filter）
生产者-消费者
添加过滤器

19.文件操作与串行化（Serialization）
串行化：将数据转换为一个字节流或字符流。然后就可以将其存储到一个文件中，或者通过网络连接发送出去了。
function n_serialize(data)
	if type(data) == "number" then
		io.write(data, "\n")
	elseif type(data) == "string" then
		ui,write(string.format("%q\n", data))
	elseif type(data) == "table" then
		io.write("{\n");
		for k,v in pairs(data) do
			-- io.write("  ", k, "=") --key为数字或者非法Lua标识符不行
			io.write(" [*'); serialize(k); is.write('] = ")
			n_serialize(v)
			-- io.write(",\n")
		end
		io.write("}\n")
	else
	end
end
tbl={a=12,b="lua"}
n_serialize(tbl)
local fw = assert(io.open("text.txt", "w"))
fw:write("hello world")
fw:close()
local fr = assert(io.open("text.txt", "r"))
print(fr:read("a"))
fr:close()
for line in io.lines("main.lua") do
	print(line)
end
-- 字符串转说明：%q
-- io.write("'", o, "'") -- 特殊字符：引号，换行有问题
-- io.write("[[", o, "]]") -- ]] .. os.execute('rm *') .. [[ 加载这个数据会出现不可估量的结果
-- 5.1 用于长字符串 [=[]=]

20.字符串库
string.len(s)
string.rep(s, n) --返回字符串s重复n次的结果，repeat
string.lower(s) --所有大写的内容变为小写
string.upper(s)
string.sub(s, i, j) --提取字符串s的第i个到第j个字符，Lua中，第一个字符的索引值为1，最后一个为-1
string.format(s, ...)
string.char(...) --参数为0到多个整数，并将每个整数转换为对应的字符。然后返回由这些字符连接而成的字符串
string.byte(s, i) --返回字符串s的第i个字符串的ASCII值，第二个参数缺省值为1。
-- https://www.twle.cn/l/yufei/lua53/lua-basic-strings-format.html
-- 格式说明符：%q 接受一个字符串并将其转化为可安全被Lua编译器读入的格式
string.find("hello world", "ello") -- 2, 5
string.find("hello world", "sss") -- nil

21.大量字符串拼接（string.format 不合适）
运算符： .. 每次拼接都需要申请新的空间，旧的result对应的空间会在某时刻被Lua的垃圾回收期GC，
且随着result不断增长，越往后会开辟更多新的空间，并进行拷贝操作，产生更多需要被GC的空间，所以性能降低
使用 table.concat( table [, spe[, start [, end]]]) 函数：
function tableConcat(str, count)
	local tbl = {}
	for i=1,count do
		table.insert(tbl, str)
	end
	return table.concat(tbl)
end
table.concat 底层拼接字符串的方式也是使用运算符 .., 但是其使用算法减少了使用运算符的次数，减少了GC,
从而提高效率。主要思路：采用二分思想，用栈存储字符串，新入栈的字符串与下方的字符串比较长度。

22.元表 元方法
t = {}
setmetatable(t, t1)
assert(getmetatable(t) == t1)
当访问一个table不存在的字段时，得到的结果为。寻找__index元方法. k
当对一个table中不存在的索引赋值时，解释器会查找__newindex元方法. k, v
-- 调用rawset(t, k, v) rawget(t, k) 允许绕过元方法
-- 默认值，只读table，继承 

23.单一继承
基类
Account = {balance = 0}
function Account:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
function Account:hello()
	print("hello")
end
派生子类
SpecialAccount = Account:new()
function SpecialAccount:hello()
	print("SpecialAccount")
end
s = SpecialAccount:new({limit = 0.0})
s:hello()
-- 私密性local 单一方法做法
function newObject(value)
	return function (action , v)
		if (action == "get") then return value
		elseif (action == "set") then value = v 
		else 
			error("hehe")
		end
	end
end
d = newObject(0)
d("get")
-- 一个对象只有一个方法时，可以不用创建接口table，但要将这个单独的方法作为对象表示来返回。

24.弱引用：__mode = "k" ; "v"; "kv"
collectgarbage([opt[,arg]]) -- 强制进行一次垃圾收集
https://blog.csdn.net/shimazhuge/article/details/40310233
Lua采用了自动内存管理，我们不需要删除对象，Lua会自动地删除那些已经成为垃圾的对象、
最重要的就是！当我们在纠结c++在回收时的环形引用问题时，Lua早就走在了前面，它没有环形引用问题，当要用到环形结构时，也能被正常回收。
垃圾回收器只会回收它认为是垃圾的东西，所以当我们使用栈的时候就会出现一个问题：我们以为我们不再使用的对象被回收了，但是其实它还没有被回收。
##当我们数组中引用了一个对象，那么这个对象就无法被回收了。为了解决这个问题，lua引入了弱引用
##lua只会回收弱引用table中的对象，数字和布尔值以及字符串是不可回收的。
-- key值弱引用,也就是刚刚说到的情况,只要其他地方没有对key值引用,那么, table自身的这个字段也会被删除。设置方法:setmetatable(t, {__mode = “k”});
-- value值弱引用,情况类似,只要其他地方没有对value值引用,那么,table的这 个value所在的字段也会被删除。设置方法:setmetatable(t, {__mode = “v”});
-- key和value弱引用,规则一样,但是key和value都同时生效,任意一个起作用时都 会导致table的字段被删除。设置方法:setmetatable(t, {__mode = “kv”});

25.lua 文件加密
-- https://www.zhihu.com/question/21853681























