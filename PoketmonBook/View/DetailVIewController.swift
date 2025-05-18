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
    
    // MARK: UI
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

    func setPokemonId(_ id: Int) {
        viewModel.poketmonId = id
    }

    private func bind() {
        viewModel.poketmonSubject
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (detail: PoketmonDetail) in
                let koreanName = PoketmonTranslator.getKoreanName(for: detail.name ?? "")
                let typeNames = detail.types.map { $0.type.name ?? "" }
                let translated = typeNames.compactMap { PoketmonTypeName(rawValue: $0)?.displayName }
                self?.nameLabel.text = "No. \(detail.id ?? 0)  \(koreanName)"
                self?.typeLabel.text = "타입: \(translated.joined(separator: " / "))"
                self?.heightLabel.text = "키: \((Double(detail.height ?? 0) / 10)) m"
                self?.weightLabel.text = "몸무게: \((Double(detail.weight ?? 0) / 10)) kg"
                if let id = detail.id,
                   let imageURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png") {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: imageURL),
                           let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self?.imageView.image = image
                            }
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }

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
