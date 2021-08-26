//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "OWSRecoverableDecryptionPlaceholder.h"
#import "TSThread.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@implementation OWSRecoverableDecryptionPlaceholder

- (nullable instancetype)initWithFailedEnvelope:(SSKProtoEnvelope *)envelope
                                        groupId:(nullable NSData *)groupId
                                    transaction:(SDSAnyWriteTransaction *)writeTx
{
    SignalServiceAddress *sender = [[SignalServiceAddress alloc] initWithUuidString:envelope.sourceUuid];
    if (!sender) {
        OWSFailDebug(@"Invalid UUID");
        return nil;
    }

    TSThread *thread;
    if (groupId.length > 0) {
        thread = [TSGroupThread fetchWithGroupId:groupId transaction:writeTx];
        OWSAssertDebug(thread);
    }
    if (!thread) {
        thread = [TSContactThread getThreadWithContactAddress:sender transaction:writeTx];
        OWSAssertDebug(thread);
    }
    if (!thread) {
        return nil;
    }
    TSErrorMessageBuilder *builder =
        [TSErrorMessageBuilder errorMessageBuilderWithThread:thread errorType:TSErrorMessageDecryptionFailure];
    builder.timestamp = envelope.timestamp;
    builder.senderAddress = sender;
    return [super initErrorMessageWithBuilder:builder];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    return [super initWithCoder:coder];
}

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run
// `sds_codegen.sh`.

// clang-format off
// clang-format on

// --- CODE GENERATION MARKER

#pragma mark - Methods

- (NSDate *)expirationDate
{
    NSTimeInterval expirationInterval = [RemoteConfig replaceableInteractionExpiration];
    OWSAssertDebug(expirationInterval >= 0);

    if (SSKDebugFlags.fastPlaceholderExpiration.value) {
        expirationInterval = MIN(expirationInterval, 5.0);
    }

    return [self.receivedAtDate dateByAddingTimeInterval:MAX(0, expirationInterval)];
}

- (BOOL)supportsReplacement
{
    return [self.expirationDate isAfterNow] && !self.wasRead;
}

- (NSString *)previewTextWithTransaction:(SDSAnyReadTransaction *)transaction
{
    NSString *_Nullable senderName = nil;
    if (self.sender) {
        senderName = [self.contactsManager shortDisplayNameForAddress:self.sender transaction:transaction];
    }

    if (SSKDebugFlags.showFailedDecryptionPlaceholders.value) {
        return [[NSString alloc]
            initWithFormat:@"Placeholder for timestamp: %llu from sender: %@", self.timestamp, senderName];
    } else if (senderName) {
        OWSFailDebug(@"Should not be directly surfaced to user");
        NSString *formatString = NSLocalizedString(@"ERROR_MESSAGE_DECRYPTION_FAILURE",
            @"Error message for a decryption failure. Embeds {{sender short name}}.");
        return [[NSString alloc] initWithFormat:formatString, senderName];
    } else {
        OWSFailDebug(@"Should not be directly surfaced to user");
        return NSLocalizedString(
            @"ERROR_MESSAGE_DECRYPTION_FAILURE_UNKNOWN_SENDER", @"Error message for a decryption failure.");
    }
}

- (void)anyDidInsertWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [super anyDidInsertWithTransaction:transaction];
    [self.messageDecrypter scheduleCleanupIfNecessaryFor:self transaction:transaction];
}

#pragma mark - <OWSReadTracking>

- (void)markAsReadAtTimestamp:(uint64_t)readTimestamp
                       thread:(TSThread *)thread
                 circumstance:(OWSReceiptCircumstance)circumstance
                  transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSLogInfo(@"Marking placeholder as read. No longer eligible for inline replacement.");
    [super markAsReadAtTimestamp:readTimestamp thread:thread circumstance:circumstance transaction:transaction];
}

#pragma mark - Testing

#if TESTABLE_BUILD
- (instancetype)initFakePlaceholderWithTimestamp:(uint64_t)timestamp thread:(TSThread *)thread sender:(SignalServiceAddress *)sender
{
    TSErrorMessageBuilder *builder = [TSErrorMessageBuilder errorMessageBuilderWithThread:thread errorType:TSErrorMessageDecryptionFailure];
    builder.timestamp = timestamp;
    builder.senderAddress = sender;
    return [super initErrorMessageWithBuilder:builder];
}
#endif

@end

NS_ASSUME_NONNULL_END
