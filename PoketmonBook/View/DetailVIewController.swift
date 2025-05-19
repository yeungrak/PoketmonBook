//
//  DetailVIewController.swift
//  PoketmonBook
//
//  Created by 최영락 on 5/18/25.
//

import UIKit
import SnapKit
import RxSwift

class DetailViewController: UIViewController {
    
    private let viewModel = DetailViewModel()
    private let disposeBag = DisposeBag()
    
    private let nameLabel = UILabel()
    private let typeLabel = UILabel()
    private let heightLabel = UILabel()
    private let weightLabel = UILabel()
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkRed
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
        viewModel.fetchPoketmonDetail()
    }
    //포켓몬의 id 정보를 받아 올 수 있는 함수 detailModel 받아오기 떄문에
    // DetailViewController에서 받아옴.
    func setPoketmonId(_ id: Int) {
        viewModel.poketmonId = id
    }
    //데이터바인딩을 위한 함수
    private func bind() {
        viewModel.poketmonSubject
        //nil이 아닌 값만 방출
            .compactMap { $0 }
        //ui변경은 항상 메인스레드에서 해야함으로 보장해줌
            .observe(on: MainScheduler.instance)
        //구독 시작하고 새로운 데이터가 들어올때마다 처리
            .subscribe(onNext: { [weak self] (detail: PoketmonDetail) in
                //번역용 프로퍼티
                let koreanName = PoketmonTranslator.getKoreanName(for: detail.name ?? "")
                let typeNames = detail.types.map { $0.type.name ?? "" }
                let translated = typeNames.compactMap { PoketmonTypeName(rawValue: $0)?.displayName }
                self?.nameLabel.text = "No. \(detail.id ?? 0)  \(koreanName)"
                self?.typeLabel.text = "타입: \(translated.joined(separator: " / "))"
                self?.heightLabel.text = "키: \((Double(detail.height ?? 0) / 10)) m"
                self?.weightLabel.text = "몸무게: \((Double(detail.weight ?? 0) / 10)) kg"
                //비동기형식의 이미지처리
                //detail api의 id부분을 가져와
                //이미지 UrL생성 백그라운드에서 이미지를 다운하고
                //이미지 다운로드 성공시에 메인스레드 이미지뷰에 세팅함
                if let id = detail.id,
                   let imageURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png") {
                    URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
                        guard let data = data, error == nil,
                              let image = UIImage(data: data) else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                        }
                    }.resume()
                }
            }).disposed(by: disposeBag)
    }
    
    // MARK: - UI
    private func configureUI() {
        view.backgroundColor = .mainRed
        view.addSubview(backgroundView)
        let biglabels = [nameLabel]
        biglabels.forEach {
            $0.textColor = .white
            $0.font = UIFont.systemFont(ofSize: 40, weight: .heavy)
            view.addSubview($0)
        }
        let labels = [typeLabel, heightLabel, weightLabel]
        labels.forEach {
            $0.textColor = .white
            $0.font = .boldSystemFont(ofSize: 20)
            view.addSubview($0)
        }
        
        view.addSubview(imageView)
        
        backgroundView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
            make.height.equalTo(450)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        heightLabel.snp.makeConstraints { make in
            make.top.equalTo(typeLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        weightLabel.snp.makeConstraints { make in
            make.top.equalTo(heightLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
}
