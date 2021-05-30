//
//  ViewController.swift
//  LearnRxSwift
//
//  Created by Shotaro Maruyama on 2021/05/11.
//  
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let prices = [100, 250, 560, 980]
        let taxRate = 1.08

        Observable
            // from: 配列をObservableのシーケンスに変換するメソッド。引数の異なるものでjust, ofがある
            .from(prices)
            //map: 各要素に対して処理を行う
            .map({ price in
                Int(Double(price) * taxRate)
            })
            .subscribe({ event in
                print(event)
            })
            .dispose()
    }


}

