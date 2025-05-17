import UIKit
import RxSwift

class InfoViewController: UIViewController {
    // MARK: - Typealiases
    
    typealias Images = InfoModels.Images
    typealias NavigationType = MainModels.NavigationType
    
    typealias Colors = GlobalConstants.Colors
    typealias Constants = GlobalConstants.Constants
    typealias Fonts = GlobalConstants.Fonts
    
    // MARK: - Properties
    
    private let closeButton: UIButton = {
       let button = UIButton(type: .system)
        button.setBackgroundImage(Images.closeImage, for: .normal)
        button.tintColor = Colors.blueColor
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.primaryFont
        label.textColor = Colors.blackColor
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.secondaryFont
        label.textColor = Colors.greyColor
        return label
    }()
    
    private let disposeBag = DisposeBag()
}

extension InfoViewController {
    // MARK: - Methods
    
    func initData(navigation: NavigationDataResponse) {
        switch NavigationType(rawValue: navigation.navigation) {
        case .push:
            configurePushUI(navigation: navigation)
        case .modal:
            configureModalUI(navigation: navigation)
        case .fullScreen:
            configureFullUI(navigation: navigation)
        }
    }
}

private extension InfoViewController {
    // MARK: - Private Methods
    
    private func configurePushUI(navigation: NavigationDataResponse) {
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Colors.beigeColor
        title = navigation.title
        
        subtitleLabel.text = navigation.subtitle
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func configureModalUI(navigation: NavigationDataResponse) {
        view.backgroundColor = Colors.beigeColor

        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Constants.horizontalSpacing)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.verticalSpacing * 2)
            make.width.height.equalTo(InfoModels.Constants.closeButtonSize)
        }
        closeButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        let containerView = UIView()
        containerView.backgroundColor = .clear
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.centerY.left.right.equalToSuperview()
        }
        
        let imageView = UIImageView(image: UIImage(systemName: navigation.titleSymbol ?? .empty))
        imageView.tintColor = Colors.blueColor
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.width.height.equalTo(InfoModels.Constants.imageSize)
        }
        
        titleLabel.text = navigation.title
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(Constants.verticalSpacing)
        }
    }
    
    private func configureFullUI(navigation: NavigationDataResponse) {
        view.backgroundColor = Colors.beigeColor

        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Constants.horizontalSpacing)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.verticalSpacing * 2)
            make.width.height.equalTo(InfoModels.Constants.closeButtonSize)
        }
        closeButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        let containerView = UIView()
        containerView.backgroundColor = .clear
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.centerY.left.right.equalToSuperview()
        }
        
        titleLabel.text = navigation.title
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
        }
        
        subtitleLabel.text = navigation.subtitle
        containerView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.verticalSpacing)
            make.bottom.centerX.equalToSuperview()
        }
    }
}
