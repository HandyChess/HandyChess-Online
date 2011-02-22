/*
 *  PolyglotBridge.cpp
 *  HandyChess
 *
 *  Created by Anton Zemyanov on 28.02.09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "PolyglotBridge.h"
#include "fen.h"
#include "move_gen.h"
#include "option.h"
#include "piece.h"
#include "hash.h"
#include "attack.h"
#include <string.h>

#ifdef __cplusplus
extern "C" 
{
#endif
	
void bridge_init()
{
	util_init();
	option_init();
	square_init();
	piece_init();
	attack_init();
	hash_init();
	my_random_init();
	return;
}
	
//r1bqkb1r/2pp1ppp/p1n2n2/1p2p3/B3P3/5N2/PPPP1PPP/RNBQ1RK w kq b6 0 6
	
int bridge_get_move_list(const char* fen, char *buff)
{
	//printf("POL: fen=%s\n", fen);
	
	// terminate output string
	buff[0] = '\0';
	
	// get board from FEN string
	board_t board;
	bool res = board_from_fen(&board, fen);
	if(!res)
		throw "Polyglot error";
	
	// get legal moves for the position
	list_t moveList;
	gen_legal_moves(&moveList, &board);
	
	// build return value
	if(moveList.size==0)
		return 0;
	
	char tmp[64];
	for(int cnt=0; cnt<moveList.size; ++cnt)
	{
		move_t move = moveList.move[cnt];
		move_to_can(move, &board, tmp, 64);
		strcat(buff, tmp);
		if(cnt!=moveList.size-1)
			strcat(buff,"|");
	}
	
	return moveList.size;
}
	
#ifdef __cplusplus
}
#endif