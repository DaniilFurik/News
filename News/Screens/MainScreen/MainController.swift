import SnapKit
import RxSwift
import UIKit

class MainController: UIViewController {
    
    // MARK: - Typealiases
    
    typealias Constants = GlobalConstants.Constants
    typealias Fonts = GlobalConstants.Fonts
    typealias Colors = GlobalConstants.Colors

    typealias Texts = MainModels.Texts
    typealias Images = MainModels.Images
    typealias NavigationType = MainModels.NavigationType
    
    // MARK: - Properties
    
    private let segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [Texts.allText, Texts.favoritesText, Texts.blockedText])
        control.selectedSegmentIndex = .zero
        return control
    }()
    
    private let refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()
    
    private let spinner: UIActivityIndicatorView = {
       return UIActivityIndicatorView(style: .medium)
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = UITableView.automaticDimension 
        tableView.separatorColor = .clear
        tableView.backgroundColor = .clear
        tableView.tableHeaderView = segmentControl
        tableView.tableFooterView = spinner
        tableView.verticalScrollIndicatorInsets.right = -Constants.horizontalSpacing
        tableView.delaysContentTouches = false
        tableView.clipsToBounds = false
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.delegate = self
        return tableView
    }()
    
    private let emptyNewsView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private let emptyFavoriteView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private let emptyBlockedView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private let router: IMainRouter = MainRouter()
    private let viewModel: IMainViewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        bindViewModel()
        
        loadLatestNews()
    }
}

private extension MainController {
    // MARK: - Private methods
    
    func configureUI() {
        view.backgroundColor = GlobalConstants.Colors.beigeColor
        title = Texts.titleText
        
        tableView.addSubview(refreshControl)
        
        tableView.addSubview(emptyNewsView)
        emptyNewsView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(MainModels.Constants.emptyNewsHeight)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        var config = UIButton.Configuration.plain()
        config.title = Texts.resfreshText
        config.image = Images.refreshImage
        config.imagePlacement = .trailing
        config.imagePadding = Constants.horizontalSpacing
        
        let emptyNewsButton = UIButton(type: .system)
        emptyNewsButton.backgroundColor = Colors.blueColor
        emptyNewsButton.tintColor = .white
        emptyNewsButton.roundConrers(cornerRadius: Constants.smallRadius)
        emptyNewsButton.configuration = config
        emptyNewsView.addSubview(emptyNewsButton)
        emptyNewsButton.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
            make.height.equalTo(Constants.defaultHeightButton)
            make.width.equalToSuperview()
        }
        emptyNewsButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.loadLatestNews()
        }).disposed(by: disposeBag)
        
        let emptyNewsLabel = UILabel()
        emptyNewsLabel.font = Fonts.primaryFont
        emptyNewsLabel.textColor = Colors.blackColor
        emptyNewsLabel.text = Texts.emptyNewsText
        emptyNewsLabel.setContentHuggingPriority(.required, for: .vertical)
        emptyNewsView.addSubview(emptyNewsLabel)
        emptyNewsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(emptyNewsButton.snp.top).offset(-Constants.verticalSpacing)
        }
        
        let emptyNewsImage = UIImageView(image: Images.emptyNewsImage)
        emptyNewsImage.tintColor = Colors.blueColor
        emptyNewsView.addSubview(emptyNewsImage)
        emptyNewsImage.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.bottom.equalTo(emptyNewsLabel.snp.top).offset(-Constants.verticalSpacing)
            make.width.equalTo(emptyNewsImage.snp.height)
        }
        
        tableView.addSubview(emptyFavoriteView)
        emptyFavoriteView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(MainModels.Constants.emptyFavoriteHeight)
        }
        
        let emptyFavoriteLabel = UILabel()
        emptyFavoriteLabel.font = Fonts.primaryFont
        emptyFavoriteLabel.textColor = Colors.blackColor
        emptyFavoriteLabel.text = Texts.emptyFavoritesText
        emptyFavoriteLabel.setContentHuggingPriority(.required, for: .vertical)
        emptyFavoriteView.addSubview(emptyFavoriteLabel)
        emptyFavoriteLabel.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
        }
        
        let emptyFavoriteImage = UIImageView(image: Images.emptyFavotitesImage)
        emptyFavoriteImage.tintColor = Colors.blueColor
        emptyFavoriteView.addSubview(emptyFavoriteImage)
        emptyFavoriteImage.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.bottom.equalTo(emptyFavoriteLabel.snp.top).offset(-Constants.verticalSpacing)
            make.width.equalTo(emptyFavoriteImage.snp.height)
        }
        
        tableView.addSubview(emptyBlockedView)
        emptyBlockedView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(emptyFavoriteView)
        }
        
        let emptyBlockedLabel = UILabel()
        emptyBlockedLabel.font = Fonts.primaryFont
        emptyBlockedLabel.textColor = Colors.blackColor
        emptyBlockedLabel.text = Texts.emptyBlockedText
        emptyBlockedLabel.setContentHuggingPriority(.required, for: .vertical)
        emptyBlockedView.addSubview(emptyBlockedLabel)
        emptyBlockedLabel.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
        }
        
        let emptyBlockedImage = UIImageView(image: Images.emptyBlockedImage)
        emptyBlockedImage.tintColor = Colors.blueColor
        emptyBlockedView.addSubview(emptyBlockedImage)
        emptyBlockedImage.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.bottom.equalTo(emptyBlockedLabel.snp.top).offset(-Constants.verticalSpacing)
            make.width.equalTo(emptyBlockedImage.snp.height)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Constants.horizontalSpacing)
            make.right.equalToSuperview().inset(Constants.horizontalSpacing)
            make.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    func loadLatestNews() {
        viewModel.loadLatestNews()
    }
    
    func bindViewModel() {
        viewModel.combinedItems
            .do(onNext: { _ in
                self.refreshControl.endRefreshing()
            })
            .bind(to: tableView.rx.items(
                cellIdentifier: NewsTableViewCell.identifier,
                cellType: NewsTableViewCell.self
            )) { index, item, cell in
                cell.configure(with: item,
                               viewModel: self.viewModel,
                               segment: SegmentType(rawValue: self.segmentControl.selectedSegmentIndex) ?? .all,
                               delegate: self
                )}
            .disposed(by: disposeBag)
        
        let selectedSegment = segmentControl.rx.selectedSegmentIndex
            .map { SegmentType(rawValue: $0) ?? .all }
            .share(replay: 1)
        
        selectedSegment
            .bind(onNext: { [viewModel] segment in
                viewModel.selectSegment(segment)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.combinedItems, selectedSegment)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] news, segment in
                guard let self = self else { return }
                
                updateEmptyViewsVisibility(isListEmpty: news.isEmpty, currentSegment: segment)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .do(onNext: { [weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            })
            .withLatestFrom(viewModel.combinedItems) { indexPath, data in
                return data[indexPath.row]
            }
            .subscribe(onNext: { selectedItem in
                switch selectedItem {
                    case .news(let news):
                        if let url = URL(string: news.url) {
                            UIApplication.shared.open(url)
                        }
                    case .navigation:
                        break
                    }
            })
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.loadLatestNews()
            })
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .withLatestFrom(viewModel.combinedItems) { (offset: $0, news: $1) }
            .filter { _, news in
                !news.isEmpty
            }
            .subscribe(onNext: { [weak self] offset, _ in
                guard let self = self else { return }
                let contentHeight = self.tableView.contentSize.height
                let height = self.tableView.frame.size.height

                if offset.y > contentHeight - height + MainModels.Constants.spacing {
                    self.viewModel.loadNews()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .bind(to: spinner.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.publishError
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self = self else { return }
                
                showWarningAlert(with: error)
                refreshControl.endRefreshing()
                spinner.stopAnimating()
                
                if tableView.visibleCells.isEmpty {
                    segmentControl.selectedSegmentIndex = (SegmentType.all).rawValue
                    updateEmptyViewsVisibility(
                        isListEmpty: true,
                        currentSegment: SegmentType.all
                    )
                }
            })
            .disposed(by: disposeBag)
    }
    
    func updateEmptyViewsVisibility(isListEmpty: Bool, currentSegment: SegmentType) {
        emptyNewsView.isHidden = !(isListEmpty && currentSegment == .all)
        emptyFavoriteView.isHidden = !(isListEmpty && currentSegment == .favorites)
        emptyBlockedView.isHidden = !(isListEmpty && currentSegment == .blocked)
    }
}

extension MainController: UITableViewDelegate {
    // MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row + 1) % (Constants.blockInterval + 1) == .zero {
            return  Constants.cellNavigationSize
        } else {
            return Constants.cellNewsSize
        }
    }
}

extension MainController: NewsTableViewCellDelegate {
    // MARK: - Cell Delegate Methods
    
    func showConfirmAlert(title: String, message: String, buttonTitle buttonText: String, action handler: @escaping () -> Void) {
        self.showAlert(title: title, message: message, buttonText: buttonText, handler: handler)
    }
    
    func navigation(navigation: NavigationDataResponse) {
        let navigationType = NavigationType(rawValue: navigation.navigation)
        let controller = InfoViewController()
        controller.initData(navigation: navigation)
        router.showViewController(from: self, to: controller, with: navigationType)
    }
}
