//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

@objc
class PrivacySettingsViewController: OWSTableViewController2 {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("SETTINGS_PRIVACY_TITLE", comment: "")

        updateTableContents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateTableContents()
    }

    func updateTableContents() {
        let contents = OWSTableContents()

        let blockedSection = OWSTableSection()
        blockedSection.add(.disclosureItem(
            withText: NSLocalizedString(
                "SETTINGS_BLOCK_LIST_TITLE",
                comment: "Label for the block list section of the settings view"
            ),
            actionBlock: { [weak self] in
                let vc = BlockListViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        ))
        contents.addSection(blockedSection)

        let whoCanSection = OWSTableSection()
        whoCanSection.headerTitle = NSLocalizedString("SETTINGS_WHO_CAN", comment: "Label for the 'who can' privacy settings.")

        if FeatureFlags.phoneNumberSharing {
            whoCanSection.add(.disclosureItem(
                withText: NSLocalizedString(
                    "SETTINGS_PHONE_NUMBER_SHARING",
                    comment: "Label for the 'phone number sharing' setting."
                ),
                detailText: PhoneNumberSharingSettingsTableViewController.nameForCurrentMode,
                actionBlock: { [weak self] in
                    let vc = PhoneNumberSharingSettingsTableViewController()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            ))
        }

        if FeatureFlags.phoneNumberDiscoverability {
            whoCanSection.add(.disclosureItem(
                withText: NSLocalizedString(
                    "SETTINGS_PHONE_NUMBER_DISCOVERABILITY",
                    comment: "Label for the 'phone number discoverability' setting."
                ),
                detailText: PhoneNumberDiscoverabilitySettingsTableViewController.nameForCurrentDiscoverability,
                actionBlock: { [weak self] in
                    let vc = PhoneNumberDiscoverabilitySettingsTableViewController()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            ))
        }

        if !whoCanSection.items.isEmpty {
            contents.addSection(whoCanSection)
        }

        let messagingSection = OWSTableSection()
        messagingSection.headerTitle = NSLocalizedString(
            "SETTINGS_MESSAGING",
            comment: "Label for the 'messaging' privacy settings."
        )
        messagingSection.footerTitle = NSLocalizedString(
            "SETTINGS_MESSAGING_FOOTER",
            comment: "Explanation for the 'messaging' privacy settings."
        )
        messagingSection.add(.switch(
            withText: NSLocalizedString(
                "SETTINGS_READ_RECEIPT",
                comment: "Label for the 'read receipts' setting."
            ),
            isOn: { Self.readReceiptManager.areReadReceiptsEnabled() },
            target: self,
            selector: #selector(didToggleReadReceiptsSwitch)
        ))
        messagingSection.add(.switch(
            withText: NSLocalizedString(
                "SETTINGS_TYPING_INDICATORS",
                comment: "Label for the 'typing indicators' setting."
            ),
            isOn: { Self.typingIndicators.areTypingIndicatorsEnabled() },
            target: self,
            selector: #selector(didToggleTypingIndicatorsSwitch)
        ))
        contents.addSection(messagingSection)

        let appSecuritySection = OWSTableSection()
        appSecuritySection.headerTitle = NSLocalizedString("SETTINGS_SECURITY_TITLE", comment: "Section header")
        appSecuritySection.footerTitle = NSLocalizedString("SETTINGS_SECURITY_DETAIL", comment: "Section footer")
        appSecuritySection.add(.switch(
            withText: NSLocalizedString("SETTINGS_SCREEN_SECURITY", comment: ""),
            isOn: { Self.preferences.screenSecurityIsEnabled() },
            target: self,
            selector: #selector(didToggleReadReceiptsSwitch)
        ))
        appSecuritySection.add(.switch(
            withText: NSLocalizedString(
                "SETTINGS_SCREEN_LOCK_SWITCH_LABEL",
                comment: "Label for the 'enable screen lock' switch of the privacy settings."
            ),
            isOn: { OWSScreenLock.shared.isScreenLockEnabled() },
            target: self,
            selector: #selector(didToggleScreenScreenLockSwitch)
        ))
        if OWSScreenLock.shared.isScreenLockEnabled() {
            appSecuritySection.add(.disclosureItem(
                withText: NSLocalizedString(
                    "SETTINGS_SCREEN_LOCK_ACTIVITY_TIMEOUT",
                    comment: "Label for the 'screen lock activity timeout' setting of the privacy settings."
                ),
                detailText: formatScreenLockTimeout(OWSScreenLock.shared.screenLockTimeout()),
                actionBlock: { [weak self] in
                    self?.showScreenLockTimeoutPicker()
                }
            ))
        }
        contents.addSection(appSecuritySection)

        if !CallUIAdapter.isCallkitDisabledForLocale {
            let callsSection = OWSTableSection()
            callsSection.headerTitle = NSLocalizedString(
                "SETTINGS_SECTION_TITLE_CALLING",
                comment: "settings topic header for table section"
            )
            callsSection.add(.switch(
                withText: NSLocalizedString(
                    "SETTINGS_PRIVACY_CALLKIT_SYSTEM_CALL_LOG_PREFERENCE_TITLE",
                    comment: "Short table cell label"
                ),
                isOn: { Self.preferences.isSystemCallLogEnabled() },
                target: self,
                selector: #selector(didToggleEnableSystemCallLogSwitch)
            ))
            contents.addSection(callsSection)
        }

        let advancedSection = OWSTableSection()
        advancedSection.add(.disclosureItem(
            withText: NSLocalizedString(
                "SETTINGS_PRIVACY_ADVANCED_TITLE",
                comment: "Title for the advanced privacy settings"
            ),
            actionBlock: { [weak self] in
                let vc = AdvancedPrivacySettingsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        ))
        contents.addSection(advancedSection)

        self.contents = contents
    }

    @objc
    func didToggleReadReceiptsSwitch(_ sender: UISwitch) {
        readReceiptManager.setAreReadReceiptsEnabledWithSneakyTransactionAndSyncConfiguration(sender.isOn)
    }

    @objc
    func didToggleTypingIndicatorsSwitch(_ sender: UISwitch) {
        typingIndicators.setTypingIndicatorsEnabledAndSendSyncMessage(value: sender.isOn)
    }

    @objc
    func didToggleScreenSecuritySwitch(_ sender: UISwitch) {
        preferences.setScreenSecurity(sender.isOn)
    }

    @objc
    func didToggleScreenScreenLockSwitch(_ sender: UISwitch) {
        OWSScreenLock.shared.setIsScreenLockEnabled(sender.isOn)
        updateTableContents()
    }

    private func showScreenLockTimeoutPicker() {
        let actionSheet = ActionSheetController(title: NSLocalizedString(
            "SETTINGS_SCREEN_LOCK_ACTIVITY_TIMEOUT",
            comment: "Label for the 'screen lock activity timeout' setting of the privacy settings."
        ))

        for timeout in OWSScreenLock.shared.screenLockTimeouts {
            actionSheet.addAction(.init(
                title: formatScreenLockTimeout(timeout, useShortFormat: false),
                handler: { [weak self] _ in
                    OWSScreenLock.shared.setScreenLockTimeout(timeout)
                    self?.updateTableContents()
                }
            ))
        }

        actionSheet.addAction(OWSActionSheets.cancelAction)

        presentActionSheet(actionSheet)
    }

    private func formatScreenLockTimeout(_ value: TimeInterval, useShortFormat: Bool = true) -> String {
        guard value > 0 else {
            return NSLocalizedString(
                "SCREEN_LOCK_ACTIVITY_TIMEOUT_NONE",
                comment: "Indicates a delay of zero seconds, and that 'screen lock activity' will timeout immediately."
            )
        }
        return NSString.formatDurationSeconds(UInt32(value), useShortFormat: useShortFormat)
    }

    @objc
    func didToggleEnableSystemCallLogSwitch(_ sender: UISwitch) {
        preferences.setIsSystemCallLogEnabled(sender.isOn)

        // rebuild callUIAdapter since CallKit configuration changed.
        AppEnvironment.shared.callService.individualCallService.createCallUIAdapter()
    }
}
