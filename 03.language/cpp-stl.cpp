--[[
https://blog.csdn.net/xp731574722/article/details/76101089?depth_1-utm_source=distribute.pc_relevant.none-task&utm_source=distribute.pc_relevant.none-task
vector:{
    https://blog.csdn.net/qq_33434631/article/details/82997578?depth_1-utm_source=distribute.pc_relevant.none-task&utm_source=distribute.pc_relevant.none-task
    #include < vector > 向量，不定长数组。不需要指定长度，vector动态分配空间（线性连续地址）
    创建：
        vector<int> v1; //默认初始化，v1为空        
        vector<int> v2(10); //初始10个值为0的元素
        vector<double> v3(10,8.6); //初始10个值为8.6的元素
        vector<int>::iterator it;
    访问：
        cout<<v2[2]<<endl; //直接通过下标就能访问
        cout<<*(v2.begin()+2)<<endl; //通过迭代器访问
    赋值：
	    v2[2]=3;
    遍历：     
        for(int i=0;i<v3.size();i++)
            cout<<v3[i]<<' '; //①通过下标遍历
        for(it=v2.begin();it!=v2.end();it++)
            cout<<*it<<' '; //②通过迭代器遍历（推荐）
    尾部添加：
        v.push_back(9); // ①元素尾部扩张
    插入：
        v.insert(v.begin()+2,1);
        v.insert(v.end(),3); 
    排序：
        sort(v.begin(),v.end()); //递增
        reverse(v.begin(),v.end()); //元素反向排列
    etc:
        for_each(v1.begin(),v1.end(),[](int value){cout << value << " ";});
}
map:{
    #include< map > 映射；map就是从键（key）到值（value）的映射；
    创建：
        map<string,double> m;
        map<string,double>::iterator it;
    遍历：
        for(it=m.begin();it!=m.end();it++)
            cout<<(*it).first<<":"<<(*it).second<<endl;
    判断访问：
        it=m.find("Jack");
        if (it!=m.end()) cout<<"Jack found"<<(*it).second<<endl;
    访问：
        //访问时如果map中不存在该键值，实值为空，对于数字则为0，字符串则为空串。
        cout<<m["Jack"]<<endl;
    赋值：
        m["Jack"]=5;
    删除：
        //m.erase(5); //删除值为5的元素，返回删除的元素个数
        m.erase(m.begin());
    清空：
        m.clear();
    etc:
        //count       ：  在序列中统计某个值出现的次数
}
set:{
    采用了红黑树的平衡二叉树的数据结构。
    其内部元素会根据元素的键值自动被排序
}
stack:{
    栈
    stack<int> s;
    s.push(8);
    s.pop();
    s.top(); //取栈顶元素（但不删除）
}
queue:{
    队列
    queue<int>  q1;queue<string> q2; 
    q1.push(5);    //排队，把5放进去
    q1.pop();      //弹队 先进先出 
    q1.front(); //访问队列中最早进入队列的元素
    q1.back();  //访问队列中最后进入队列的元素 
    q1.size();  //队列中元素的个数
    q1.empty(); //队列中的元素是否为空
}
--]]