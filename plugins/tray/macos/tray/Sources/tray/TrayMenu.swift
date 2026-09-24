import AppKit

final class TrayMenu: NSMenu {
    private let onSelect: (Int) -> Void

    init(items: [[String: Any]], onSelect: @escaping (Int) -> Void) {
        self.onSelect = onSelect
        super.init(title: "")
        autoenablesItems = false
        let detailTab = TrayMenu.detailTab(for: items)
        for entry in items {
            addItem(makeItem(entry, detailTab: detailTab))
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeItem(_ entry: [String: Any], detailTab: CGFloat) -> NSMenuItem {
        let type = entry["type"] as? String ?? ""
        if type == "separator" {
            return NSMenuItem.separator()
        }

        let item = NSMenuItem()
        item.title = entry["label"] as? String ?? ""
        item.tag = entry["id"] as? Int ?? 0
        item.isEnabled = entry["enabled"] as? Bool ?? true

        if detailTab > 0, let detail = entry["detail"] as? String, !detail.isEmpty {
            item.attributedTitle = TrayMenu.attributedTitle(
                item.title,
                detail: detail,
                tab: detailTab
            )
        }

        switch type {
        case "checkbox":
            item.state = (entry["checked"] as? Bool ?? false) ? .on : .off
            item.target = self
            item.action = #selector(didSelectItem(_:))
        case "submenu":
            let children = entry["items"] as? [[String: Any]] ?? []
            setSubmenu(TrayMenu(items: children, onSelect: onSelect), for: item)
        default:
            item.target = self
            item.action = #selector(didSelectItem(_:))
        }

        return item
    }

    /// Detail text right-aligns to one column, so the tab stop clears the
    /// widest label in this menu; zero means no item carries a detail.
    private static func detailTab(for items: [[String: Any]]) -> CGFloat {
        let font = NSFont.menuFont(ofSize: 0)
        var maxWidth: CGFloat = 0
        var hasDetail = false
        for entry in items {
            if let detail = entry["detail"] as? String, !detail.isEmpty {
                hasDetail = true
            }
            let label = entry["label"] as? String ?? ""
            let width = (label as NSString)
                .size(withAttributes: [.font: font]).width
            maxWidth = max(maxWidth, width)
        }
        return hasDetail ? maxWidth + 32 : 0
    }

    private static func attributedTitle(
        _ label: String,
        detail: String,
        tab: CGFloat
    ) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.tabStops = [NSTextTab(textAlignment: .right, location: tab)]
        let font = NSFont.menuFont(ofSize: 0)
        let result = NSMutableAttributedString(
            string: label + "\t" + detail,
            attributes: [.font: font, .paragraphStyle: paragraph]
        )
        let detailRange = NSRange(
            location: (label as NSString).length + 1,
            length: (detail as NSString).length
        )
        result.addAttribute(
            .foregroundColor,
            value: NSColor.tertiaryLabelColor,
            range: detailRange
        )
        return result
    }

    @objc private func didSelectItem(_ sender: NSMenuItem) {
        onSelect(sender.tag)
    }
}
