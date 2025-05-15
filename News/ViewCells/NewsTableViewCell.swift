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
    
    private lazy var menuButton: UIButton = {
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
    
    // MARK: - Static Metadata Cache
    private var metadataTask: Task<Void, Never>? = nil
    private static var imageCache: [URL: UIImage] = [:]
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        categoryLabel.text = nil
        dateLabel.text = nil
        currentURL = nil
        previewImage = Images.newsImage
        
        metadataTask?.cancel()
        metadataTask = nil
    }
}

extension NewsTableViewCell {
    // MARK: - Methods
    
    func configure(
        with news: News,
        viewModel: IMainViewModel,
        segment: SegmentType,
        showAlert: ((String, String, String, @escaping () -> Void) -> Void)? = nil
    ) {
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
    }
}

private extension NewsTableViewCell {
    // MARK: - Private Methods
    
    func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.roundConrers(cornerRadius: GlobalConstants.Constants.bigRadius)
        contentView.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(GlobalConstants.Constants.verticalSpacing)
            make.bottom.equalToSuperview().inset(GlobalConstants.Constants.verticalSpacing)
        }

        newsImageView.roundConrers(cornerRadius: GlobalConstants.Constants.smallRadius)
        containerView.addSubview(newsImageView)

        newsImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(Constants.cellSpacing)
            make.bottom.equalToSuperview().inset(Constants.cellSpacing)
            make.width.equalTo(newsImageView.snp.height)
        }
        
        containerView.addSubview(menuButton)

        menuButton.snp.makeConstraints { make in
            make.top.equalTo(newsImageView)
            make.right.equalToSuperview().inset(Constants.cellSpacing)
            make.width.height.equalTo(Constants.menuButtonSize)
        }
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(newsImageView.snp.right).offset(GlobalConstants.Constants.horizontalSpacing)
            make.top.equalTo(newsImageView)
            make.right.equalTo(menuButton.snp.left).offset(-GlobalConstants.Constants.horizontalSpacing)
        }

        containerView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(GlobalConstants.Constants.verticalSpacing)
            make.left.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().inset(GlobalConstants.Constants.verticalSpacing).priority(.high)
        }
        
        let circleImageView = UIImageView(image: Images.circleImage)
        circleImageView.tintColor = Colors.greyColor
        circleImageView.contentMode = .scaleAspectFit
        containerView.addSubview(circleImageView)
        circleImageView.snp.makeConstraints { make in
            make.centerY.equalTo(categoryLabel).offset(1)
            make.left.equalTo(categoryLabel.snp.right).offset(Constants.cellSpacing / 3)
            make.width.height.equalTo(Constants.circleSize)
        }
        
        containerView.addSubview(dateLabel)
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
                    self.viewModel?.toggleFavorite(news: news)
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
                    self.viewModel?.toggleFavorite(news: news)
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
