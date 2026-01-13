#!/usr/bin/env python3
import sys
from pysat.formula import CNF
from pysat.solvers import Glucose3

class SudokuGrid:
    def __init__(self, grid: list[list[int]]):
        """9x9の数独グリッドを初期化"""
        if len(grid) != 9 or any(len(row) != 9 for row in grid):
            raise ValueError("Grid must be 9x9")
        self._grid = grid

    @staticmethod
    def from_file(filepath: str) -> "SudokuGrid":
        """ファイルから数独グリッドを読み込む"""
        grid: list[list[int]] = []
        with open(filepath, "r", encoding="utf-8") as f:
            for line_str in f:
                chars = list(line_str)
                row: list[int] = []
                for char in chars:
                    if char == "_":
                        row.append(0)
                    elif char.isdigit():
                        row.append(int(char))
                if row:
                    grid.append(row)
        return SudokuGrid(grid)

    @staticmethod
    def from_stdin() -> "SudokuGrid":
        """標準入力から数独グリッドを読み込む"""
        grid: list[list[int]] = []
        for line_str in sys.stdin:
            chars = list(line_str)
            row: list[int] = []
            for char in chars:
                if char == "_":
                    row.append(0)
                elif char.isdigit():
                    row.append(int(char))
            if row:
                grid.append(row)
        return SudokuGrid(grid)

    def get_cell(self, row: int, col: int) -> int:
        """指定された位置のセルの値を取得"""
        return self._grid[row][col]

    def get_size(self) -> int:
        """グリッドのサイズを取得"""
        return len(self._grid)

    def raw(self) -> list[list[int]]:
        """生のグリッドデータを取得"""
        return self._grid

    def print(self):
        """数独グリッドを表示"""
        print("+-------+-------+-------+")
        for i, row in enumerate(self._grid):
            row_str = "| "
            for j, val in enumerate(row):
                row_str += str(val) if val != 0 else "."
                if (j + 1) % 3 == 0:
                    row_str += " | "
                else:
                    row_str += " "
            print(row_str.rstrip())

            if (i + 1) % 3 == 0 and i < 8:
                print("+-------+-------+-------+")
            elif i == 8:
                print("+-------+-------+-------+")


class SatConverter:
    def __init__(self, sudoku_grid: SudokuGrid):
        """数独グリッドからCNF変換器を初期化"""
        self.sudoku_grid = sudoku_grid

    def to_cnf(self) -> str:
        """数独をDIMACS CNF形式に変換"""
        cnf = ""
        cnf += self._get_cell_at_least_one_value()
        cnf += self._get_cell_at_most_one_value()
        cnf += self._get_row_unique_values()
        cnf += self._get_col_unique_values()
        cnf += self._get_box_unique_values()
        cnf += self._get_initial_values()
        cnf = self._add_cnf_header(cnf, "c J2300023 伊藤 駿")
        return cnf

    def _get_cell_at_least_one_value(self) -> str:
        """各セルに少なくとも1つの値が入る制約を生成"""
        cnf = ""
        for i, row in enumerate(self.sudoku_grid.raw()):
            for j in range(len(row)):
                for val in range(1, 10):
                    cnf += f"{self._encode_variable(i, j, val)} "
                cnf += "0\n"
        return cnf

    def _get_cell_at_most_one_value(self) -> str:
        """各セルに最大1つの値しか入らない制約を生成"""
        cnf = ""
        for i, row in enumerate(self.sudoku_grid.raw()):
            for j in range(len(row)):
                for val1 in range(1, 10):
                    for val2 in range(val1 + 1, 10):
                        var1 = self._encode_variable(i, j, val1)
                        var2 = self._encode_variable(i, j, val2)
                        cnf += f"-{var1} -{var2} 0\n"
        return cnf

    def _get_row_unique_values(self) -> str:
        """各行で値が重複しない制約を生成"""
        cnf = ""
        for i, row in enumerate(self.sudoku_grid.raw()):
            for val in range(1, 10):
                for j1 in range(len(row)):
                    for j2 in range(j1 + 1, len(row)):
                        var1 = self._encode_variable(i, j1, val)
                        var2 = self._encode_variable(i, j2, val)
                        cnf += f"-{var1} -{var2} 0\n"
        return cnf

    def _get_col_unique_values(self) -> str:
        """各列で値が重複しない制約を生成"""
        cnf = ""
        grid = self.sudoku_grid.raw()
        for j in range(len(grid[0])):
            for val in range(1, 10):
                for i1 in range(len(grid)):
                    for i2 in range(i1 + 1, len(grid)):
                        var1 = self._encode_variable(i1, j, val)
                        var2 = self._encode_variable(i2, j, val)
                        cnf += f"-{var1} -{var2} 0\n"
        return cnf

    def _get_box_unique_values(self) -> str:
        """各3x3ブロックで値が重複しない制約を生成"""
        cnf = ""
        grid = self.sudoku_grid.raw()
        box_size = len(grid) // 3
        for box_row in range(box_size):
            for box_col in range(box_size):
                for val in range(1, 10):
                    cells = self._get_box_cells(box_row, box_col, box_size)
                    for k1, (i1, j1) in enumerate(cells):
                        for k2 in range(k1 + 1, len(cells)):
                            i2, j2 = cells[k2]
                            var1 = self._encode_variable(i1, j1, val)
                            var2 = self._encode_variable(i2, j2, val)
                            cnf += f"-{var1} -{var2} 0\n"
        return cnf

    def _get_box_cells(
        self, box_row: int, box_col: int, box_size: int
    ) -> list[tuple[int, int]]:
        """指定された3x3ブロック内のセル座標リストを取得"""
        cells = []
        start_row = box_row * box_size
        end_row = (box_row + 1) * box_size
        start_col = box_col * box_size
        end_col = (box_col + 1) * box_size
        for i in range(start_row, end_row):
            for j in range(start_col, end_col):
                cells.append((i, j))
        return cells

    def _get_initial_values(self) -> str:
        """初期値が与えられているセルの制約を生成"""
        cnf = ""
        for i, row in enumerate(self.sudoku_grid.raw()):
            for j, val in enumerate(row):
                if val != 0:
                    cnf += f"{self._encode_variable(i, j, val)} 0\n"
        return cnf

    @staticmethod
    def _encode_variable(row: int, col: int, value: int) -> int:
        """(行, 列, 値)をSAT変数番号にエンコード"""
        return (row * 9 * 9) + (col * 9) + value

    @staticmethod
    def _add_cnf_header(cnf: str, header: str = "") -> str:
        """DIMACS CNFヘッダーを追加"""
        num_vars = 9 * 9 * 9
        num_clauses = cnf.count("\n")
        header += f"\np cnf {num_vars} {num_clauses}\n"
        return header + cnf


class SudokuSolver:
    def __init__(self, sudoku_grid: SudokuGrid):
        """数独ソルバーを初期化"""
        self.sudoku_grid = sudoku_grid
        self.converter = SatConverter(sudoku_grid)

    def solve(self) -> SudokuGrid | None:
        """SATソルバーを使って数独を解く"""
        # SatConverterを使ってDIMACS CNF形式に変換
        cnf_string = self.converter.to_cnf()

        # CNFオブジェクトを作成
        cnf = CNF(from_string=cnf_string)

        # Glucose3ソルバーで解く
        with Glucose3(bootstrap_with=cnf) as solver:
            if solver.solve():
                # 解が見つかった場合、モデルを取得
                model = solver.get_model()
                grid = self._decode_model(model)
                return SudokuGrid(grid)
            else:
                # 解が見つからない場合
                return None

    @staticmethod
    def _decode_variable(var: int) -> tuple[int, int, int]:
        """変数番号を(row, col, value)に変換"""
        var = var - 1  # 1-indexed to 0-indexed
        value = (var % 9) + 1
        col = (var // 9) % 9
        row = var // 81
        return (row, col, value)

    def _decode_model(self, model: list[int]) -> list[list[int]]:
        """SATソルバーの解を数独グリッドに変換"""
        grid = [[0] * 9 for _ in range(9)]

        for var in model:
            # 正の変数のみ処理（真の割り当て）
            if var > 0:
                row, col, value = self._decode_variable(var)
                if 0 <= row < 9 and 0 <= col < 9 and 1 <= value <= 9:
                    grid[row][col] = value

        return grid

    def print_solution(self, solution: SudokuGrid | None):
        """解が見つかれば表示、見つからなければエラーメッセージを表示"""
        if solution is None:
            print("解が見つかりませんでした。")
            return

        solution.print()


def main():
    """メイン関数: CNF出力モードまたは解決モードを実行"""
    # コマンドライン引数でモードを選択
    if len(sys.argv) > 1 and sys.argv[1] == "--solve":
        # SudokuSolverを使って解く
        try:
            sudoku_grid = SudokuGrid.from_stdin()
            solver = SudokuSolver(sudoku_grid)
            solution = solver.solve()
            solver.print_solution(solution)
        except (IOError, ValueError) as e:
            sys.stderr.write(f"Error: {e}\n")
            sys.exit(1)
    else:
        # デフォルト: DIMACS CNF形式を出力
        try:
            sudoku_grid = SudokuGrid.from_stdin()
            converter = SatConverter(sudoku_grid)
            cnf = converter.to_cnf()
            sys.stdout.write(cnf)
        except (IOError, ValueError) as e:
            sys.stderr.write(f"Error: {e}\n")
            sys.exit(1)


if __name__ == "__main__":
    main()
