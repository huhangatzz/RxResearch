//
//  InfoCell.swift
//  RxResearch
//  InfoCell 不参与 Rx 请求。纯 UI 渲染对象
//  Created by Kaiser on 2026/8/17.
//

import UIKit
import Kingfisher
import SnapKit
import RswiftResources

class InfoCell: UITableViewCell {
    
    private var _info: Info!
    
    private lazy var picView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .playAndroidTitle
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .gray
        return label
    }()
    
    private lazy var praiseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .gray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        picView.kf.cancelDownloadTask()
        picView.image = nil
        contentLabel.text = nil
        authorLabel.text = nil
        praiseLabel.text = nil
    }
    
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(picView)
        picView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(76)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(10)
        }
        
        contentView.addSubview(praiseLabel)
        praiseLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentLabel)
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        contentView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentLabel)
            make.top.bottom.equalTo(praiseLabel)
        }
    }
}

extension InfoCell {
    
    var info: Info! {
        set {
            _info = newValue
            
            var title = newValue.title
            contentLabel.text = title?.filterHTML()
            authorLabel.text = newValue.author
            
            if let zan = newValue.zan, zan > 0 {
                praiseLabel.text = "赞: \(zan)"
            } else {
                praiseLabel.text = nil
            }
            
            if let imageStr = info.envelopePic,
               let url = URL(string: imageStr) {
                picView.isHidden = false
                picView.kf.setImage(with: url, placeholder: R.image.wan_android_placeholder(), options: [.transition(.fade(0.25)),
                     .scaleFactor(traitCollection.displayScale),
                     .cacheSerializer(FormatIndicatedCacheSerializer.png)])
                
                // 初始约束已经存在，Cell 重用时只更新 offset，避免重复添加约束。
                contentLabel.snp.updateConstraints { make in
                    make.leading.equalToSuperview().offset(76)
                }
            } else {
                picView.kf.cancelDownloadTask()
                picView.image = nil
                picView.isHidden = true
                contentLabel.snp.updateConstraints { make in
                    make.leading.equalToSuperview().offset(16)
                }
            }
        }
        
        get {
            return _info
        }
    }

}
