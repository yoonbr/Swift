//
//  WineListVC.swift
//  winenote
//
//  Created by boreum yoon on 2021/03/16.
//

import UIKit
import Alamofire


class WineListVC: UITableViewController {
    
    // 다운 받은 데이터를 저장할 프로퍼티 생성 - Array
    var wineList = Array<Wine>()
    
    //뷰가 화면에 보여질 때 호출되는 메소드
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            //AppDelegate 에 대한 포인터를 생성
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            //데이터를 가져올 URL
             let listUrl = "http://192.168.0.8/wine/all"
             let updateUrl = "http://192.168.0.8/item/updatedate"
            
//             let listUrl = "http://172.20.10.3/wine/all"
//             let updateUrl = "http://192.168.219.119/wine/updatedate"
            
            if appDelegate.updatedate == nil{
                //get 방식으로 데이터 가져오기
                let request = AF.request(listUrl, method:.get, encoding:JSONEncoding.default, headers: [:])
                request.responseJSON{
                    response in
                    //가져온 데이터는 response.value
                    //전체를 디셔너리로 변환
                    if let jsonObject = response.value as? [String:Any]{
                        //list 키의 데이터를 배열로 변환
                        let list = jsonObject["list"] as! NSArray
                        //리스트 순회
                        for index in 0...(list.count - 1){
                            //하나의 데이터 가져오기
                            let wineDict = list[index] as! NSDictionary
                            
                            //wine 객체를 생성
                            var wine = Wine();
                            wine.winenum = ((wineDict["winenum"] as! NSNumber).intValue)
                            wine.winename = wineDict["winename"] as? String
                            wine.varieties = wineDict["varieties"] as? String
                            wine.country = wineDict["country"] as? String
                            wine.category = wineDict["category"] as? String
                            wine.wineimg = wineDict["wineimg"] as? String
                            wine.updatedate = wineDict["updatedate"] as? String
                            
                            //이미지 가져오기
                            let imageurl = URL(string:"http://172.30.1.27/img/\(wine.wineimg!)")
                            let imageData = try!Data(contentsOf: imageurl!)
                            wine.image = UIImage(data: imageData)
                            self.wineList.append(wine)
                            
                        }
                        NSLog("데이터 저장 성공")
                    }
                    //테이블 뷰 다시 출력
                    self.tableView.reloadData()
                    //현재 가져온 데이터가 언제 데이터인지
                    //기록을 해야 합니다.
                    
                    //update 한 시간을 받아오기 위한 요청을 생성
                    let updaterequest = AF.request(updateUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
                    updaterequest.responseJSON{
                        response in
                        if let jsonObject = response.value as? [String:Any]{
                            let result = jsonObject["result"] as? String
                            appDelegate.updatedate = result
                }
            }
        }
//            //대화상자 출력
//            self.present(alert, animated: true)
    }
        //업데이트 한 시간이 존재하는 경우
        else{
            let updaterequest = AF.request(updateUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
            updaterequest.responseJSON{
                response in
                if let jsonObject = response.value as? [String:Any]{
                    let result = jsonObject["result"] as? String
                    //내가 가지고 있는 업데이트 시간과
                    //서버의 업데이트 시간이 같은 경우
                    //현재 데이터만 다시 출력
                    if appDelegate.updatedate == result{
//                        let alert = UIAlertController(title: "데이터 가져오기", message: "서버의 데이터와 가지고 있는 데이터가 같아서 다운로드 하지 않습니다.", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "확인", style: .default))
//                        self.present(alert, animated: true)
                        self.tableView.reloadData()
                    }
                    //서버의 데이터를 다시 읽어서 출력
                    else{
                        //데이터 가져와서 출력하기
//                        let alert = UIAlertController(title: "데이터 목록보기", message: "데이터가 변경되서 데이터를 다운로드 합니다.", preferredStyle: .alert)
//
//                        alert.addAction(UIAlertAction(title:"확인", style: .default){
//                            (_) -> Void in
                            //get 방식으로 데이터 가져오기
                            let request = AF.request(listUrl, method:.get, encoding:JSONEncoding.default, headers: [:])
                            request.responseJSON{
                                response in
                                //가져온 데이터는 response.value
                                //전체를 디셔너리로 변환
                                if let jsonObject = response.value as? [String:Any]{
                                    //list 키의 데이터를 배열로 변환
                                    let list = jsonObject["list"] as! NSArray
                                    //기존 데이터를 삭제
                                    self.wineList.removeAll()
                                    //리스트 순회
                                    for index in 0...(list.count - 1){
                                        //하나의 데이터 가져오기
                                        let wineDict = list[index] as! NSDictionary
                                        
                                        //wine 객체를 생성
                                        var wine = Wine();
                                        wine.winenum = ((wineDict["winenum"] as! NSNumber).intValue)
                                        wine.winename = wineDict["winename"] as? String
                                        wine.varieties = wineDict["varieties"] as? String
                                        wine.country = wineDict["country"] as? String
                                        wine.category = wineDict["category"] as? String
                                        wine.wineimg = wineDict["wineimg"] as? String
                                        wine.updatedate = wineDict["updatedate"] as? String
                                        
                                        //이미지 가져오기
                                        let imageurl = URL(string:"http://http://172.30.1.27/img/\(wine.wineimg!)")
                                        let imageData = try!Data(contentsOf: imageurl!)
                                        wine.image = UIImage(data: imageData)
                                        self.wineList.append(wine)
                                        
                                    }
                                    NSLog("데이터 저장 성공")
                                }
                                //테이블 뷰 다시 출력
                                self.tableView.reloadData()
                                //현재 가져온 데이터가 언제 데이터인지
                                //기록을 해야 합니다.
                                
                                //update 한 시간을 받아오기 위한 요청을 생성
                                let updaterequest = AF.request(updateUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
                                updaterequest.responseJSON{
                                    response in
                                    if let jsonObject = response.value as? [String:Any]{
                                        let result = jsonObject["result"] as? String
                                        appDelegate.updatedate = result
                                    }
                                }
                            }
                        // })
                        
                        //대화상자 출력
                        // self.present(alert, animated: true)
                    }
                }
            }
        }
    }
                
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "와인리스트"
        
        
    }

    // MARK: - Table view data source

    // 테이블 뷰 관련 메소드

        // 섹션의 개수를 설정하는 메소드 - 선택
        override func numberOfSections(in tableView: UITableView) -> Int {
            
            return 1
        }
        
        // 섹션 별 행의 개수를 설정하는 메소드 - 필수
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            return wineList.count
        }
    
        // cell의 높이(100)를 설정하는 메소드
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }

        // 셀의 모양을 설정하는 메소드 - 필수
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cellIdentifier = "Cell"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            if(cell == nil){
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
            }
            
            // 하나의 데이터 가져오기
            let wine = wineList[indexPath.row]
            
            // 데이터를 출력
            cell!.textLabel!.text = wine.winename
            cell!.detailTextLabel!.text = wine.varieties
            cell!.imageView!.image = wine.image
            
            return cell!
        }

}