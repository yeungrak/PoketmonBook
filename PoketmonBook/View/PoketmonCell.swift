//
//  PoketmonCell.swift
//  PoketmonBook
//
//  Created by 최영락 on 5/18/25.
//

import UIKit

class PoketmonCell: UICollectionViewCell {
    //Identifier
    static let id = "PoketmonCell"
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .cellBackground
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        //전체 셀 영역에 이미지가 차게함
        imageView.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        imageView.image = nil
    }
    //킹피셔로 교체가능
    func configure(with url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }
}
