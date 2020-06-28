--[[
网页地址####
shader学习笔记（一）https://www.jianshu.com/p/9cb34ea799ad
日积月累Shader: https://www.jianshu.com/p/9d70072f4f8c
HSV（HSB）模型：色相，饱和度，亮度：https://blog.csdn.net/hanchao123/article/details/47108881

shader内置变量和函数: https://www.jianshu.com/p/d35f3b052b4b
OpenGL和GLSL版本更迭 https://www.cnblogs.com/George1994/p/6418013.html
Shader学习建议 https://blog.csdn.net/zjz520yy/article/details/81023606
shader2.x3.x内置变量 https://blog.csdn.net/shenshen211/article/details/51802700/
--]]

--[[
其他记录
setBlendFunc
变灰：https://www.jianshu.com/p/013426f006fa
点乘：
float gray = dot(mycolor.rgb, vec3(0.2126, 0.7152, 0.0722));
gl_FragColor =  vec4(gray);
取模：-1 - -2*0 = 0, -1
--]]
--[[20191211：
Shader其实就是一段执行在GPU上的程序，此程序使用OpenGL ES SL语言来编写。
依靠着色器我们可以控制渲染流水线中的渲染细节，例如
用顶点着色器来进行顶点变换以及传递数据，
用片段着色器来进行逐像素渲染。
--]]
--[[20191213：
Shader中文翻译 着色器，是一种较为短小的程序片段，用于高速图形硬件如何计算和输出图像，
过去由汇编语言来编写，现在也可以使用高级语言来编写，
一句话概括：shader 是可编程图形管线的算法片段。
它主要分为两类，Vertex Shader和 Fragment Shader
Vertex Shader顶点shader（计算机中图形都是无数个顶点组成的）
Fragment Shader片段Shader（也可以说是顶点颜色填充处理）
什么是渲染管线？
渲染管线也称为渲染流水线,是显示芯片内部 处理图形信号相互独立的并行处理单元。
Vertex处理完后 Frament 处理
如果一次渲染有100顶点要处理，一次就会同时执行100次VertexShader的调用，
类似上面说的汽车装配流水线，一次有100个车同时装配左车门，下一步骤就是同时装配右车门
####cpu gpu 分界线 渲染流程图
渲染流程一次就是一次DC，
DrawCall是指CPU收集数据，传输给GPU调用GPU一次渲染命令，合理的控制DC可以增加你的渲染性能。
总结，渲染管线就是一次渲染流程，也是经常说的Draw Call一次DC。
Shader和材质，贴图的关系
材质好比引擎最终使用的商品，Shader好比生产这种商品的加工方法，而贴图就是原材料。
####shader基础知识
这两段代码实现的功能都是提取 2D 图像上每个像素点的颜色值，
第一段代码是用c++写的，在cup上面运行，它需要循环遍历每个像素点，
第二段代码是CG代码，在GPU上面运行，它只需要一行代码就能实现同样的功能。
GPU是专门用来进行图形处理的，而Shader，就是GPU执行的一段针对3D对象进行操作的程序。
####OpenGL的渲染流程
这个流程简化之后是这样的 
顶点变换 → 图元装配和光栅化 → 片元纹理映射和着色 → 写入帧缓存
在顶点变换和片元着色这两步时，我们就可以对其编程，进行各种操作，
其他的部分我们是没法进行编程的。我们的shader就是作用于顶点变换和片元着色这两个部分的。
shader的开发语言
HLSL: 主要用于Direct3D。平台:windows。
GLSL: 主要用于OpenGL。 平台:移动平台（iOS，安卓），mac(only use when you target Mac OS X or OpenGL ES 2.0)
CG：与DirectX 9.0以上以及OpenGL 完全兼容。运行时或事先编译成GPU汇编代码。
CG比HLSL、GLSL支持更多的平台，Unity Shader采用CG/HLSL作为开发语言。
####内置变量和函数
--]]
--[[shader基础
https://www.jianshu.com/p/d35f3b052b4b
https://blog.csdn.net/keen_zuxwang/article/details/71693297
https://www.cnblogs.com/chenggg/p/11204708.html
==修饰符
默认：无修饰符，普通变量读写， 与外界无连接；
修饰符const：常量 const vec3 zAxis = vec3(0.0, 0.0, 1.0);
修饰符：uniform，attribute和varying；uniform, in, out;
==精度
精度：highp, mediump, lowp；不同类型，默认精度不同;
精度设置：precision highp float; varying mediump vec2 Coord;
精度建议：vertex position； texture coordinate； colors；
==内置常量
==内置常量
gl_Position: 用于vertex shader, 写顶点位置；被图元收集、裁剪等固定操作功能所使用；
           其内部声明是：highp vec4 gl_Position;
gl_FragColor: 用于Fragment shader，写fragment color；被后续的固定管线使用；
            mediump vec4 gl_FragColor;
==外部函数
1、uint CreateShader(enum type) : 创建空的shader object; type: VERTEX_SHADER, 
2、void ShaderSource(uint shader, sizeicount, const **string, const int *length)：加载shader源码进shader object；可能多个字符串 
3、void CompileShader(uint shader)：编译shader object； shader object有状态 表示编译结果 
4、void DeleteShader( uint shader )：删除 shader object; 
5、void ShaderBinary( sizei count, const uint *shaders, enum binaryformat, const void *binary, sizei length ): 加载预编译过的shader 二进制串； 
6、uint CreateProgram( void )：创建空的program object， programe object组织多个shader object，成为executable; 
7、void AttachShader( uint program, uint shader )：关联shader object和program object； 
8、void DetachShader( uint program, uint shader )：解除关联； 
9、void LinkProgram( uint program )：program object准备执行，其关联的shader object必须编译正确且符合限制条件； 
10、void UseProgram( uint program )：执行program object； 
11、void ProgramParameteri( uint program, enum pname, int value )： 设置program object的参数； 
12、void DeleteProgram( uint program )：删除program object；
==
--]]


1.opengl的光照模型
https://blog.csdn.net/dcrmg/article/details/53121938
光源就是光的来源，是“光”这种物质的提供者；
材质反映的是光照射到物体上后物体表现出来的对光的吸收、漫反射、反射等性能； 
光照环境反应环境中所有光源发出的光经过无数次反射、漫反射之后整体环境所表现出来的光照效果。指定合适的光照环境参数可以使得最后形成的画面更接近于真实场景。

2.opengl有哪几种内存缓存类型
https://www.jianshu.com/p/34b6e36e90a5

3.opengl的渲染管线是怎样的
https://www.jianshu.com/p/4ddf560e2e3c

4.glsl内建函数
https://www.jianshu.com/p/ca9e9ff50c5b
vec4 texture2D(sampler2D sampler, vec2 coord)
The texture2D function returns a texel, i.e. the (color) value of the texture for the given coordinates.
第一个参数代表图片纹理，第二个参数代表纹理坐标点，通过GLSL的内建函数texture2D来获取对应位置纹理的颜色RGBA值

5.




















