1.for ipairs(a)
{
	for i, v in ipairs({[2]="dd"}) do print(v) end; -- [输出无内容]
 	for i, v in ipairs({"a",[3]="dd"}) do print(v) end; -- a
 	for i, v in ipairs({"a",[3]="dd","rr"}) do print(v) end; -- a rr dd
}


2.元表 元方法
t = {}
setmetatable(t, t1)
assert(getmetatable(t) == t1)
当访问一个table不存在的字段时，得到的结果为。寻找__index元方法. k
当对一个table中不存在的索引赋值时，解释器会查找__newindex元方法. k, v
-- 调用rawset(t, k, v) rawget(t, k) 允许绕过元方法
-- 默认值，只读table，继承 


3.官方继承：https://www.cnblogs.com/howeho/p/4048201.html
Object = {class_id = 0}
function Object:new(o)
    o = o or {}
    setmetatable(o,self) -- 对象o调用不存在的成员时都会去self中查找，而这里的self指的就是Object
    self.__index = self
return o
end
---以下我们创建对象来测试以下
local o1 = Object:new()
o1.class_id = 11;
local o2 = Object:new()
o2.class_id = 22;
---以上我们就利用元表实现了一个类，但这个类没有任何行为，以下我们继承上面的类
DisplayObject = Object:new()

-- 现在为止，DisplayObject只是Object的一个实例，注意以下代码
D = DisplayObject:new(width = 100,height = 50)
-- DisplayObject从Object继承了new方法，当new执行的时候，self参数指向DisplayObject。
-- 所以，D的metatable是DisplayObject，__index 也是DisplayObject。这样，D继承了DisplayObject，后者继承了Object。
---在Lua中面向对象有趣的一个方面是你不需要创建一个新类去指定一个新的行为。


4.闭包：通过调用含有一个内部函数加上该外部函数持有的外部局部变量（upvalue）的外部函数（就是工厂）产生的一个实例函数；
尾调用，当一个函数调用是另一个函数的最后一个动作时尾调用不会消费栈空间，所以一个程序可以拥有无数嵌套的尾调用。举例，调用以下函数时，传入任何数字作为参数都不会造成栈溢出：
迭代器与泛型for: 编写使用泛型for的迭代器Iterator.
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

