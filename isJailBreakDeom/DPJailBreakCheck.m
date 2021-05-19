//
//  DPJailBreakCheck.m
//  isJailBreakDeom
//
//  Created by dp on 2021/5/19.
//

#import "DPJailBreakCheck.h"
#import "AppDelegate.h"
#include <dlfcn.h>
#import <sys/stat.h>
@implementation DPJailBreakCheck
/**检查是不是越狱的机型*/
+(BOOL)isJailBreak{
    if ([self isJailBreakByToolPaths] || [self isJailBreakByCanOpenURL] || [self isJailBreakByApplications] || [self isJailBreakByCydia] || [self isJailBreakByPrintEnv]) {
        return YES;
    }
    return NO;
}
/**
 通常情况下，手机越狱后会增加以下文件
 /Applications/Cydia.app
 /Library/MobileSubstrate/MobileSubstrate.dylib
 /bin/bash
 /usr/sbin/sshd
 /etc/apt
 */
+(BOOL)isJailBreakByToolPaths{
    NSArray *jailbreak_tool_paths = @[
    @"/Applications/Cydia.app",
    @"/Library/MobileSubstrate/MobileSubstrate.dylib",
    @"/etc/apt"
    ];
    for (int i=0; i<jailbreak_tool_paths.count; i++) {
        
         if ([[NSFileManager defaultManager] fileExistsAtPath:jailbreak_tool_paths[i]]) {
            NSLog(@"The device is jail broken!");
            return YES;
         }
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
    
}
/**是否能打开cydia这个协议头*/
+(BOOL)isJailBreakByCanOpenURL{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
       NSLog(@"The device is jail broken!");
       return YES;
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}
/**
 越狱后的手机是可以获取到手机内安装的所有应用程序的，如果可以获取到就说明越狱了
 */
+(BOOL)isJailBreakByApplications{
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"User/Applications/"]) {
        NSLog(@"The device is jail broken!");
        NSArray *appList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"User/Applications/" error:nil];
        NSLog(@"appList = %@", appList);
        return YES;
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}
/**
 使用C语言的函数来判断，使用star方法判断cydia是否存在
 */
+(BOOL)isJailBreakByCydia{
    
    return checkCydia();
    
}
int checkInject() {
    int ret;
    Dl_info dylib_info;
    int (*func_stat)(const char*, struct stat*) = stat;
    char *dylib_name = "/usr/lib/system/libsystem_kernel.dylib";
    if ((ret = dladdr(func_stat, &dylib_info)) && strncmp(dylib_info.dli_fname, dylib_name, strlen(dylib_name))) {
       return 0;
    }
    return 1;
}
int checkCydia() {
    struct stat stat_info;
    if (!checkInject()) {
        if (0 == stat("/Applications/Cydia.app", &stat_info)) {
           return 1;
        }
    } else {
        return 1;
    }
    return 0;
}
/**
 根据读取的环境变量是否有值判断
 DYLD_INSERT_LIBRARIES环境变量在非越狱的设备上应该是空的，而越狱的设备基本上都会有Library/MobileSubstrate/MobileSubstrate.dylib
 */
+(BOOL)isJailBreakByPrintEnv{
    
    if (printEnv()) {
       NSLog(@"The device is jail broken!");
       return YES;
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
    
}
char* printEnv(void) {
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    NSLog(@"%s", env);
    return env;
}
@end
