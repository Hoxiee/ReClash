#import <Foundation/Foundation.h>
#import <Security/Security.h>

NS_ASSUME_NONNULL_BEGIN

NSDictionary *_Nullable RCCopySystemJob(NSString *label);

@interface RCHelperPeer : NSObject
@property(nonatomic, readonly) SecCodeRef code;
@property(nonatomic, readonly) uid_t uid;
@property(nonatomic, readonly) gid_t gid;
@property(nonatomic, readonly) pid_t pid;
@property(nonatomic, copy, readonly) NSString *connectionID;
@end

@protocol RCHelperListenerDelegate <NSObject>
- (void)handleRequest:(NSData *)request
            fromPeer:(RCHelperPeer *)peer
               reply:(void (^)(NSData *))reply;
- (void)connectionInvalidated:(NSString *)connectionID;
@end

@interface RCHelperListener : NSObject
- (instancetype)initWithServiceName:(NSString *)name
                              queue:(dispatch_queue_t)queue
                           delegate:(id<RCHelperListenerDelegate>)delegate;
- (void)activate;
- (void)invalidate;
@end

@interface RCHelperClient : NSObject
- (instancetype)initWithServiceName:(NSString *)name queue:(dispatch_queue_t)queue;
- (void)sendRequest:(NSData *)request
        completion:(void (^)(NSData *_Nullable, RCHelperPeer *_Nullable,
                             NSError *_Nullable))completion;
- (void)invalidate;
@end

SecCodeRef _Nullable RCCopySocketPeerCode(int fd) CF_RETURNS_RETAINED;
BOOL RCSocketPeer(int fd, uid_t *uid, pid_t *pid);

NS_ASSUME_NONNULL_END
