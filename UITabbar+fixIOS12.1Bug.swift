//
//  UItabbar+fixIOS12.1Bug.swift
//
//
//  Created by tony on 2018/11/7.
//  Copyright © 2018 Senji. All rights reserved.
//

import Foundation

public protocol SwizzlingInjection {
    static func inject()
}


extension UIApplication {
    open override var next: UIResponder? {
        // Called before applicationDidFinishLaunching
        SwizzlingHelper.enableInjection()
        return super.next
    }
}

class SwizzlingHelper {
    
    static func enableInjection() {
        DispatchQueue.once(token: "com.SwizzlingInjection") {
            //what to need inject
            UITabbarButtonInjection.inject()
        }
    }
}


class UITabbarButtonInjection: SwizzlingInjection {
    static func inject() {
        //ios12.1问题
        guard  #available(iOS 12.1, *) else {return}
        
        guard let selfClass  = NSClassFromString("UITabBarButton")  else {
            return
        }
        let oriSelector: Selector = #selector(setter: UIView.frame)
        if let originalMethod = class_getInstanceMethod(selfClass,oriSelector) {
           
            let originalImp = method_getImplementation(originalMethod)
            
            //imp_implementationWithBlock的参数需要的是一个oc的block，所以需要指定convention(block)
            let newimpblock:@convention(block) (UIView,CGRect) -> Void = {
                (selfobject,frameagv) in
                if !selfobject.frame.isEmpty,frameagv.isEmpty {
                    return
                }
                
                var newFrame = frameagv
                //兼容iphoneX
                if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 {
                    let tabBarHeight = frameagv.size.height
                    let realTabBarHeight = Constant.tabBarHeight
                    if tabBarHeight != realTabBarHeight {
                        newFrame.size.height = realTabBarHeight
                    }
                }
                // call original same with in object-c oriImp(oriclass,oriMethod,frameage)
                //由于IMP是函数指针，所以接收时需要指定@convention(c)
                typealias SwiftImpType = @convention(c) (UIView,Selector,CGRect)->Void
                //将函数指针强转为兼容函数指针的闭包
                let swiftImp = unsafeBitCast(originalImp, to: SwiftImpType.self)
                //调用函数指针，需要使用 instance, 相当于调用 instance.selector
                swiftImp(selfobject,oriSelector,newFrame)
            }
           
            //imp_implementationWithBlock的参数需要的是一个oc的block, swift->oc
            let newImp = imp_implementationWithBlock(unsafeBitCast(newimpblock, to: AnyObject.self))
            method_setImplementation(originalMethod, newImp)
            
        }
    }
}


