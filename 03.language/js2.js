1.

2.js在创建对象（不论是普通对象还是函数对象）的时候，都有一个叫做__proto__的内置属性，
.任何实例的构造函数，都是该对象
.对象的原型对象，是该对象的一个实例
.对象实例的__proto__属性，指向他的构造函数的原型对象
person1.constuctor = Person
Person.prototype.constuctor = Person
person1.__proto__ = Person.prototype
*.这个连接存在于实例（person1）与构造函数Person的原型对象（Person.prototype）之间，
而不是存在于实例（person1）与构造函数（Person）之间。

3.构造器
var obj = {};
等同于
var obj = new Object();
obj是构造函数（Object）的一个实例。
obj.constructor = Object
obj.__proto__ = Object.prototype
新对象obj是使用 new操作符后跟一个构造函数 来创建的。创建函数（Object）本身就是一个函数。
只不过该函数出于创建对象的目的而定义。
同理，可以创建对象的 构造器不仅仅有Obejct，也可以是Array，Date，Function等。所以我们
也可以构造函数来创建Array、Date、Function。
这些构造器 都是函数对象.

4.原型链  实例的__proto__属性 
person1.__proto__ = Person.prototype -- person1的原型
Person.__proto__ = Fucntion.prototype -- 构造函数的原型
Person.prototype.__proto__ = Object.prototype --原型对象的原型 对象
Object.prototype.__proto__ = null --特殊，对象也有proto属性，为null.

5.函数对象，【复习】
所有函数对象的proto属性都 指向 Function.prototype,它是一个空函数.
js中内置(build-in)构造器/对象一共12个：
*.Number Boolean String Object Function Array RegExp Error Date
Object,__proto__ === Function.prototype
Object.constructor == Function
所有[构造器]，都来自Function.prototype,甚至包括Object和Function自身。
*.Global不能直接访问，Arguments仅在函数调用时由js引擎创建
Math,JSON是以对象形式存在的，无需new。他们的proto是Object.prototype
Math.__proto__ === Object.prototype
Math.constructor == Object
*.上面说的函数对象，当然包括自定义的。如下

6.所有的构造器都来自于 Function.prototype, 甚至包括根构造器 Object以及Function自身。
所有构造器都继承了Function.prototype 的属性及方法。如length、call、apply、bind**
Function.prototype 也是唯一的 类型为 function 的 prototype; 其他的构造器的prototype都是对象。
Function.prototype.__proto__ === Object.prototype .函数是一等
** 所有的构造器也都是一个普通的js对象，可以给构造器添加/删除等属性。同时它也继承了Object.prototype
上的所有方法：toString、valueOf、hasOwnProperty等。
** 最后 Object.prototype.__proto__ = null

7.prototype
对于ECMAScript中的引用类型而言，prototype是保存着他们所有实例方法的真正所在。
换句话说，诸如toString()等方法实际上都保存在prototype名下，只不过是通过各自对象的实例访问罢了。
当创建一个函数时：
var Person = new Object()
Person 是 Object的实例，所以Person继承了 Object的原型对象Object.prototype上的所有方法。
当创建一个数组时：
var num = new Array()
.#num 是 Array的实例，所以num继承了 Array的原型对象Array.prototype上所有的方法。 空数组[]
.#ES5提供的新方法：Object.getOwnProperyNames(Array.prototype) 获取所有（包含不可枚举的属性）的属性名不包括prototype中
的属性，返回一个数组。 **没有输出constructor/hasOwnPrototype等对象的方法。
.#因为Array.prototype 虽然没这些方法，但是它有原型对象（__proto__）。
Array.prototype.__proto__ == Object.prototype。 所以继承了对象的所有方法.
当创建一个函数时：
var f = new Function("x", "return x*x;");
等同于 var f = function(x){return x*x; };
所有函数对象proto都指向Function.prototype, 它是一个空函数。

8.复习1
所有对象的__proto__ 都指向其构造器的prototype
所有函数对象的__proto 都指向 Function.prototype, 它是一个空函数。
9.复习2
Function.prototype.__proto__ === Object.prototype
Object.prototype.__proto__ === null

10.总结
原型和原型链是JS实现继承的一种模型。
原型链的行程是真正靠__proto__ 而非prototype
e.g.
var animal = function(){}
var dog = function(){}
animal.price = 2000;
dog.prototype = animals;
var tidy = new dog();
dog.price; //undefined
tidy.price; //2000
实例 和 构造器的原型对象 存在继承关系。

11.异步 和 单线程
js是单线程执行的语言，必须由异步
单线程：一次只能做一件事情
console.log(10);
setTimeout(function() {
	console.log(40)
}, 0);
setTimeout(function() {
	console.log(20)
}, 1000);
console.log(30);//异步
//打印结果是：10 30 40 20
//执行setTimeout时，这里面的函数会被存起来在一个队列里面，不会立即执行
//所有程序处理完，处理机处于空闲状态，立马看看队列里面有没有待执行的函数啥的
//发现setTimeout里面的函数，这个时候执行。
同步会阻塞代码运行，异步不会
console.log(1000);
alert(2000);//会阻塞，不会产生异步
console.log(3000);
//打印结果是：1000 2000（按确定之后出现3000）3000
前端需要使用异步的场景是哪些（需要等待的时候）
定时任务：setTimeout,setInterval
绑定时间：addEventListener (click等等)
网络请求：ajax和img动态加载





