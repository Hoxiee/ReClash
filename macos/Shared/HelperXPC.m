#import "HelperXPC.h"
#import <ServiceManagement/ServiceManagement.h>
#import <bsm/libbsm.h>
#import <sys/socket.h>
#import <sys/ucred.h>
#import <sys/un.h>
#import <xpc/xpc.h>

NSDictionary *RCCopySystemJob(NSString *label) {
    return CFBridgingRelease(SMCopyDictionary(kSMDomainSystemLaunchd, (__bridge CFStringRef)label));
}

static NSError *RCXPCError(NSString *detail) {
    return [NSError errorWithDomain:@"com.reclash.helper.xpc" code:1
                          userInfo:@{NSLocalizedDescriptionKey: detail}];
}

@implementation RCHelperPeer {
    SecCodeRef _code;
}

- (instancetype)initWithMessage:(xpc_object_t)message
                     connection:(xpc_connection_t)connection
                   connectionID:(NSString *)connectionID {
    self = [super init];
    if (!self) return nil;
    if (SecCodeCreateWithXPCMessage(message, kSecCSDefaultFlags, &_code) != errSecSuccess) {
        return nil;
    }
    _uid = xpc_connection_get_euid(connection);
    _gid = xpc_connection_get_egid(connection);
    _pid = xpc_connection_get_pid(connection);
    _connectionID = [connectionID copy];
    return self;
}

- (SecCodeRef)code { return _code; }
- (void)dealloc { if (_code) CFRelease(_code); }
@end

static NSData *RCPayload(xpc_object_t message) {
    if (xpc_get_type(message) != XPC_TYPE_DICTIONARY) return nil;
    __block BOOL valid = YES;
    xpc_dictionary_apply(message, ^bool(const char *key, xpc_object_t value) {
        if (strcmp(key, "payload") != 0) valid = NO;
        return true;
    });
    size_t length = 0;
    const void *bytes = xpc_dictionary_get_data(message, "payload", &length);
    if (!valid || !bytes || length == 0 || length > 4096) return nil;
    return [NSData dataWithBytes:bytes length:length];
}

@implementation RCHelperListener {
    xpc_connection_t _listener;
    NSMutableDictionary<NSString *, id> *_connections;
    dispatch_queue_t _queue;
    __weak id<RCHelperListenerDelegate> _delegate;
}

- (instancetype)initWithServiceName:(NSString *)name
                              queue:(dispatch_queue_t)queue
                           delegate:(id<RCHelperListenerDelegate>)delegate {
    self = [super init];
    if (!self) return nil;
    _queue = queue;
    _delegate = delegate;
    _connections = [NSMutableDictionary dictionary];
    _listener = xpc_connection_create_mach_service(name.UTF8String, queue,
                                                  XPC_CONNECTION_MACH_SERVICE_LISTENER);
    __weak RCHelperListener *weakSelf = self;
    xpc_connection_set_event_handler(_listener, ^(xpc_object_t event) {
        RCHelperListener *owner = weakSelf;
        if (!owner || xpc_get_type(event) != XPC_TYPE_CONNECTION) return;
        xpc_connection_t connection = (xpc_connection_t)event;
        NSString *connectionID = NSUUID.UUID.UUIDString;
        owner->_connections[connectionID] = connection;
        xpc_connection_set_target_queue(connection, owner->_queue);
        xpc_connection_set_event_handler(connection, ^(xpc_object_t message) {
            RCHelperListener *current = weakSelf;
            if (!current) return;
            if (xpc_get_type(message) == XPC_TYPE_ERROR) {
                [current->_delegate connectionInvalidated:connectionID];
                [current->_connections removeObjectForKey:connectionID];
                return;
            }
            NSData *payload = RCPayload(message);
            RCHelperPeer *peer = [[RCHelperPeer alloc] initWithMessage:message
                                                         connection:connection
                                                       connectionID:connectionID];
            xpc_object_t response = xpc_dictionary_create_reply(message);
            if (!payload || !peer || !response) {
                xpc_connection_cancel(connection);
                return;
            }
            [current->_delegate handleRequest:payload fromPeer:peer reply:^(NSData *data) {
                if (data.length > 4096) {
                    xpc_connection_cancel(connection);
                    return;
                }
                xpc_dictionary_set_data(response, "payload", data.bytes, data.length);
                xpc_connection_send_message(connection, response);
            }];
        });
        xpc_connection_activate(connection);
    });
    return self;
}

- (void)activate { xpc_connection_activate(_listener); }
- (void)invalidate {
    for (xpc_connection_t connection in _connections.allValues) {
        xpc_connection_cancel(connection);
    }
    [_connections removeAllObjects];
    xpc_connection_cancel(_listener);
}
@end

@implementation RCHelperClient {
    xpc_connection_t _connection;
    dispatch_queue_t _queue;
}

- (instancetype)initWithServiceName:(NSString *)name queue:(dispatch_queue_t)queue {
    self = [super init];
    if (!self) return nil;
    _queue = queue;
    _connection = xpc_connection_create_mach_service(name.UTF8String, queue,
                                                    XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
    xpc_connection_set_event_handler(_connection, ^(xpc_object_t event) {});
    xpc_connection_activate(_connection);
    return self;
}

- (void)sendRequest:(NSData *)request
        completion:(void (^)(NSData *, RCHelperPeer *, NSError *))completion {
    if (request.length == 0 || request.length > 4096) {
        completion(nil, nil, RCXPCError(@"Invalid helper request size"));
        return;
    }
    xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_data(message, "payload", request.bytes, request.length);
    xpc_connection_t connection = _connection;
    xpc_connection_send_message_with_reply(connection, message, _queue, ^(xpc_object_t reply) {
        NSData *payload = RCPayload(reply);
        RCHelperPeer *peer = [[RCHelperPeer alloc] initWithMessage:reply
                                                     connection:connection
                                                   connectionID:@"helper"];
        if (!payload || !peer) {
            completion(nil, nil, RCXPCError(@"Privileged helper did not return an authenticated reply"));
            return;
        }
        completion(payload, peer, nil);
    });
}

- (void)invalidate { xpc_connection_cancel(_connection); }
- (void)dealloc { xpc_connection_cancel(_connection); }
@end

BOOL RCSocketPeer(int fd, uid_t *uid, pid_t *pid) {
    struct xucred credential;
    socklen_t length = sizeof(credential);
    if (getsockopt(fd, SOL_LOCAL, LOCAL_PEERCRED, &credential, &length) != 0 ||
        credential.cr_version != XUCRED_VERSION) return NO;
    length = sizeof(*pid);
    if (getsockopt(fd, SOL_LOCAL, LOCAL_PEERPID, pid, &length) != 0) return NO;
    *uid = credential.cr_uid;
    return YES;
}

SecCodeRef RCCopySocketPeerCode(int fd) {
    audit_token_t token;
    socklen_t length = sizeof(token);
    if (getsockopt(fd, SOL_LOCAL, LOCAL_PEERTOKEN, &token, &length) != 0 ||
        length != sizeof(token)) return NULL;
    NSData *data = [NSData dataWithBytes:&token length:sizeof(token)];
    SecCodeRef code = NULL;
    if (SecCodeCopyGuestWithAttributes(NULL,
        (__bridge CFDictionaryRef)@{(__bridge NSString *)kSecGuestAttributeAudit: data},
        kSecCSDefaultFlags, &code) != errSecSuccess) return NULL;
    return code;
}
