//
//  Logger.m
//  Bot
//
//  Created by Anton Zemyanov on 21.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Logger.h"
#include <sys/time.h>
#include <pthread.h>

#define MAX_LOG_STRING_LENGTH	(256*64*4)

pthread_mutex_t log_mutex;

void OpenLog()
{
	int res = pthread_mutex_init(&log_mutex, NULL);
	if(res!=0)
		[NSException raise:@"LOG" format:@"Cant create log mutex"];
	return;
}

void CloseLog()
{
	pthread_mutex_destroy(&log_mutex);
	return;
}

// private function
void Log(NSString *fmt, va_list args);

#ifdef LOG_ENABLE_DEBUG
void DbgLog(NSString *fmt,...) 
{
	va_list args;
	va_start(args, fmt);
	Log(fmt,args);
	va_end(args);
}
#else
void DbgLog(NSString *fmt,...) {}
#endif

#ifdef LOG_ENABLE_MESSAGE
void MsgLog(NSString *fmt,...) 
{
	va_list args;
	va_start(args, fmt);
	Log(fmt,args);
	va_end(args);
}
#else
void MsgLog(NSString *fmt,...) {}
#endif

#ifdef LOG_ENABLE_ERROR
void ErrLog(NSString *fmt,...) 
{
	va_list args;
	va_start(args, fmt);
	Log(fmt,args);
	va_end(args);
}
#else
void ErrLog(NSString *fmt,...) {}
#endif

#ifdef LOG_ENABLE_NETWORK
void NetLog(NSString *fmt,...) 
{
	va_list args;
	va_start(args, fmt);
	Log(fmt,args);
	va_end(args);
}
#else
void NetLog(NSString *fmt,...) {}
#endif

void Log(NSString *fmt, va_list args)
{
	char buff[MAX_LOG_STRING_LENGTH];

	pthread_mutex_lock(&log_mutex);

	// format string
	NSString *tmp = [[NSString alloc] initWithFormat:fmt arguments:args];
	
	// timestamped string
	struct timeval tm;
	gettimeofday(&tm,NULL);
	struct tm *tms = localtime(&tm.tv_sec);
	sprintf(buff, "%02d:%02d:%02d.%03d: %s\n", tms->tm_hour, tms->tm_min, tms->tm_sec, tm.tv_usec/1000, [tmp UTF8String]);
	[tmp release];

	fprintf(stderr, "%s", buff);

	pthread_mutex_unlock(&log_mutex);

	return;
}

