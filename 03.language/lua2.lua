--[[lua协程原理：异步
https://www.cnblogs.com/zrtqsk/p/4374360.html
https://blog.csdn.net/qq_36748278/article/details/79967713
经典并发问题：生产者-消费者
（1）线程
　　首先复习一下多线程。我们都知道线程——Thread。每一个线程都代表一个执行序列。
　　当我们在程序中创建多线程的时候，看起来，同一时刻多个线程是同时执行的，不过实质上多个线程是并发的，
因为只有一个CPU，所以实质上同一个时刻只有一个线程在执行。
　　在一个时间片内执行哪个线程是不确定的，我们可以控制线程的优先级，不过真正的线程调度由CPU的调度决定。
（2）协程
　　那什么是协程呢？协程跟线程都代表一个执行序列。不同的是，协程把线程中不确定的地方尽可能的去掉，
执行序列间的切换不再由CPU隐藏的进行，而是由程序显式的进行。
　　所以，使用协程实现并发，需要多个协程彼此协作。
-- 生产者
local function productor()
	local i = 0
	while true do
		i = i + 1
		coroutione.yield(i)
	end
end
-- 创建
local newProductor = coroutine.create(productor)
-- 消费者
local function consumer()
	while true do
		local status,value = coroutine.resume(newProductor)
		print(status, value)
	end
end
-- 开始
consumer()
--]]
--[[lua元表实现继承
https://www.cnblogs.com/howeho/p/4048201.html
--]]
--[[luagc机制
lua采用了标记清除式（Mark and Sweep）GC算法，算法简述：
标记：每次执行GC时，先以若干根节点开始，逐个把直接或间接和它们相关的节点都做上标记；
清除：当标记完成后，遍历整个对象链表，把被标记为需要删除的节点一一删除即可。
lua用白、灰、黑三色来标记一个对象的可回收状态。(白色又分为白1、白2)
总结一: 如何监测Lua的编程产生内存泄露:
1.       针对会产生泄露的函数,先调用collectgarbage("count"),取得最初的内存使用
2.       函数调用后, collectgarbage("collect")进行收集, 并使用collectgarbage("count")再取得当前内存, 最后记录两次的使用差
3.       从test1的收集可看到, collectgarbage("collect")被调用，并不保证一次成功, 所以, 大可以调用多次
总结二: 如何避免Lua应用中出现的内存使用过大行为:
1.       当然是代码实现不出现泄露
2.       在测试中，其实还发现, Lua中被分配的内存，其实并不会自动回收(个人估计要么就是Lua虚拟机没有做这个事情，要么就是回收的时机是在C层),
 所以, 为了避免内存过大, 应用的运行时，可能需要定期的（调用collectgarbage("collect")，又或者collectgarbage("step")）进行显式回收。
--]]
--[[luac互调
https://www.jb51.net/article/132851.htm
--]]
--[[垃圾回收器函数
collectgarbage("setpause"): 将 arg 设为收集器的 间歇率。 
collectgarbage("setstepmul"): 返回 步进倍率 的前一个值。
--
collectgarbage("collect"): 做一次完整的垃圾收集循环。
collectgarbage("count"): 以 K 字节数为单位返回 Lua 使用的总内存数。
collectgarbage("restart"): 重启垃圾收集器的自动运行。
collectgarbage("stop"): 停止垃圾收集器的运行。
--
collectgarbage("setpause", 200) ： 内存增大 2 倍（200/100）时自动释放一次内存 （200 是默认值）
collectgarbage("setstepmul", 200) ：收集器单步收集的速度相对于内存分配速度的倍率，设置 200 的倍率等于 2 倍（200/100）。（200 是默认值）
--]]
