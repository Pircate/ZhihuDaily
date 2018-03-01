//
//  ComponentFactory.swift
//  ChengTayTong
//
//  Created by GorXion on 2018/2/9.
//  Copyright © 2018年 adinnet. All rights reserved.
//

import Foundation

protocol Factorable {
    static var componentName: String { get }
    var needsUnload: Bool { get }
    
    init()
    static func load() -> Self
    static func unload()
}

extension Factorable {
    static var componentName: String {
        return "\(self)"
    }
    
    static func load() -> Self {
        return ComponentFactory.load(self)
    }
    
    static func unload() {
        ComponentFactory.unload(componentName)
    }
}

final class ComponentFactory {
    
    private var componentContainer: [String: Factorable] = [:]
    
    private static let shared = ComponentFactory()
    private init() {}
    
    public static func load<T: Factorable>(_ component: T.Type) -> T {
        return ComponentFactory.shared.loadComponent(component)
    }
    
    public static func unload(_ componentName: String) {
        ComponentFactory.shared.unloadComponent(componentName)
    }
    
    private func loadComponent<T: Factorable>(_ component: T.Type) -> T {
        if let cpt = componentContainer[component.componentName] as? T {
            return cpt
        }
        
        unloadNeedlessComponent()
        
        let cpt = component.init()
        objc_sync_enter(self)
        componentContainer.updateValue(cpt, forKey: component.componentName)
        objc_sync_exit(self)
        return cpt
    }
    
    private func unloadComponent(_ componentName: String) {
        objc_sync_enter(self)
        componentContainer.removeValue(forKey: componentName)
        objc_sync_exit(self)
    }
    
    private func unloadNeedlessComponent() {
        componentContainer.forEach { (name, component) in
            if component.needsUnload {
                ComponentFactory.unload(name)
            }
        }
    }
}
