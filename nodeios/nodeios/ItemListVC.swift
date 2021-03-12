//
//  ItemListVC.swift
//  nodeios
//
//  Created by boreum yoon on 2021/03/11.
//

import UIKit
import Alamofire

class ItemListVC: UITableViewController {
    // 로그인 & 로그아웃을 위한 Barbutton
    var loginBtn:UIBarButtonItem! = nil
    
    // 위의 버튼이 호출할 메소드 (toggle)
    @objc func login(_ sender:UIBarButtonItem){
        if sender.title == "LOGIN" {
            // 로그인 대화상자를 생성해서 출력
            let loginDlg = UIAlertController(title: "Login", message: "아이디와 비밀번호를 입력해주세요", preferredStyle: .alert)
            // 텍스트 필드 추가
            loginDlg.addTextField{(tf) in
                tf.placeholder = "아이디를 입력하세요"}
            loginDlg.addTextField{(tf) in
                tf.placeholder = "비밀번호를 입력하세요"
                tf.isSecureTextEntry = true
            }
            // 버튼 추가
            // 취소 버튼
            loginDlg.addAction(UIAlertAction(title: "취소", style: .cancel))
            // 로그인 버튼
            loginDlg.addAction(UIAlertAction(title: "로그인", style: .default){(_ action) in
                // 버튼을 눌렀을 때 수행할 동작
                // 입력한 내용을 가져옴
                let id = loginDlg.textFields?[0].text
                let pw = loginDlg.textFields?[1].text
                
                // post 방식의 파라미터 생성
                let parameters = ["memberid":id!, "memberpw":pw!]
                
                // 서버에게 전송
                // encoding : post방식일 때는 항상 httpbody
                let request = AF.request("http://localhost/member/login", method: .post, parameters: parameters, encoding:URLEncoding.httpBody, headers: [:])
                
                //응답
                request.responseJSON{ response in
                    // 응답 결과를 json 객체로 생성
                    if let jsonObject = response.value as? [String:Any]{
                        // 로그인 결과 가져오기(필요한 데이터 Parsing)
                        let result = jsonObject["result"] as! Bool
                        // 로그인 성공
                        var msg = ""
                        if(result == true){
                            msg = "로그인 성공"
                            // 회원정보
                            let member = jsonObject["member"] as! [String:Any]
                            // 이 정보를 프로퍼티에 저장
                            // 앱을 다시 실행하면 로그인이 안된 상태로 실행
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            // AppDelegate는 앱 어디서나 접근이 가능 (로그인은 모든 곳에서 접근할 수 있는 AppDelegate에 저장)
                            appDelegate.id = member["memberid"] as? String
                            appDelegate.nickname = member["membernickname"] as? String
                            self.title = appDelegate.nickname
                            sender.title="로그아웃"
                        }
                        // 로그인 실패
                        else {
                            msg = "아이디와 비밀번호를 다시 확인해주세요."
                            
                        }
                        let alert = UIAlertController(title: "로그인 여부", message: msg, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            })
            
            self.present(loginDlg, animated: true)
            
        } else {
            
            // 로그아웃 할 때는 로그인 정보를 삭제
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            // AppDelegate는 앱 어디서나 접근이 가능 (로그인은 모든 곳에서 접근할 수 있는 AppDelegate에 저장)
            appDelegate.id = nil
            appDelegate.nickname = nil
            
            self.title = ""
            
            sender.title = "LOGIN"
        }
        
    }

    // 다운로드 받은 데이터 전체를 저장할 배열
    var itemList = Array<Item>()
    
    // 페이징을 위한 프로퍼티
    var pageno = 1
    var count = 15
    
    // 업데이트를 위한 프로퍼티
    var flag = false
    
    // 검색바 관련 프로퍼티와 메소드
    let searchController = UISearchController(searchResultsController: nil)
    
    // 검색 결과를 저장할 리스트 생성
    var filteredItems = [Item]()
    
    // 검색란이 비어있는지 확인하는 메소드
    // searchbar가 비어있으면 true를 리턴
    func searchBarIsEmpty() -> Bool {
        return
            searchController.searchBar.text?.isEmpty ?? true
    }
    
    // 검색 입력 란에 내용을 입력하면 호출되는 메소드
    // 검색 입력 란의 내용이 itemname에 존재하는 데이터만 filteredItems에 추가
    func filterContentForSearchText(_ searchText:String, scope:String="All") {
        filteredItems = itemList.filter({(item:Item) -> Bool in
            return item.itemname!.lowercased()
                .contains(searchText.lowercased())})
        tableView.reloadData()
    }
    
    // 검색 입력 란의 상태를 리턴하는 메소드
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "아이템 목록"
        
        // 검색 컨트롤러 배치
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "검색어를 입력하세요"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // 네비게이션 바의 왼쪽에 삭제 버튼을 추가
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        // 삽입을 위한 바버튼을 오른쪽에 생성
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addView(_:)))
        
        // self.navigationItem.rightBarButtonItem = addBtn
        // 로그인 버튼 생성
        let loginBtn = UIBarButtonItem(title: "LOGIN", style: .done, target: self, action: #selector(login(_:)))
        
        // 여러 개의 바버튼을 추가
        self.navigationItem.rightBarButtonItems = [loginBtn, addBtn]
    }
    
    //뷰가 화면에 보여질 때 호출되는 메소드
    // 무엇인가를 가지고 있을때 상위 클래스를 한번 호출 한 후 자신의 일을 함
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //AppDelegate 에 대한 포인터를 생성
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //데이터를 가져올 URL
        let listUrl = "http://localhost/item/all"
        let updateUrl = "http://localhost/item/updatedate"
        
        if appDelegate.updatedate == nil{
            // 데이터를 가져올 URL
            let alert = UIAlertController(title: "데이터 목록보기", message: "데이터가 없어서 데이터를 다운로드 합니다.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title:"확인", style: .default){
                (_) -> Void in
              // get 방식으로 데이터 가져와서 출력하기
                let request = AF.request(listUrl, method:.get, encoding:JSONEncoding.default, headers: [:])
                request.responseJSON{
                    response in
                    // 가져온 데이터는 response.value
                    // 전체를 Dictionary로 변환
                    if let jsonObject = response.value as? [String:Any]{
                        // list 키의 데이터를 배열로 변환
                        let list = jsonObject["list"] as! NSArray
                        // 리스트 순회
                        for index in 0...(list.count - 1){
                            // 하나의 데이터 가져오기
                            let itemDict = list[index] as! NSDictionary
                            
                            // Item 객체를 생성
                            var item = Item();
                            item.itemid = ((itemDict["itemid"] as! NSNumber).intValue)
                            item.itemname = itemDict["itemname"] as? String
                            item.price = ((itemDict["price"] as! NSNumber).intValue)
                            item.description = itemDict["description"] as? String
                            item.pictureurl = itemDict["pictureurl"] as? String
                            item.updatedate = itemDict["updatedate"] as? String
                            
                            // 이미지 가져오기
                            let imageurl = URL(string:"http://localhost/img/\(item.pictureurl!)")
                            let imageData = try!Data(contentsOf: imageurl!)
                            item.image = UIImage(data: imageData)
                            self.itemList.append(item)
                            
                        }
                        NSLog("데이터 저장 성공")
                    }
                    // 테이블 뷰 다시 출력
                    self.tableView.reloadData()
                    // 현재 가져온 데이터가 언제 데이터인지 기록해야함
                    // update 한 시간을 받아오기 위한 요청을 생성
                    let updaterequest = AF.request(updateUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
                    updaterequest.responseJSON{
                        response in
                        if let jsonObject = response.value as? [String:Any]{
                            let result = jsonObject["result"] as? String
                            appDelegate.updatedate = result
                        }
                    }
                }
            })
            
            //대화상자 출력
            self.present(alert, animated: true)
        }
        //업데이트 한 시간이 존재하는 경우
        else{
            // JSON을 다운로드 받았을 때의 내용
            let updaterequest = AF.request(updateUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
            updaterequest.responseJSON{
                response in
                if let jsonObject = response.value as? [String:Any]{
                    let result = jsonObject["result"] as? String
                    // 내가 가지고 있는 업데이트 시간과 서버의 업데이트 시간이 같은 경우
                    // 현재 데이터만 다시 출력
                    if appDelegate.updatedate == result{
                        let alert = UIAlertController(title: "데이터 가져오기", message: "서버의 데이터와 동일하여 다운로드 하지 않습니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(alert, animated: true)
                        self.tableView.reloadData()
                    }
                    // 다르면 서버의 데이터를 다시 읽어서 출력
                    else{
                        // 데이터 가져와서 출력하기
                        let alert = UIAlertController(title: "데이터 목록보기", message: "서버의 데이터를 가져와 업데이트합니다.", preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title:"확인", style: .default){
                            (_) -> Void in
                            // get 방식으로 데이터 가져오기
                            let request = AF.request(listUrl, method:.get, encoding:JSONEncoding.default, headers: [:])
                            request.responseJSON{
                                response in
                                // 가져온 데이터는 response.value
                                // 전체를 Dictionary로 변환
                                if let jsonObject = response.value as? [String:Any]{
                                    // list 키의 데이터를 배열로 변환
                                    let list = jsonObject["list"] as! NSArray
                                    // 기존 데이터를 삭제
                                    self.itemList.removeAll()
                                    // 리스트 순회
                                    for index in 0...(list.count - 1){
                                        // 하나의 데이터 가져오기
                                        let itemDict = list[index] as! NSDictionary
                                        
                                        // Item 객체를 생성
                                        var item = Item();
                                        item.itemid = ((itemDict["itemid"] as! NSNumber).intValue)
                                        item.itemname = itemDict["itemname"] as? String
                                        item.price = ((itemDict["price"] as! NSNumber).intValue)
                                        item.description = itemDict["description"] as? String
                                        item.pictureurl = itemDict["pictureurl"] as? String
                                        item.updatedate = itemDict["updatedate"] as? String
                                        
                                        // 이미지 가져오기
                                        let imageurl = URL(string:"http://localhost/img/\(item.pictureurl!)")
                                        let imageData = try!Data(contentsOf: imageurl!)
                                        item.image = UIImage(data: imageData)
                                        self.itemList.append(item)
                                        
                                    }
                                    NSLog("데이터 저장 성공")
                                }
                                // 테이블 뷰 다시 출력
                                self.tableView.reloadData()
                                
                                // 현재 가져온 데이터가 언제 데이터인지 기록 해야 함
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
                        })
                        
                        //대화상자 출력
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    // 네비게이션 바의 오른쪽 버튼을(add) 누르면 호출될 메소드
    @objc func addView(_ sender:UIBarButtonItem) {
        // ItemListVC를 화면에 출력
        let itemInsertVC = self.storyboard?.instantiateViewController(identifier: "ItemInsertVC") as! ItemInsertVC
        self.navigationController?.pushViewController(itemInsertVC, animated: true)
    }

 
    // 테이블 뷰 관련 메소드
    // 섹션의 개수를 설정하는 메소드 - 선택
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // 섹션 별 행의 개수를 설정하는 메소드 - 필수
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 페이지 단위로 개수를 수정
        // 검색바에 무엇인가를 입력했다면
        if isFiltering() {
            // 검색된 내용을 출력
            return filteredItems.count
        }
        // 검색바가 비활성화 되어있으면 전체를 출력
        if pageno * count >= itemList.count {
            return itemList.count
        } else {
            return pageno * count
        }
    }

    // 셀의 모양을 설정하는 메소드 - 필수
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if(cell == nil){
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        // 하나의 데이터 가져오기
        var item : Item!
        // 검색 란을 사용 중이면 filteredItems 에서 가져오고 그렇지 않으면 itemList에서 가져옴
        if isFiltering() {
            item = filteredItems[indexPath.row]
        } else {
            item = itemList[indexPath.row]
        }
   
        // 데이터를 출력
        cell!.textLabel!.text = item.itemname
        cell!.detailTextLabel!.text = item.description
        cell!.imageView!.image = item.image

        return cell!
    }
    // 셀을 선택했을 때 호출되는 메소드
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 하위 뷰 컨트롤러를 생성
        let itemDetailVC = self.storyboard?.instantiateViewController(identifier: "ItemDetailVC") as! ItemDetailVC
        // 데이터 넘겨주기
        if isFiltering(){
            itemDetailVC.item = filteredItems[indexPath.row]
        } else {
            itemDetailVC.item = itemList[indexPath.row]
        }
        
        // 하위 뷰 컨트롤러 푸시
        self.navigationController?.pushViewController(itemDetailVC, animated: true)
    }

    // 셀이 보여질 때 호출되는 메소드
    // 마지막 셀이 보여질 때 업데이트를 수행
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(flag == false && indexPath.row == self.pageno * count - 1) {
            flag = true
        } else if(flag == true && indexPath.row == self.pageno * count - 1) {
            pageno = pageno + 1
            tableView.reloadData()
        }
    }
    // edit 버튼을 눌렀을 때 수행할 동작을 설정하는 메소드 (editingStyleForRowAt)
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // 삭제 동작을 수행하겠다고 설정
        return.delete
    }
    
    // edit를 눌러서 나오는 아이콘을 누르고 동작을 수행하면 호출되는 메소드 (commit editingStyle)
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 삭제할 데이터를 찾아오기
        let itemid = itemList[indexPath.row].itemid
        // 로컬에서 삭제
        itemList.remove(at: indexPath.row)
        // 삭제되는 애니메이션 출력 - error?
        // tableView.deleteRows(at: [indexPath], with: .fade)
        
        self.tableView.reloadData()
        
        // 서버에게 삭제요청 보내기
        // title이 없는 POST로 보냄
        
        // post 방식의 파라미터 생성
        let parameters = ["itemid":"\(itemid!)"]
        
        let request = AF.request("http://localhost/item/delete", method:.post, parameters: parameters, encoding: URLEncoding.httpBody, headers: [:])
        
        // 서버의 응답 처리
        request.responseJSON{
            response in
            
            if let jsonObject = response.value as? [String:Any]{
                // 결과 찾아오기
                let result = jsonObject["result"] as! Bool
                // 출력할 메시지 저장할 변수
                var msg : String = ""
                if result == true {
                    msg = "삭제 성공"
                } else {
                    msg = "삭제 실패"
                }
                
                let alert = UIAlertController(title: "데이터 삭제", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}

// extension 생성 할 때는 클래스 밖으로 나감
extension ItemListVC : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
