//
//  Logger.h
//  Bot
//
//  Created by Anton Zemyanov on 21.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GlobalConfig.h"

#ifndef RELEASE_BUILD
#define LOG_ENABLE_DEBUG	1
#define LOG_ENABLE_MESSAGE	1
#define LOG_ENABLE_ERROR	1
#define LOG_ENABLE_NETWORK	1
#endif

void OpenLog();
void CloseLog();

void DbgLog(NSString *fmt,...);
void MsgLog(NSString *fmt,...);
void ErrLog(NSString *fmt,...);
void NetLog(NSString *fmt,...);
