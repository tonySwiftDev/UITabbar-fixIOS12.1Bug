# UITabbar-fixIOS12.1Bug

## Problem:

 in ios12.1 , when popViewController animate, during  navigation controller go back to  UITabbarController, the item bar position is up. and it will take  1 to 2 seconds for the item bar to  be normal.



## tip:

 the  solution is just for fix   **ios12.1**  bug.  and  It's better for **swift** project. 


#How to do:
 - You just  **add the file to you project**. 
 - on the  top of the file (UITabbar+fixIOS12.1Bug.swift), you will see  a constant,kIPhoneXSeriesTabbarButtonHeight, you modify accroding to  what value you use for tabbarr Height on the iPhone x series   .example 78.0.you modify to  **let** kIPhoneXSeriesTabbarButtonHeight: CGFloat = 78.0
 - just run your project         
 - 


## Thanks for you:
Thanks for you coming . If it work for you , please please please give me a **start**  on the top right corner.



##问题：

iOS12.1 popViewControllerAnimated，UINavigationController返回时，item出现错位，文字消失，图标及小圆点出现位置偏移。过1-2秒才恢复到正常位置

X系列 tabbar 位置错乱

iOS12.1 tabbar 每次出现icon会跳一下, 之前没有



##如何做：
你只要下载这个文件放到你的项目中，就可以了，不用其他操作。

因为这个方案是运行时注入，并不清楚你在iphoneX系列(X,Xs,XR,Xs Max)的机型中，使用的tabbar 高度.所以需要你在 文件顶部 **找到**这个常量**kIPhoneXSeriesTabbarButtonHeight**，然后**更改**为你实际项目中的iphoneX系列的tabbar高度

另外这是一个swift文件，所以是为 **swift项目**准备的。 

如果对你有帮助，请在右上角给个**星**，非常感谢















