//
//  UItabbar+fixIOS12.1Bug.swift
//
//
//  Created by tony on 2018/11/7.
//  Copyright © 2018 Senji. All rights reserved.
//

import Foundation
import UIKit

//tip: just modify , accordingly to your project ,what value set for tabbar height in iphonex Series
let kIPhoneXSeriesTabbarButtonHeight: CGFloat = 88.0

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
                let iphoneHeight = Int(UIScreen.main.nativeBounds.height)
                if UIDevice().userInterfaceIdiom == .phone ,  [2436,2688,1792].contains(iphoneHeight) {
                    let tabBarHeight = frameagv.size.height
                    
                    if tabBarHeight != kIPhoneXSeriesTabbarButtonHeight {
                        newFrame.size.height = kIPhoneXSeriesTabbarButtonHeight
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

//just extension dispatchDueue
public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}


