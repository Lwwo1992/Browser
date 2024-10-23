//
//  CountdownTimer.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/22.
//

import Foundation

class CountdownTimer: ObservableObject {
    @Published var remainingTime: TimeInterval = 0
    private var timer: Timer?
    private var originalTimeInterval: TimeInterval = 0

    /// 启动倒计时
    func startCountdown() {
        stopTimer() // 如果之前有倒计时，先停止
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateRemainingTime()
        }
    }

    /// 更新倒计时
    private func updateRemainingTime() {
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            stopTimer()
        }
    }

    /// 停止倒计时
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// 重新设置倒计时时间
    func resetCountdown(to timeInterval: TimeInterval) {
        remainingTime = timeInterval
        originalTimeInterval = timeInterval
        startCountdown()
    }
}
