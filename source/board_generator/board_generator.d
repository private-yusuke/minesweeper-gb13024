module board_generator.board_generator;

import board;
import board_generator;
import cell;
import index2d;

/**
 * ボードの初期状態を生成することを目的とした抽象クラス
 */
abstract class BoardGenerator {
    protected uint _board_height;
    protected uint _board_width;

    /// 地雷が存在する座標の配列
    @property Index2D[] mineIndexes();

    Board generateBoard() {
        Board board = new Board(this._board_height, this._board_width);

        foreach (mineIndex; this.mineIndexes) {
            board.setMine(mineIndex);
        }

        return board;
    }
}