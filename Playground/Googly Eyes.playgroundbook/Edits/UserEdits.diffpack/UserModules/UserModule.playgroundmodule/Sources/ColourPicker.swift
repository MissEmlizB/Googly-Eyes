//
//  ColourPicker.swift
//  Googly Eyes
//
//  Created by Emily Blackwell on 18/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Foundation
import CoreGraphics


// MARK: Colour Picker

extension CGImage {
    
    static func fromImage(_ image: GEImage) -> CGImage? {
        
        #if os(macOS)
        var rect = CGRect(origin: .zero, size: image.size)
        return image.cgImage(forProposedRect: &rect, context: .none, hints: nil)
        
        #else
        return image.cgImage
        #endif
    }
    
    public func getColours(atPoints points: [CGPoint], bpc: Int? = nil, dataCache data: Data? = nil) -> [GEColour] {
        
        // Use the cache (if provided)
        var data: Data! = data
        
        // Get its raw data
        if data == nil {
            guard let d = self.dataProvider?.data as Data? else {
                return []
            }
            
            data = d
        }
        
        var bpc: Int! = bpc
        let bpr = self.bytesPerRow
        
        if bpc == nil {
            bpc = self.bitsPerComponent / 2
        }
        
        return points.map {
            // Get its index (in the data)
            let i = (Int($0.x) * bpc) + (Int($0.y) * bpr)
            
            // Make sure that we don't cause any crashes
            guard i >= 0 && i < data.count else {
                return .clear
            }
            
            // Get its RGBA components
            let components = (0...4).map {
                CGFloat(data[i + $0]) / 255.0
            }
            
            return .init(red: components[0],
                         green: components[1],
                         blue: components[2],
                         alpha: components[3])
        }
    }
}


