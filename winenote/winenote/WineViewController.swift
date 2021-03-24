//
//  WineViewController.swift
//  winenote
//
//  Created by boreum yoon on 2021/03/16.
//

import UIKit
import Alamofire

class WineViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
//    var wine : Wine!
//    var images : [String] = []
    
    // 다운로드 받은 데이터를 저장할 프로퍼티 - wineListCV
    var wineListCV = Array<Wine>()
    
    // 뷰가 화면에 보여질 때 호출되는 메소드
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // AppDelegate에 대한 포인터 생성
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // 데이터를 가져올 URL
        let listUrl = "http://192.168.0.8/wine/all"
        let updateUrl = "http://192.168.0.8/item/updatedate"
        
        if appDelegate.updatedate == nil {
            // get 방식으로 데이터 가져오기
            let request = AF.request(listUrl, method: .get,
                                     encoding: JSONEncoding.default, headers: [:])
            request.responseJSON{
                response in
                // 가져온 데이터는 response.value
                // 전체를 디셔너리로 변환
                if let jsonObject = response.value as? [String:Any] {
                    // list의 키의 데이터를 배열로 변환
                    let list = jsonObject["list"] as! NSArray
                    // 리스트 순회
                    for index in 0...(list.count - 1) {
                        // 하나의 데이터 가져오기
                        let wineDict = list[index] as! NSDictionary
                        
                        // wine 객체를 생성
                        var wine = Wine();
                        wine.winenum = ((wineDict["winenum"] as! NSNumber).intValue)
                        wine.winename = wineDict["winename"] as? String
                        wine.wineimg = wineDict["wineimg"] as? String
                        wine.updatedate = wineDict["updatedate"] as? String
                        
                        // 이미지 가져오기
                        let imageurl = URL(string: "http://192.168.0.8/img/\(wine.wineimg!)")
                        let imageData = try!Data(contentsOf: imageurl!)
                        wine.image = UIImage(data: imageData)
                        self.wineListCV.append(wine)
                    }
                    NSLog("Data Save")
                }
            }
            
            // 컬렉션 뷰 다시 출력
            self.collectionView.reloadData()
            // 현재 가져온 데이터가 언제 데이터인지 기록
            
            // update 시간 받아오는 요청
            let upadaterequest = AF.request(updateUrl, method: .get,
                                            encoding: JSONEncoding.default,
                                            headers: [:])
            upadaterequest.responseJSON{
                response in
                if let jsonObject = response.value as? [String:Any] {
                    let result = jsonObject["result"] as? String
                    appDelegate.updatedate = result
                }
            }
        }
        // 업데이트 시간이 존재하는 경우
        else {
            let updaterequest = AF.request(updateUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
            updaterequest.responseJSON{
                response in
                if let jsonObject = response.value as? [String:Any] {
                    let result = jsonObject["result"] as? String
                    // 내 업데이트 시간과 서버의 업데이트 시간이 같은 경우 현재 데이터만 다시 출력
                    if appDelegate.updatedate == result {
                        self.collectionView.reloadData()
                    }
                    // 아닐 경우 서버의 데이터를 읽어서 출력
                    else {
                        // 데이터 가져와서 출력 - get방식
                        let request = AF.request(listUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
                        request.responseJSON{
                            response in
                            // 가져온 데이터는 response.value, 전체를 디셔너리로 변환
                            if let jsonObject = response.value as? [String:Any]{
                                // list의 키의 데이터를 배열로 변환
                                let list = jsonObject["list"] as! NSArray
                                // 기존 데이터를 삭제
                                self.wineListCV.removeAll()
                                // 리스트 순회
                                for index in 0...(list.count - 1) {
                                    // 하나의 데이터 가져오기
                                    let wineDict = list[index] as! NSDictionary
                                    
                                    // wine 객체를 생성
                                    var wine = Wine()
                                    wine.winenum = ((wineDict["winenum"] as! NSNumber).intValue)
                                    wine.winename = wineDict["winename"] as? String
                                    wine.wineimg = wineDict["wineimg"] as? String
                                    wine.updatedate = wineDict["updatedate"] as? String
                                
                                    // 이미지 가져오기
                                    let imageurl = URL(string: "http://192.168.0.8/img/\(wine.wineimg!)")
                                    let imageData = try!Data(contentsOf: imageurl!)
                                    wine.image = UIImage(data: imageData)
                                    self.wineListCV.append(wine)
                                
                                }
                                
                                NSLog("Success save data")
                            }
                            
                            // 컬렉션 뷰 다시 출력
                            self.collectionView.reloadData()
                            
                            // update 한 시간을 받아오기 위한 요청을 생성
                            let updaterequest = AF.request(updateUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
                            updaterequest.responseJSON{
                                response in
                                if let jsonObject = response.value as? [String:Any] {
                                    let result = jsonObject["result"] as?
                                    String
                                    appDelegate.updatedate = result
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.title = "logo"
        
        // collectionview에 delegate, datasource 설정
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
        
        
        // 배열 초기화
//        for i in 1...6{
//            let imageName = String(format: "wine%02i.png", i)
//            images.append(imageName)
//        }
         
    }


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //셀의 개수를 설정하는 메소드
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    //셀의 모양을 설정하는 메소드
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WineCVC", for: indexPath) as! WineCVC
        
        // 데이터 출력
        return cell
    }
}

    /*
    //셀의 크기를 설정하는 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //가로로 3개 배치
        let collectionViewCellWidth =
            collectionView.frame.width / 3 - 1
        
        //가로와 세로 크기 설정
        return CGSize(width: collectionViewCellWidth, height: collectionViewCellWidth)
    }
    
    //상하좌우 여백을 설정하는 메소드 - Margin
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    //패딩
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //셀을 선택했을 때 호출되는 메소드
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.cyan.cgColor
        cell?.layer.borderWidth = 3.0
    }
 */


