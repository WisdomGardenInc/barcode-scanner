import Foundation
import AVFoundation


@objc public class CameraControl:NSObject {
    // 缩放因子的最小和最大值
    let minZoomFactor: CGFloat = 1.0
    let maxZoomFactor: CGFloat = 10.0
    let maxZoomVelocity: CGFloat = 3.0
    
    private var shouldContinueRamping = false
    // 记录当前缩放因子
    private var currentZoomFactor: CGFloat = 1.0
    
    // 视频捕获设备输入
    private var captureDeviceInput: AVCaptureDeviceInput?
    
    // 接收视频捕获设备输入
    func setCaptureDeviceInput(_ captureDeviceInput: AVCaptureDeviceInput?){
        self.captureDeviceInput = captureDeviceInput
    }
    
    
    // 重置缩放
    func resetZoomFactor() {
        guard let captureDevice = captureDeviceInput?.device else { return }
        
        
        // 设置缩放
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = 1.0
            captureDevice.unlockForConfiguration()
            currentZoomFactor = 1.0;
        } catch {
            print("Failed to set zoom factor")
            return
        }
    }
    
    // 手动聚焦
    func manualFocus(){
        guard let captureDevice = self.captureDeviceInput?.device else {
            return
        }
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.autoFocusRangeRestriction = .near
            captureDevice.unlockForConfiguration()
        } catch {
            print("Could not lock device for configuration: \(error)")
        }
    }
    
    
    // 在滚动手势结束后停止缩放动画
    func stopRamping() {
        shouldContinueRamping = false
    }
    
    
    // 设置缩放因子
    func setZoomFactor(scale: CGFloat, velocity: CGFloat) {
        guard let captureDevice = captureDeviceInput?.device else { return }
        
        let factor = currentZoomFactor * scale;
        // 计算新的缩放，确保在[minZoomFactor, maxZoomFactor]范围内
        let newZoomFactor = min(max(factor, minZoomFactor), maxZoomFactor)
        guard newZoomFactor != currentZoomFactor else { return }
            
        // 设置缩放
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = newZoomFactor
            captureDevice.unlockForConfiguration()
            // Set new zoom facto
            currentZoomFactor = newZoomFactor
        } catch {
            print("Failed to set zoom factor")
            return
        }
    }
}
