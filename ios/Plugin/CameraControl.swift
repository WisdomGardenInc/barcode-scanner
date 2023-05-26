import AVFoundation
import Foundation

@objc public class CameraControl: NSObject {
  // 缩放因子的最小和最大值
  let minZoomFactor: CGFloat = 1.0
  let maxZoomFactor: CGFloat = 4.0
  let maxZoomVelocity: CGFloat = 3.0

  // 记录当前缩放因子
  private var currentZoomFactor: CGFloat = 1.0

  // 视频捕获设备输入
  private var captureDeviceInput: AVCaptureDeviceInput?

  // 接收视频捕获设备输入
  func setCaptureDeviceInput(_ captureDeviceInput: AVCaptureDeviceInput?) {
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
      currentZoomFactor = 1.0
    } catch {
      print("Failed to set zoom factor")
      return
    }
  }

  // 手动聚焦
  func manualFocus() {
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

  func setCurrentZoomFactor() {
    guard let captureDevice = captureDeviceInput?.device else { return }
    currentZoomFactor = captureDevice.videoZoomFactor
  }

  func zoomCompletion() {
    guard let captureDevice = captureDeviceInput?.device else { return }
    do {
      try captureDevice.lockForConfiguration()
      captureDevice.cancelVideoZoomRamp()
      captureDevice.unlockForConfiguration()
    } catch {
      print("Failed to lock device for zoom configuration: \(error.localizedDescription)")
    }
  }

  // 设置缩放因子
  func setZoomFactor(scale: CGFloat) {
    guard let captureDevice = captureDeviceInput?.device else { return }

    print("scale", scale)
    let factor = currentZoomFactor * scale
    // 计算最大缩放
    let _maxZoomFactor = min(captureDevice.maxAvailableVideoZoomFactor, maxZoomFactor)
    // 计算新的缩放，确保在[minZoomFactor, maxZoomFactor]范围内
    let newZoomFactor = min(max(factor, minZoomFactor), _maxZoomFactor)

    print("newZoomFactor", newZoomFactor)

    guard newZoomFactor != currentZoomFactor else { return }

    // 平滑过渡到新的缩放值
    DispatchQueue.main.async {
      // 设置缩放
      do {
        try captureDevice.lockForConfiguration()
        // withRate:缩放的速率；表示每秒缩放的增量，单位是倍数/秒.
        captureDevice.ramp(toVideoZoomFactor: newZoomFactor, withRate: 3)
        captureDevice.unlockForConfiguration()
        self.currentZoomFactor = newZoomFactor
      } catch {
        print("Failed to set zoom factor")
        return
      }
    }
  }
}
