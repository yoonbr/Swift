//
//  ViewController.swift
//  TouchEventHandling
//
//  Created by boreum yoon on 2021/02/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 이미지 고정 해제 (1)
        // 스토리보드 - 이미지 선택 - UserInteructionEnabled 체크박스 선택 (2)
        // imgView.isUserInteractionEnabled = true
        
        // UIDevice.orientationDidChangeNotification이 발생하면 didRotate를 호출하도록 설정 
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main,
            using: didRotate)
            }
    
    // 기기의 방향이 변경되면 호출될 메소드
    // Notification 처리 메소드
    var didRotate:(Notification) -> Void = {notification in
        switch UIDevice.current.orientation{
        case .landscapeLeft, .landscapeRight:NSLog("가로 방향")
        case .portrait, .portraitUpsideDown:NSLog("세로 방향")
        default:NSLog("알 수 없는 방향")
        }
    }
    // 터치 관련 메소드
    // 터치가 시작되었을 때 호출되는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 터치 1개 가져오기
        let touch = touches.first
        // 두드린 횟수 가져오기
        // 옵셔널 없애고 싶으면 ? 대신 !
        let tapCount = touch!.tapCount
        
        label1.text = "Touch Start"
        label2.text = "\(tapCount)번"
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        label1.text = "Touch Moved to Img"
        
        // 터치가 이미지 뷰에서 발생하면 이미지뷰의 위치를
        // 터치가 발생한 지점으로 이동
        // 터치 1개를 가져오기
        let touch = touches.first
        
        if touch?.view == imgView {
            imgView.center = touch!.location(in: self.view)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        label1.text = "Touch finish"
    }
}

