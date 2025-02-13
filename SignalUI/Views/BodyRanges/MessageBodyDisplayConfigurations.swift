//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalServiceKit

public extension HydratedMessageBody.DisplayConfiguration {

    static func forMeasurement(font: UIFont) -> Self {
        // We can get away with this because unrevealed spoilers, mentions, and
        // search results all take up the same space as normal text.
        return .init(baseFont: font, baseTextColor: .fixed(.black))
    }

    static func forUnstyledText(
        font: UIFont,
        textColor: UIColor
    ) -> Self {
        return .init(
            baseFont: font,
            baseTextColor: .fixed(textColor),
            revealAllSpoilers: true
        )
    }

    static func messageBubble(
        isIncoming: Bool,
        revealedSpoilerIds: Set<StyleIdType>,
        searchRanges: SearchRanges?
    ) -> Self {
        let textColor = isIncoming ? ConversationStyle.bubbleTextColorIncomingThemed : ConversationStyle.bubbleTextColorOutgoingThemed
        let mentionBgColor: ThemedColor = isIncoming ? .incomingMessageBubbleMentionBg : .fixed(UIColor(white: 0, alpha: 0.25))
        return .init(
            baseFont: .defaultBaseFont,
            baseTextColor: textColor,
            mentionBackgroundColor: mentionBgColor,
            revealedSpoilerIds: revealedSpoilerIds,
            searchRanges: searchRanges
        )
    }

    static func composing() -> Self {
        return .init(
            baseFont: .defaultBaseFont,
            baseTextColor: ConversationStyle.bubbleTextColorIncomingThemed,
            mentionBackgroundColor: .incomingMessageBubbleMentionBg,
            revealedSpoilerBgColor: .incomingMessageBubbleMentionBg,
            revealAllSpoilers: true
        )
    }

    static func composingAttachment() -> Self {
        return .init(
            baseFont: .defaultBaseFont,
            baseTextColor: .fixed(Theme.darkThemePrimaryColor),
            mentionBackgroundColor: .fixed(.ows_gray75),
            revealedSpoilerBgColor: .fixed(.ows_gray75),
            revealAllSpoilers: true
        )
    }

    static func quotedReply(
        font: UIFont,
        textColor: ThemedColor
    ) -> Self {
        // Note: we never reveal spoilers in quoted replies under any circumstances.
        return .init(
            baseFont: font,
            baseTextColor: textColor
        )
    }

    static func longMessageView(
        revealedSpoilerIds: Set<StyleIdType>
    ) -> Self {
        return .init(
            baseFont: .defaultBaseFont,
            baseTextColor: .primaryText,
            mentionBackgroundColor: ThemedColor(
                light: .ows_blackAlpha20,
                dark: .ows_signalBlueDark
            ),
            revealedSpoilerIds: revealedSpoilerIds
        )
    }

    // TODO: Support revealing spoilers
    static func groupStoryReply() -> Self {
        return .init(
            baseFont: .defaultBaseFont,
            baseTextColor: .groupStoryReplyText,
            mentionBackgroundColor: .groupStoryReplyMentionBg
        )
    }

    static func composingGroupStoryReply() -> Self {
        return .init(
            baseFont: .defaultBaseFont,
            baseTextColor: .groupStoryReplyText,
            mentionBackgroundColor: .groupStoryReplyMentionBg,
            revealedSpoilerBgColor: .groupStoryReplyMentionBg,
            revealAllSpoilers: true
        )
    }

    static func conversationListSnippet(
        font: UIFont,
        textColor: ThemedColor
    ) -> Self {
        return .init(
            baseFont: font,
            baseTextColor: textColor
        )
    }

    static func conversationListSearchResultSnippet() -> Self {
        return .init(
            baseFont: .dynamicTypeBody2,
            baseTextColor: .secondaryTextAndIcon
        )
    }

    static func mediaCaption(
        revealedSpoilerIds: Set<StyleIdType>
    ) -> Self {
        return .init(
            baseFont: .dynamicTypeBodyClamped,
            baseTextColor: .fixed(.white),
            revealedSpoilerIds: revealedSpoilerIds
        )
    }
}

extension ThemedColor {
    fileprivate static let primaryText = ThemedColor(
        light: Theme.lightThemePrimaryColor,
        dark: Theme.darkThemePrimaryColor
    )
    fileprivate static let secondaryTextAndIcon = ThemedColor(
        light: Theme.lightThemeSecondaryTextAndIconColor,
        dark: Theme.darkThemeSecondaryTextAndIconColor
    )

    fileprivate static let incomingMessageBubbleMentionBg = ThemedColor(light: .ows_gray20, dark: .ows_gray60)

    fileprivate static let groupStoryReplyText: ThemedColor = .fixed(.ows_gray05)
    fileprivate static let groupStoryReplyMentionBg: ThemedColor = .fixed(.ows_gray60)
}

extension UIFont {
    fileprivate static let defaultBaseFont = UIFont.dynamicTypeBody
}
