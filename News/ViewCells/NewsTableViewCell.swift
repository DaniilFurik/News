import LinkPresentation
import SnapKit
import UIKit

class NewsTableViewCell: UITableViewCell {
    
    // MARK: - Typealiases
    
    typealias Constants = GlobalConstants.Constants
    typealias Colors = GlobalConstants.Colors
    typealias Fonts = GlobalConstants.Fonts
    
    // MARK: - Properties
    
    static var identifier: String { "\(Self.self)" }
    
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Colors.beigeColor
        imageView.contentMode = .center
        imageView.image = UIImage(systemName: "text.page")
        return imageView
    }()
    
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
        let button = UIButton()
        return button
    }()
    
    private var linkView: LPLinkView?
    private var currentURL: URL?
    
    // MARK: - Static Metadata Cache
    private static var metadataCache: [URL: LPLinkMetadata] = [:]
    
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
        
        linkView?.removeFromSuperview()
        linkView = nil
        currentURL = nil
    }
}

extension NewsTableViewCell {
    // MARK: - Methods
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.roundConrers(cornerRadius: Constants.bigRadius)
        contentView.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(Constants.verticalSpacing)
            make.bottom.equalToSuperview().inset(Constants.verticalSpacing)
        }

        newsImageView.roundConrers(cornerRadius: Constants.smallRadius)
        containerView.addSubview(newsImageView)

        newsImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(Constants.cellSpacing)
            make.bottom.equalToSuperview().inset(Constants.cellSpacing)
            make.width.equalTo(newsImageView.snp.height)
        }
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(newsImageView.snp.right).offset(Constants.horizontalSpacing)
            make.top.equalTo(newsImageView)
            make.right.equalTo(containerView).inset(Constants.horizontalSpacing)
        }
        
        containerView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.verticalSpacing)
            make.left.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().inset(Constants.verticalSpacing).priority(.high)
        }
    }

    private func addLinkView(with metadata: LPLinkMetadata) {
        let linkView = LPLinkView(metadata: metadata)
        newsImageView.addSubview(linkView)
        linkView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.linkView = linkView
    }
    
    func configure(with news: News) {
        titleLabel.text = news.title
        categoryLabel.text = news.sectionName
        currentURL = URL(string: news.url)
        
        if let url = currentURL {
            // Если уже есть метаданные — используем сразу
            if let cachedMetadata = Self.metadataCache[url] {
                addLinkView(with: cachedMetadata)
                return
            }
            
            // Иначе грузим через LPMetadataProvider
            let provider = LPMetadataProvider()
            provider.startFetchingMetadata(for: url) { [weak self] metadata, error in
                guard
                    let self = self,
                    let metadata = metadata,
                    self.currentURL == url,
                    error == nil
                else {
                    return
                }
                
                // Кэшируем и отображаем
                Self.metadataCache[url] = metadata
                DispatchQueue.main.async {
                    self.addLinkView(with: metadata)
                }
            }
        }
        
        layoutIfNeeded()
    }
}
