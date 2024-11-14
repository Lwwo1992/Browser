#import <Foundation/Foundation.h>

@class ProxyResponse;

@interface HttpProxyRequest : NSObject

/**
 * 单利初始化
 */
+(instancetype)manager;

/** header设置
 *  只需要
 */
- (void)refrestHeaderWithParameters:(NSDictionary *)parameters;

/** post请求
 *  urlString：请求api
 *  parameters：请求参数
 *  completion：返回结果
 */
- (void)sendPostRequestWithURL:(NSString *)urlString
                    parameters:(NSDictionary *)parameters
                    completion:(void(^)(ProxyResponse *successResponse))completion;

/** get请求
 *  urlString：请求api
 *  parameters：请求参数
 *  completion：返回结果
 */
- (void)sendGetRequestWithURL:(NSString *)urlString
                   parameters:(NSDictionary *)parameters
                   completion:(void(^)(ProxyResponse *failureResponse))completion;

@end

@interface ProxyResponse : NSObject

/// 接口返回数据
@property (nonatomic, strong, readonly)NSData *data;
/// 此参数可忽略
@property (nonatomic, strong, readonly)NSData *headerData;
/// 错误信息
@property (nonatomic, copy, readonly)NSString *message;
/// vpn请求状态码（非API）
@property (nonatomic, assign, readonly)int code;

+(ProxyResponse *)responseWithData:(NSData *)data headerData:(NSData *)headerData message:(NSString *)message code:(int)code;

@end
