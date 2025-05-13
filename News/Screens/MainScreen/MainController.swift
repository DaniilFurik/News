import SnapKit
import RxSwift
import UIKit

class MainController: UIViewController {
    
    // MARK: - Typealiases
    
    typealias Constants = GlobalConstants.Constants
    typealias Texts = MainModels.Texts
    
    // MARK: - Properties
    
    private let segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [Texts.allText, Texts.favoritesText, Texts.blockedText])
        control.selectedSegmentIndex = .zero
        return control
    }()
    
    private let refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = Constants.cellSize
        tableView.estimatedRowHeight = UITableView.automaticDimension 
        tableView.separatorColor = .clear
        tableView.backgroundColor = .clear
        tableView.tableHeaderView = segmentControl
        //tableView.refreshControl = refreshControl
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return tableView
    }()
    
    private let viewModel: IMainViewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadNews()
    }
}

private extension MainController {
    // MARK: - Private methods
    
    func configureUI() {
        view.backgroundColor = GlobalConstants.Colors.beigeColor
        title = Texts.titleText
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Constants.horizontalSpacing)
            make.right.equalToSuperview().inset(Constants.horizontalSpacing)
            make.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        tableView.rx.itemSelected
            .do(onNext: { [weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            })
            .withLatestFrom(viewModel.newsItems) { indexPath, data in
                return data[indexPath.row]
            }
            .subscribe(onNext: { selectedItem in
                if let url = URL(string: selectedItem.url) {
                    UIApplication.shared.open(url)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        viewModel.newsItems
            .bind(to: tableView.rx.items(
                cellIdentifier: NewsTableViewCell.identifier,
                cellType: NewsTableViewCell.self
            )) { index, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
    }
}
