//
//  MainViewController.swift
//  PoketmonBook
//
//  Created by 최영락 on 5/18/25.
//

import UIKit
import SnapKit
import RxSwift

class MainViewController: UIViewController {
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    private var poketmonList = [PoketmonListResult]()
    
    private let ballImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "pokemonBall")
        image.contentMode = .scaleAspectFill
        return image
    }()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(PoketmonCell.self, forCellWithReuseIdentifier: PoketmonCell.id)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .darkRed
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUi()
        bind()
        viewModel.fetchPokemonList(limit: 20, offset: 0)
    }
    
    //MARK: UI
    private func configureUi() {
        view.backgroundColor = .mainRed
        view.addSubview(ballImage)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(ballImage.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        ballImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
    }
    private func bind() {
        viewModel.poketmonSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] list in
                self?.poketmonList = list
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .fractionalWidth(1.0 / 3.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0 / 3.0)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: Array(repeating: item, count: 3)
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 2, leading: 4, bottom: 2, trailing: 4)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
extension UIColor {
    static let mainRed = UIColor(red: 190/255, green: 30/255, blue: 40/255, alpha: 1.0)
    static let darkRed = UIColor(red: 120/255, green: 30/255, blue: 30/255, alpha: 1.0)
    static let cellBackground = UIColor(red: 245/255, green: 245/255, blue: 235/255, alpha: 1.0)
}

// MARK: UICollcetionView Data Source

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selected = poketmonList[indexPath.item]

            // url에서 포켓몬 id 추출
            if let urlString = selected.url,
               let idString = urlString.split(separator: "/").last,
               let id = Int(idString) {
                
                let detailVC = DetailViewController()
                detailVC.setPokemonId(id) // ID 전달
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
}
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return poketmonList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PoketmonCell.id, for: indexPath) as? PoketmonCell else {
            return UICollectionViewCell()
        }
        
        let result = poketmonList[indexPath.item]
        if let url = result.imageURL {
            cell.configure(with: url)
        }
        return cell
    }


}


