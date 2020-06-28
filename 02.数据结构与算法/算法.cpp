5.二分法代码补全；
https://juejin.im/post/5cd3f36b6fb9a0323a01cea1
public static int binary(int[] arr, int data)
 {
 	int min = 0;
 	int max = arr.length - 1;
 	int mid;
 	while (min <= max) {
 		// 防止溢出
 		mid = min + (max - min) / 2;
 		// mid = min + ((max - min) >>> 1); // 无符号位运算符的优先级较低，先括起来
 		if (arr[mid] > data) {
 			max = mid - 1;
 		} else if (arr[mid] < data) {
 			min = mid + 1;
 		} else {
 			return mid;
 		}
 	}
 	return -1
 }
--]]

6.斐波那契数列
题目描述
有 N 级的台阶，你一开始在底部，每次可以向上迈最多 K 级台阶（最少 1 级），问到达第 N 级台阶有多少种不同方式。

7.A*算法
A*算法在人工智能中是一种典型的启发式搜索算法，启发中的估价是用估价函数表示的：
f(n) = g(n) + h(n). [g(n)表示 从起始节点到 n 节点所需要的代价。h(n)表示 从n节点到目标节点所需要的代价。]
https://www.cnblogs.com/wangnfhy/p/4956711.html
https://wenku.baidu.com/view/39414aa4f8c75fbfc77db2a2.html
https://zhuanlan.zhihu.com/p/80707067
优化：
	动态衡量启发式：f(n) = g(n) + w(n) * h(n) , 其中 w(n) >= 1 。
	分级寻径：把搜索过程拆分开了，如查找空间A中的p1点到空间B中的p2点最短路径，那么可以分为两部分，先查找p1点到空间B的路径，再搜索到p2的路径，整个过程分为了两步，甚至是将计算一次的消耗，拆分成了两次，计算压力也变小了

8.一段字符串中搜索”aabb”首次出现的位置—KMP算法；
