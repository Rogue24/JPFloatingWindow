//
//  JPFloatingWindowSwitch.swift
//  JPFloatingWindow_Example
//
//  Created by 周健平 on 2023/6/19.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Combine

final class JPFloatingWindowSwitch: ObservableObject {
    static let shared = JPFloatingWindowSwitch()
    @Published var isOn = true
}
