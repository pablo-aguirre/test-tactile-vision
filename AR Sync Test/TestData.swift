//
//  TestModel.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 20/11/24.
//

import Foundation
import simd

@Observable
class TestData: Codable {
    var status: String
    
    var iphone2D: CGPoint
    var iphone3D: SIMD3<Float>
    
    var handPoint: SIMD3<Float>
    var underHandPoint: SIMD3<Float>
    var distance: Float {
        return simd_distance(handPoint, underHandPoint)
    }
    
    init(iphone2D: CGPoint, iphone3D: SIMD3<Float>, handPoint: SIMD3<Float>, underHandPoint: SIMD3<Float>, status: String) {
        self.iphone2D = iphone2D
        self.iphone3D = iphone3D
        self.handPoint = handPoint
        self.underHandPoint = underHandPoint
        self.status = status
    }
}

extension simd_float3 {
    var dataDescription: String {
        return "\(x),\(y),\(z)"
    }
}

extension CGPoint {
    var dataDescription: String {
        return "\(x),\(y)"
    }
}
