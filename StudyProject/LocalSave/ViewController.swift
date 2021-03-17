//
//  ViewController.swift
//  LocalSave
//
//  Created by boreum yoon on 2021/03/17.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblAppDelegate: UILabel!
    @IBOutlet weak var lblUserDefaults: UILabel!

    @IBOutlet weak var tfFileData: UITextField!

    @IBAction func saveFile(_ sender: Any) {
        
        //도큐먼트 디렉토리 경로를 생성
                let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let docDir = dirPaths[0]
                
                //파일 경로 생성
                let dataFile = docDir + "/datafile.dat"
                
                //입력받은 데이터를 가져오기
                let str = tfFileData.text
                let dataBuffer = str!.data(using: String.Encoding.utf8)
                
                //파일 기록
                FileManager.default.createFile(atPath: dataFile, contents: dataBuffer, attributes: nil)
                
                tfFileData.text = "기록 성공"
            }
            @IBAction func readFile(_ sender: Any) {
                //도큐먼트 디렉토리 경로를 생성
                let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let docDir = dirPaths[0]
                
                //파일 경로 생성
                let dataFile = docDir + "/datafile.dat"
                
                //파일의 존재 여부를 확인
                if FileManager.default.fileExists(atPath: dataFile) == false{
                    tfFileData.text = "파일이 존재하지 않습니다."
                }else{
                    //파일의 내용 읽어오기
                    let dataBuffer = FileManager.default.contents(atPath: dataFile)
                    //파일에서 읽은 데이터는 NSData(바이트 배열) 타입입니다.
                    //이 데이터를 문자열로 변경할 때는 NSString을 거쳐서 변경
                    //encoding을 설정할 때 Objective-C에서는
                    //나열형 상수를 정수로 간주해서 설정했기 때문에
                    //Swift 에서는 나열형 상수를 직접 대입을 하지 못하고
                    //정수로 변환한 rawValue를 대입합니다.
                    let contents = NSString(data: dataBuffer!, encoding: String.Encoding.utf8.rawValue)
                    tfFileData.text = contents! as String
                }
            }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // AppDelegate 에 대한 참조 만들기
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        lblAppDelegate.text = appDelegate?.shareData
        
        // 값을 변경하면 앱이 실행 중인 동안은 적용이 되지만 앱이 종료되면 다시 초기값으로 설정
        appDelegate?.shareData = "2021-03-16"
        
        lblAppDelegate.text = appDelegate?.shareData
        
        // 환경 설정에 대한 참조 만들기
        let userDefaults = UserDefaults.standard
        //환경 설정에 data라는 키에 저장된 데이터를 가져와서 출력
        if userDefaults.string(forKey: "data") == nil{
            lblUserDefaults.text = "데이터 없음"
        }else{
            lblUserDefaults.text = userDefaults.string(forKey: "data")
        }
        // 환경 설정에 저장
        // 한 번 저장하면 삭제할 때 까지 지워지지 않음
        userDefaults.set("공유 데이터", forKey: "data")

        
    }

}

