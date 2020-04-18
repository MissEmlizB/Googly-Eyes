//
//  Common Extensions.swift
//  Googly Eyes
//
//  Created by Emily Blackwell on 19/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

// MARK: Image Extensions

#if os(macOS)

import Cocoa
public typealias GEImage = NSImage

extension NSImage {
    public var cgImage: CGImage? {
        var rect = CGRect(origin: .zero, size: self.size)
        return self.cgImage(forProposedRect: &rect, context: .current, hints: nil)
    }
}

#elseif os(iOS)

import UIKit
public typealias GEImage = UIImage

#endif

extension CGImage {
    
    var image: GEImage {
        #if os(macOS)
        
        let size = CGSize(width: self.width, height: self.height)
        return NSImage(cgImage: self, size: size)
        
        #elseif os(iOS)
        
        return UIImage(cgImage: self)
        
        #endif
    }
}

// MARK: CGPoint Extensions

extension CGPoint {
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    static func /(lhs: CGPoint, rhs: Int) -> CGPoint {
        return lhs / CGFloat(rhs)
    }
}


extension CGPoint: Comparable {
    
    public static func < (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return (lhs.x + lhs.y) < (rhs.x + rhs.y)
    }
}

// MARK: Colour Extensions

#if os(macOS)
import Cocoa
public typealias GEColour = NSColor
#elseif os(iOS)
import UIKit
public typealias GEColour = UIColor
#endif

extension GEColour {
    
    #if os(iOS)
    
    var components: [CGFloat] {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: nil)
        return [red, green, blue]
    }
    
    var redComponent: CGFloat {
        return components[0]
    }
    
    var greenComponent: CGFloat {
        return components[1]
    }
    
    var blueComponent: CGFloat {
        return components[2]
    }
    
    #endif
    
    var deviceColourspaceColour: GEColour? {
        #if os(macOS)
        return self.usingColorSpace(.deviceRGB)
        #elseif os(iOS)
        return self
        #endif
    }
}

