/*
 *  PolyglotBridge.h
 *  HandyChess
 *
 *  Created by Anton Zemyanov on 28.02.09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifdef __cplusplus
extern "C" 
{
#endif

void bridge_init();
int bridge_get_move_list(const char* fen, char *buff);

#ifdef __cplusplus
}
#endif
