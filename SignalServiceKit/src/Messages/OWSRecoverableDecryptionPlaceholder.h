//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import <SignalServiceKit/TSErrorMessage.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSRecoverableDecryptionPlaceholder : TSErrorMessage <OWSReadTracking>

- (instancetype)initErrorMessageWithBuilder:(TSErrorMessageBuilder *)errorMessageBuilder NS_UNAVAILABLE;
- (nullable instancetype)initWithFailedEnvelope:(SSKProtoEnvelope *)envelope
                                        groupId:(nullable NSData *)groupId
                                    transaction:(SDSAnyWriteTransaction *)writeTx NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

@property (assign, nonatomic, readonly) BOOL supportsReplacement;

/// After this date, the placeholder is no longer eligible for replacement with the original content.
@property (strong, nonatomic, readonly) NSDate *expirationDate;

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run
// `sds_codegen.sh`.

// clang-format off
// clang-format on

// --- CODE GENERATION MARKER

#if TESTABLE_BUILD
- (instancetype)initFakePlaceholderWithTimestamp:(uint64_t)timestamp thread:(TSThread *)thread sender:(SignalServiceAddress *)sender;
#endif

@end

NS_ASSUME_NONNULL_END
