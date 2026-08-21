//
//  MyView.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/21.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture
import NSObject_Rx
import SnapKit
import RswiftResources

class MyView: UIView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: R.image.user())
        imageView.layer.cornerRadius = 33
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.systemGray.cgColor
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .playAndroidTitle
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private var _myCoin: CoinRank?
    
    var myCoin: CoinRank? {
        set {
            _myCoin = newValue
            
            if let text = newValue?.myInfo {
                imageView.image = R.image.android()
                infoLabel.text = text
            } else {
                imageView.image = R.image.user()
                infoLabel.text = "排名: -- 等级: -- 积分: --"
            }
        }
        
        get {
            return _myCoin
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(snp.centerY)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(66)
        }
        imageView.rx.tapGesture()
            .subscribe(onNext: ({ [weak self] _ in
                self?.bubbleEvent(InnerViewEvent.custom(["name": "season"]))
            }))
            .disposed(by: rx.disposeBag)
        
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(snp.centerY).offset(16)
            make.centerX.equalToSuperview()
        }
    }
}

extension Reactive where Base: MyView {
    var myInfo: Binder<CoinRank?> {
        return Binder(base) {myView, model in
            myView.myCoin = model
        }
    }
}
