import LinkPresentation
import SnapKit
import UIKit

class NewsTableViewCell: UITableViewCell {
    
    // MARK: - Typealiases
    
    typealias Constants = CellsModels.Constants
    typealias Images = CellsModels.Images
    typealias Texts = CellsModels.Texts
    
    typealias Colors = GlobalConstants.Colors
    typealias Fonts = GlobalConstants.Fonts
    
    // MARK: - Properties
    
    static var identifier: String { "\(Self.self)" }
    
    // MARK: - News Properties
    
    private let containerNewsView = UIView()
    
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Colors.beigeColor
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var previewImage: UIImage? {
        didSet {
            newsImageView.image = previewImage
            
            if previewImage === Images.newsImage {
                newsImageView.contentMode = .center
            } else {
                newsImageView.contentMode = .scaleAspectFill
            }
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.numberOfLines = .zero
        label.textColor = Colors.blackColor
        label.font = Fonts.primaryFont
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.greyColor
        label.font = Fonts.secondaryFont
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.greyColor
        label.font = Fonts.secondaryFont
        return label
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = Colors.greyColor
        button.setBackgroundImage(Images.menuImage, for: .normal)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private var news: News?
    private var viewModel: IMainViewModel?
    private var linkView: LPLinkView?
    private var currentURL: URL?
    private var showAlert: ((String, String, String, @escaping () -> Void) -> Void)?
    
    // MARK: - Navigation Properties
    
    private let containerNavigationView = UIView()
    
    private let infoImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = Colors.blueColor
        return imageView
    }()
    
    private let titleNavigationLabel: UILabel = {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.numberOfLines = .zero
        label.textColor = Colors.blackColor
        label.font = Fonts.primaryFont
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.numberOfLines = .zero
        label.textColor = Colors.greyColor
        label.font = Fonts.secondaryFont
        return label
    }()
    
    private let navigationButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = Colors.blueColor
        button.roundConrers(cornerRadius: GlobalConstants.Constants.bigRadius)
        return button
    }()
    
    // MARK: - Static Metadata Cache
    private var metadataTask: Task<Void, Never>? = nil
    private static var imageCache: [URL: UIImage] = [:]
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUINews()
        configureUINavigation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        containerNewsView.removeFromSuperview()
        titleLabel.text = nil
        categoryLabel.text = nil
        dateLabel.text = nil
        currentURL = nil
        previewImage = Images.newsImage
        metadataTask?.cancel()
        metadataTask = nil
        
        containerNavigationView.removeFromSuperview()
        infoImageView.image = nil
        titleNavigationLabel.text = nil
        subtitleLabel.text = nil
        navigationButton.setTitle(nil, for: .normal)
        navigationButton.configuration = nil
    }
}

extension NewsTableViewCell {
    // MARK: - Methods
    
    func configure(
        with item: MainModels.TableItem,
        viewModel: IMainViewModel,
        segment: SegmentType,
        showAlert: ((String, String, String, @escaping () -> Void) -> Void)? = nil
    ) {
        switch item {
        case .news(let news):
            showView(containerNewsView)
            
            self.news = news
            self.showAlert = showAlert
            self.viewModel = viewModel
            titleLabel.text = news.title
            categoryLabel.text = news.sectionName
            dateLabel.text = news.date.getFormattedDate()

            menuButton.menu = getMenu(for: segment)
            
            if let url = URL(string: news.url) {
                currentURL = url
                loadPreviewImage(for: url)
            }
        case .navigation(let block):
            showView(containerNavigationView)
            
            titleNavigationLabel.text = block.title
            subtitleLabel.text = block.subtitle
            navigationButton.setTitle(block.buttonTitle, for: .normal)
            
            if let image = block.buttonSymbol {
                infoImageView.image = UIImage(systemName: image)
            }

            if let image = block.buttonSymbol {
                var config = UIButton.Configuration.plain()
                config.image = UIImage(systemName: image)
                config.imagePlacement = .trailing
                config.imagePadding = GlobalConstants.Constants.horizontalSpacing
                navigationButton.configuration = config
            }
        }
    }
}

private extension NewsTableViewCell {
    // MARK: - Private Methods
    
    func showView(_ view: UIView) {
        backgroundColor = .clear
        selectionStyle = .none
        
        view.backgroundColor = .systemBackground
        view.roundConrers(cornerRadius: GlobalConstants.Constants.bigRadius)
        
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(GlobalConstants.Constants.verticalSpacing)
            make.bottom.equalToSuperview().inset(GlobalConstants.Constants.verticalSpacing)
        }
    }
    
    func configureUINavigation() {

    }
    
    func configureUINews() {
        newsImageView.roundConrers(cornerRadius: GlobalConstants.Constants.smallRadius)
        containerNewsView.addSubview(newsImageView)

        newsImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(Constants.cellSpacing)
            make.bottom.equalToSuperview().inset(Constants.cellSpacing)
            make.width.equalTo(newsImageView.snp.height)
        }
        
        containerNewsView.addSubview(menuButton)
        menuButton.snp.makeConstraints { make in
            make.top.equalTo(newsImageView)
            make.right.equalToSuperview().inset(Constants.cellSpacing)
            make.width.height.equalTo(Constants.menuButtonSize)
        }
        
        containerNewsView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(newsImageView.snp.right).offset(GlobalConstants.Constants.horizontalSpacing)
            make.top.equalTo(newsImageView)
            make.right.equalTo(menuButton.snp.left).offset(-GlobalConstants.Constants.horizontalSpacing)
        }

        containerNewsView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(GlobalConstants.Constants.verticalSpacing)
            make.left.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().inset(GlobalConstants.Constants.verticalSpacing).priority(.high)
        }
        
        let circleImageView = UIImageView(image: Images.circleImage)
        circleImageView.tintColor = Colors.greyColor
        circleImageView.contentMode = .scaleAspectFit
        containerNewsView.addSubview(circleImageView)
        circleImageView.snp.makeConstraints { make in
            make.centerY.equalTo(categoryLabel).offset(1)
            make.left.equalTo(categoryLabel.snp.right).offset(Constants.cellSpacing / 3)
            make.width.height.equalTo(Constants.circleSize)
        }
        
        containerNewsView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel)
            make.left.equalTo(circleImageView.snp.right).offset(Constants.cellSpacing / 3)
            make.right.lessThanOrEqualTo(titleLabel)
        }
        
        previewImage = Images.newsImage
    }
    
    func getMenu(for segment: SegmentType) -> UIMenu {
        guard let news else { return UIMenu() }
        
        switch segment {
        case .all:
            return UIMenu(title: .empty, children: [
                UIAction(title: Texts.addToFavorite, image: Images.heartImage) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.viewModel?.toggleFavorite(news: news)
                    }
                },
                UIAction(title: Texts.block, image: Images.blockImage, attributes: .destructive) { _ in
                    if let showAlert = self.showAlert{
                        showAlert(Texts.titleBlock, Texts.messageBlock, Texts.block, { self.viewModel?.toggleBlocked(news: news) })
                    }
                }
            ])
            
        case .favorites:
            return UIMenu(title: .empty, children: [
                UIAction(title: Texts.removeFromFavorite, image: Images.heartSlashImage) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.viewModel?.toggleFavorite(news: news)
                    }
                },
                UIAction(title: Texts.block, image: Images.blockImage, attributes: .destructive) { _ in
                    if let showAlert = self.showAlert{
                        showAlert(Texts.titleBlock, Texts.messageBlock, Texts.block, { self.viewModel?.toggleBlocked(news: news) })
                    }
                }
            ])
            
        case .blocked:
            return UIMenu(title: .empty, children: [
                UIAction(title: Texts.unblock, image: Images.unblockImage, attributes: .destructive) { _ in
                    if let showAlert = self.showAlert{
                        showAlert(Texts.titleUnblock, Texts.messageUnblock, Texts.unblock, { self.viewModel?.toggleBlocked(news: news) })
                    }
                }
            ])
        }
    }
    
    private func loadPreviewImage(for url: URL) {
        // Если в кэше — сразу вернуть
        if let cachedImage = Self.imageCache[url] {
            previewImage = cachedImage
            return
        }

        metadataTask = Task { [weak self] in
            guard let self = self else { return }

            do {
                let metadata = try await LPMetadataProvider().startFetchingMetadata(for: url)
                guard self.currentURL == url else { return }

                if let imageProvider = metadata.imageProvider {
                    let image = try await imageProvider.loadPreviewImage()
                    Self.imageCache[url] = image
                    if self.currentURL == url {
                        previewImage = image
                    }
                }
            } catch {
                print("Preview image load failed:", error.localizedDescription)
            }
        }
    }
    
    func addLinkView(with metadata: LPLinkMetadata) {
        let linkView = LPLinkView(metadata: metadata)
        newsImageView.addSubview(linkView)
        linkView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.linkView = linkView
    }
}
