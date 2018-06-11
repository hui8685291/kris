//
//  ViewController.m
//  DYM
//
//  Created by Kris on 2018/5/18.
//  Copyright © 2018年 Kris. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
typedef void (^GetDataCompletion) (NSData *data);
static NSString *const KVO_CONTEXT_ADDRESS_CHANGED = @"KVO_CONTEXT_ADDRESS_CHANGED";
@interface ViewController ()<NSCacheDelegate,NSURLConnectionDataDelegate>{
    Person *peson;
    NSTimer *timer;
}
@property(strong,nonatomic)NSCache *chaseh;
@property(strong,nonatomic)NSString  *localLastModified;
@property(strong,nonatomic)NSString  *Etag;
@property(nonatomic,strong)NSThread *thread;

@property(copy,nonatomic)GetDataCompletion getDataCompletion;
@end
//niljkdsflks
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //KVC
    peson = [Person new];
    NSString *originalName = [peson valueForKey:@"name"];
    [peson setValue:@"Steven" forKey:@"name"];
    NSString *originalNames = [peson valueForKey:@"_name"];
    NSLog(@"Changed %@'s name to: %@", originalName, originalNames);
    
    //KVO
    [self watchPersonForChangeOfAddress];
    
    
    
}
#pragma mark --runLoop 让线程更持久

- (IBAction)openThread:(id)sender {
//    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(task1) object:nil];
//    [thread start];
//    self.thread = thread;
    [self timers];
}
- (void)timers{
   
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool{
         timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(run) userInfo:nil repeats:YES];
        NSRunLoop *currentLoops = [NSRunLoop currentRunLoop];
        [currentLoops addTimer:timer forMode:NSDefaultRunLoopMode];
        [currentLoops run];
        }
    });
}
-(void)run
{
    NSLog(@"run-----%@---%@",[NSThread currentThread],[NSRunLoop currentRunLoop].currentMode);
}

//MARK:runloop添加port
- (void)task1{
    NSLog(@"task1----%@",[NSThread currentThread]);//子线程
    /**
     利用runloop 的目的就是为了让线程长时间存活。
          01 这里我们要明确一个知识点:线程的生命周期与任务有关,任务执行完毕,它会自动销毁,就算你用强指针指着它也还是不行.
          02 如果想让线程不死,可以让任务不结束,我们可以仿苹果做法,让线程有任务就执行,没执行就休眠.
          03 我们知道runloop: 只要runloop 中有model, model中有timer/source/observer/ 它就不会退出.
          04 在开发中如果是为了让一个任务不结束,我们很少创建一个timer,因为一个timer就又涉及到时间.
          05 在开发中我们一般选择source 的方式:开一个端口
          06 以上这些做法都是在结束中执行,因为你是要任务不结束
     */
    NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
    [currentLoop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    
    [currentLoop run];
    
}
- (IBAction)reOpenThread:(id)sender {
    [timer invalidate];
    //[self performSelector:@selector(task2) onThread:self.thread withObject:nil waitUntilDone:YES];
}
- (void)task2{
    NSLog(@"task2----%@",[NSThread currentThread]);//子线程
}
#pragma mark --
-(void) watchPersonForChangeOfAddress
{
    
    // this begins the observing
    [peson addObserver:self
        forKeyPath:@"address"
               options:0  context:(__bridge void * _Nullable)(KVO_CONTEXT_ADDRESS_CHANGED)];
    
    
}
- (IBAction)addressChange:(id)sender {
    peson.address = @"你好";
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context

{

    if(context == (__bridge void * _Nullable)(KVO_CONTEXT_ADDRESS_CHANGED)) {
        NSString *name = [object valueForKey:@"name"];
        NSString *address = [object valueForKey:@"address"];
        NSLog(@"%@ has a new address: %@", name, address);
    }
}
#pragma mark --
- (IBAction)urlCacheSelector:(id)sender {
    //[self getData:self.getDataCompletion];
    [self nsURLConnection];
}


-(void)nsURLConnection{
    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    NSString*path=[paths objectAtIndex:0];
    
    NSLog(@"path:%@",path);
    
   NSURLCache *urlCache = [NSURLCache sharedURLCache];
    
    
    
    [urlCache setMemoryCapacity:1*1024*1024];
    
    //创建一个nsurl
    
    NSURL *url = [NSURL URLWithString:@"https://csdnimg.cn/release/phoenix/vendor/tingyun/tingyun-rum-blog.js"];
    
    //创建一个请求
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url
                  
                                         cachePolicy:NSURLRequestReturnCacheDataElseLoad
                  
                                     timeoutInterval:30.0f];
    

    
    //从请求中获取缓存输出
    
    NSCachedURLResponse *response =[urlCache cachedResponseForRequest:request];
    
    //判断是否有缓存
    
//    if (response != nil){
//
//        NSLog(@"如果有缓存输出，从缓存中获取数据");
//
//        [request setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
//
//    }
    
    
    
    NSURLConnection *newConnection = [[NSURLConnection alloc] initWithRequest:request
                                      
                                                                     delegate:self
                                      
                                                             startImmediately:YES];
    
  
}
//使用下面代码，我将请求的过程打印出来

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"response %@",response);
    NSLog(@"将接收输出");
    
}

- (NSURLRequest *)connection:(NSURLConnection *)connection

             willSendRequest:(NSURLRequest *)request

            redirectResponse:(NSURLResponse *)redirectResponse{
    
    NSLog(@"即将发送请求");
    
    return(request);
    
}

- (void)connection:(NSURLConnection *)connection

    didReceiveData:(NSData *)data{
    
    NSLog(@"接受数据");
    
    NSLog(@"数据长度为 = %lu", (unsigned long)[data length]);
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection

                  willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    
    NSLog(@"将缓存输出");
    
    return(cachedResponse);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    NSLog(@"请求完成");
    
}

- (void)connection:(NSURLConnection *)connection

  didFailWithError:(NSError *)error{
    
    NSLog(@"请求失败");
    
}



#pragma mark --
- (void)nsUrlCache{
    
}
- (void)nscache{
    // 循环的向cache中添加对象
    
    for (int i =0; i < 100000; i++) {
        
        NSString *str = [NSString stringWithFormat:@"hello_%d",i+1];
        
        NSLog(@"添加 %@",str);
        
        NSString *key = [NSString stringWithFormat:@"key_%d",i];
        
        
        
        [self.chaseh setObject:str forKey:key];
        
    }
    
    
    
    // 循环的取值
    
    for (int i =0; i < 100000; i++) {
        
        NSString *key = [NSString stringWithFormat:@"key_%d",i];
        
        NSString *str = [self.chaseh objectForKey:key];
        
        NSLog(@"获取 %@",str);
        
    }
}
- (NSCache *)chaseh{
    if (!_chaseh) {
        _chaseh = [NSCache new];
        _chaseh.delegate = self;
        _chaseh.countLimit = 15;
        _chaseh.totalCostLimit = 1;// 10M
    }
    return  _chaseh;
}
/// NSCache的代理方法,在对象将要从cache中移除的时候调用的

- (void)cache:(NSCache *)cache willEvictObject:(id)obj

{
    
    NSLog(@"移除 %@",obj);
    
}
- (void)getData:(GetDataCompletion)completion {
    //@"http://image17-c.poco.cn/mypoco/myphoto/20151211/16/17338872420151211164742047.png"
    NSURL *url = [NSURL URLWithString:@"https://csdnimg.cn/release/phoenix/vendor/tingyun/tingyun-rum-blog.js"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:15.0];
    
    //    // 发送 etag
    //    if (self.etag.le ngth > 0) {
    //        [request setValue:self.etag forHTTPHeaderField:@"If-None-Match"];
    //    }
    // 发送 LastModified
    if (self.localLastModified.length > 0) {
        [request setValue:self.localLastModified forHTTPHeaderField:@"If-Modified-Since"];
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"555a***  %@",data);
        // NSLog(@"%@ %tu", response, data.length);
        // 类型转换（如果将父类设置给子类，需要强制转换）
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"statusCode == %@", @(httpResponse.statusCode));
        // 判断响应的状态码是否是 304 Not Modified （更多状态码含义解释： https://github.com/ChenYilong/iOSDevelopmentTips）
        if (httpResponse.statusCode == 304) {
            NSLog(@"加载本地缓存图片");
            // 如果是，使用本地缓存
            // 根据请求获取到`被缓存的响应`！
            NSCachedURLResponse *cacheResponse =  [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
            // 拿到缓存的数据
            data = cacheResponse.data;
        }
        NSCachedURLResponse *cacheResponse =  [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
        // 拿到缓存的数据
        BOOL iscahse = !cacheResponse.data ?0 :1;
        NSLog(@"data***  %d",iscahse);
        
        // 获取并且纪录 etag，区分大小写
        //        self.etag = httpResponse.allHeaderFields[@"Etag"];
        // 获取并且纪录 LastModified
        self.localLastModified = httpResponse.allHeaderFields[@"Last-Modified"];
        //        NSLog(@"%@", self.etag);
        NSLog(@"%@", self.localLastModified);
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion ?: completion(data);
        });
    }] resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
