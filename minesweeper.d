import std.stdio, std.conv, std.random, std.range, std.string;

const USAGE_MESSAGE =
r"  The player opens cells that don't contain mine.
  If you open the mine cell, you lose.
  
  [Cell]
  - x: not opened yet
  - F: flag
  - number: showing how many mines in the nearby 8 cells.
  
  [How to open]
  First you type 1, then type the coordinate of the cell.
  
  [How to set a flag]
  First you type 2, then do as opening a cell.
  
  [How to win]
  Open all the cells except mine ones.
";

bool isFinished = false;

enum Mode {
	MINE,
	EMPTY,
	MINE_FLAGGED,
	EMPTY_FLAGGED,
	OPENED
}
struct Cell {
	Mode mode = Mode.EMPTY;
	int number;
}

uint BOARD_HEIGHT = uint.max, BOARD_WIDTH = uint.max, MINE_AMOUNT = uint.max;

Cell[][] board;

void main(string[] args) {
	if(args.length > 1) {
		if(args.length >= 4)
		try {
			BOARD_HEIGHT = args[1].to!uint;
			BOARD_WIDTH = args[2].to!uint;
			MINE_AMOUNT = args[3].to!uint;
		} catch (ConvException e) {
			"Type the correct values.".writeln;
		}
	}
	while(BOARD_HEIGHT == 0 || BOARD_HEIGHT > 100) {
		"Height: > ".write;
		BOARD_HEIGHT = getInput;
	}
	while(BOARD_WIDTH == 0 || BOARD_WIDTH > 100) {
		"Width: > ".write;
		BOARD_WIDTH = getInput;
	}
	while(MINE_AMOUNT >= uint.max) {
		"mine: > ".write;
		MINE_AMOUNT = getInput;
	}
	
	assert(BOARD_HEIGHT * BOARD_WIDTH > MINE_AMOUNT, "The amount of mine is greater than the number of the cells");
	board = new Cell[][](BOARD_HEIGHT, BOARD_WIDTH); // same as defining a matrix
	auto rnd = Random(unpredictableSeed);
	
	for(int i = 0; i < MINE_AMOUNT;) {
		auto h = uniform(0, BOARD_HEIGHT, rnd), w = uniform(0, BOARD_WIDTH, rnd);
		with(Mode) if(board[h][w].mode != MINE){
			board[h][w].mode = MINE;
			i++;
		}
	}
	
	foreach(i;0..BOARD_HEIGHT) foreach(j;0..BOARD_WIDTH) {
		with(Mode) if(board[i][j].mode != MINE) {
			int count = 0;
			for(int m = -1; m <= 1; m++) {
				if(i+m < 0 || i+m >= BOARD_HEIGHT) continue;
				for(int n = -1; n <= 1; n++) {
					if(j+n < 0 || j+n >= BOARD_WIDTH) continue;
					if(board[i+m][j+n].mode == MINE) count++;
				}
			}
			board[i][j].number = count;
		}
	}
	
	loop();
}

void loop() {
	while(!isFinished) {
		printBoard();
		
		"show usage: 0, open the cell: 1, set a flag: 2".writeln;
		uint ip = uint.max;
		while(ip > 2) {
			" >> ".write;
			ip = getInput;
		}
		switch(ip) {
			case 0:
				USAGE_MESSAGE.write;
				break;
			case 1, 2:
				int h = -1, w = -1;
				"Which cell?".writeln;
				
				while(w < 0 || w >= BOARD_WIDTH) {
					"x: > ".write;
					w = getInput;
				}
				while(h < 0 || h >= BOARD_HEIGHT) {
					"y: > ".write;
					h = getInput;
				}
				ip == 1 ? openCell(h, w) : setFlag(h, w);
				break;
			default: break;
		}
		int c = 0;
		foreach(board_h;board) foreach(board_h_w; board_h)
				if(board_h_w.mode == Mode.OPENED) c++;
				
		if(c >= BOARD_HEIGHT*BOARD_WIDTH-MINE_AMOUNT) {
			"\n\nThe cells are opened safely. You win!".writeln;
			isFinished = true;
			printBoard;
		}
	}
}

void printBoard() {
	"\n [y]".writeln;
	foreach(i;0..BOARD_HEIGHT) {
		writef(" %2d│", i);
		foreach(j;0..BOARD_WIDTH) {
			auto cell = board[i][j];
			with(Mode) switch(cell.mode) {
				case EMPTY, MINE:
					write(" x");
					break;
				case EMPTY_FLAGGED, MINE_FLAGGED:
					write(" F");
					break;
				case OPENED:
					if(cell.number > 0) writef(" %d", cell.number);
					else "  ".write;
					break;
				default:
					break;
			}
		}
		writeln;
	}
	"   └─".write;
	'─'.repeat(BOARD_WIDTH*2).writeln;
	"    ".write;
	foreach(i;0..BOARD_WIDTH) writef!" %d"(i%10);
	" [x]".writeln;
	
}

uint getInput() {
	try {
		auto ip = readln.chomp.to!uint;
		return ip;
	} catch(ConvException e) {
		"Type the correct value.".writeln;
		return uint.max;
	}
	
}

auto d = [[-1, 0], [0, -1], [0, 1], [1, 0]];

void openCell(int h, int w) {
	auto cell = &board[h][w];
	with(Mode) switch(cell.mode) {
		case EMPTY_FLAGGED, MINE_FLAGGED:
			"Not opened because of the flag".writeln;
			break;
		case MINE:
			"Unfortunately you touched a mine. You lose!".writeln;
			isFinished = true;
			break;
		case EMPTY, OPENED:
			/*foreach(m;-1..2) {
				if(h+m < 0 || h+m >= BOARD_HEIGHT) continue;
				foreach(n;-1..2) {
					if(w+n < 0 || w+n >= BOARD_WIDTH) continue;
					if(board[h+m][w+n].mode == EMPTY)
						board[h+m][w+n].mode = OPENED;
				}
			}*/
			cell.mode = OPENED;
			foreach(d_i; d) {
				if(h+d_i[0] >= 0 && h + d_i[0] < BOARD_HEIGHT && w+d_i[1] >= 0 && w+d_i[1] < BOARD_WIDTH) {
					if(board[h+d_i[0]][w+d_i[1]].mode == EMPTY) {
						board[h+d_i[0]][w+d_i[1]].mode = OPENED;
						if(board[h+d_i[0]][w+d_i[1]].number == 0)
							openCell(h+d_i[0], w+d_i[1]);
					}
				}
			}
			break;
		default: break;
	}
}

void setFlag(int h, int w) {
	auto cell = &board[h][w];
	with(Mode) with(cell) switch(mode) {
		case EMPTY: mode = EMPTY_FLAGGED; break;
		case MINE: mode = MINE_FLAGGED; break;
		case EMPTY_FLAGGED: mode = EMPTY; break;
		case MINE_FLAGGED: mode = MINE; break;
		case OPENED:
			"Already opened".writeln;
			break;
		default: break;
	}
}