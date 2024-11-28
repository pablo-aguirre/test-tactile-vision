//
//  MainScreen2Seconds.swift
//  AR Sync Test
//
//  Created by Pablo Aguirre on 28/11/24.
//


import SwiftUI
import simd
import os.log

struct MainScreen2: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var session: MultipeerSession
    @State private var testData: TestData
    @State private var imageSize: CGSize = .zero
    @State private var isTouching: Bool = false
    @State private var ipad2D: CGPoint = .zero
    @State private var currentTime: TimeInterval = .zero
    private let startTime: Date = .now
    
    private let fileLogger: FileLogger
    let normalizedPoints: [CGPoint]
    
    init(xPoints: Int = 10, yPoints: Int = 10) {
        let testData: TestData = .init(iphone2D: .zero, iphone3D: .zero, handPoint: .zero, underHandPoint: .zero, status: "")
        self.testData = testData
        self._session = StateObject(wrappedValue: MultipeerSession(testData: testData))
        self.fileLogger = FileLogger()
        
        self.normalizedPoints = {
            var points: [CGPoint] = []
            for y in 0..<yPoints {
                for x in 0..<xPoints {
                    points.append(
                        CGPoint(
                            x: xPoints > 1 ? (Double(x) / Double(xPoints - 1) * 0.8 + 0.1) : 0.5,
                            y: yPoints > 1 ? (Double(y) / Double(yPoints - 1) * 0.8 + 0.1) : 0.5
                        )
                    )
                }
            }
            return points
        }()
    }
    
    var body: some View {
        ZStack {
            Image("united kingdom model")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                imageSize = geometry.size
                            }
                    }
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gestureValue in
                            let location = gestureValue.location
                            currentTime = Date().timeIntervalSince(startTime)
                            
                            guard location.x >= 0, location.x <= imageSize.width,
                                  location.y >= 0, location.y <= imageSize.height else { return }
                            self.ipad2D = CGPoint(
                                x: location.x / imageSize.width,
                                y: location.y / imageSize.height
                            )
                        }
                        .simultaneously(
                            with: LongPressGesture(minimumDuration: 0.5)
                                .onEnded { _ in
                                    let logEntry  = "\(currentTime),\(ipad2D.csv),\(testData.csv)"
                                    fileLogger.log(entry: logEntry)
                                    
                                    //print(logEntry)
                                    self.isTouching = true
                                }
                        )
                        .onEnded { _ in
                            self.isTouching = false
                        }
                )
            ForEach(normalizedPoints.indices, id: \.self) { index in
                let point = normalizedPoints[index]
                Circle()
                    .fill(.black)
                    .frame(width: 5, height: 5)
                    .position(
                        x: point.x * imageSize.width,
                        y: point.y * imageSize.height
                    )
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                fileLogger.saveToFile()
            }
        }
        .overlay {
            VStack {
                Spacer()
                HStack {
                    if isTouching {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 50, height: 50)
                    }
                }
            }
        }
    }
}

#Preview {
    MainScreen2(xPoints: 10, yPoints: 10)
}

