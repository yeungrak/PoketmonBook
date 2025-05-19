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
        viewModel.loadMorePoketmons()
    }
    //데이터 바인딩
    private func bind() {
        viewModel.poketmonList
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] list in
                self?.poketmonList = list
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    //MARK: -UI
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
    
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            //정사각형 모양의 Item 사이즈
            //가로와 세로의 높이는 전체너비의 1/3 즉, 한 줄에 3개의 셀 표현
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .fractionalWidth(1.0 / 3.0)
        )
        // 셀 내부 여백 설정
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
        // 한 줄은 화면 전체 너비
        // 그룹의 높이도 셀 하나와 동일
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0 / 3.0)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            //그룹에 Item을 3개씩 넣어 배치함.
            subitems: Array(repeating: item, count: 3)
        )
        
        //그룹을 담는 섹션 설정
        let section = NSCollectionLayoutSection(group: group)
        //그룹간 여백
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
    //셀을 클릭했을때 나타나는 이벤트 설정 함수
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //사용자가 선택한 셀의 포켓몬 데이터를 PoketmonList에서 가져온다.
        let selected = poketmonList[indexPath.item]
        /// urlString은 사용자가 선택한 셀의 url을 저장
        ///  idString은 urlString을 split을 이용해 /를 기준으로 구분하여 마지막 글자를 저장함
        ///  id는 마지막 글자를 Int로 바꿔 저정함
        if let urlString = selected.url,
           let idString = urlString.split(separator: "/").last,
           let id = Int(idString) {
            //detailVC에 id를 전달해주고 내비게이션을 활용해 detailVC화면을 Push함.
            let detailVC = DetailViewController()
            detailVC.setPoketmonId(id) // ID 전달
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    //아래로 스크롤하면 호출되는 함수
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 현재 스크롤 위치
        let offsetY = scrollView.contentOffset.y
        // 전체 콘텐츠 높이
        let contentHeight = scrollView.contentSize.height
        // 현재 화면 높이
        let frameHeight = scrollView.frame.size.height
        //현재 스크롤 위치가 거의 맨 아래에서 위로 100만큼 도달하면 추가 데이터를 로드함.
        if offsetY > contentHeight - frameHeight - 100 {
            viewModel.loadMorePoketmons()
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


