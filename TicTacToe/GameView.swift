//
//  ContentView.swift
//  TicTacToe
//
//  Created by Takuma Nezu on 2025/11/22.
//

import SwiftUI
import UIKit
import GoogleMobileAds

//対戦モード
enum GameMode {
    case twoPlayer
    case vsCPU(difficulty: CPUDifficulty)
}

//CPUの強さ
enum CPUDifficulty: String {
    case easy = "弱い"
    case normal = "普通"
    case hard = "強い"
}

struct GameView: View {
    let mode: GameMode
    @State private var cells = Array(repeating: "", count: 9)   //セル
    @State private var playerFlg = true         // プレイヤーフラグ（true:◯番, false:×番）
    @State private var draw = false             // 引き分けフラグ
    @State private var winner: String? = nil    // 勝者を保存
    @State private var pulse = false
    let columns = Array(repeating: GridItem(.flexible()), count: 3) //マス

    init(mode: GameMode = .twoPlayer) {
        self.mode = mode
    }

    //勝ちパターン
    let winPatterns = [
        [0,1,2], [3,4,5], [6,7,8],
        [0,3,6], [1,4,7], [2,5,8],
        [0,4,8], [2,4,6]
    ]

    //現在の手番表示ラベル
    var currentTurnLabel: String {
        switch mode {
        case .twoPlayer:
            return "Player:"
        case .vsCPU:
            return playerFlg ? "あなた:" : "CPU:"
        }
    }

    //画面タイトル
    var screenTitle: String {
        switch mode {
        case .twoPlayer:
            return "2人対戦"
        case .vsCPU(let difficulty):
            return "CPU対戦(\(difficulty.rawValue))"
        }
    }


    var body: some View {
        ZStack {
            // 全体の背景白
            Color.white.ignoresSafeArea()
            // -----------------------------
            // 広告+ゲーム画面（ZStack の最背面）
            // -----------------------------
            VStack {
                //広告表示
                //AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")    //テスト広告
                AdBannerView(adUnitID: "ca-app-pub-4013798308034554/2995384805")  //本番広告
                    .frame(width: 320, height: 50)

                //スペース
                Spacer()

                //現在のプレイヤー表示
                HStack {
                    Text(currentTurnLabel)
                    Text(playerFlg ? "◯" : "×")
                        .frame(width: 40)
                }
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding(.top, 100)

                //スペース
                Spacer()

                //盤面表示
                VStack(spacing: 0) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<3) { col in
                                let index = row * 3 + col

                                ZStack {
                                    Rectangle()
                                        .fill(Color(white: 0.97))

                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.black.opacity(0.7), lineWidth: 2)
                                        )

                                    Text(cells[index])
                                        .font(.system(size: 60, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)
                                        .bold()
                                }
                                .aspectRatio(1, contentMode: .fit)
                                .onTapGesture {
                                    guard winner == nil, !draw, cells[index].isEmpty else { return }

                                    //CPU戦でCPUの番はタップ無効
                                    if case .vsCPU = mode, !playerFlg { return }

                                    playHaptic()
                                    cells[index] = tapAction()

                                    //勝者判定実行
                                    if let win = checkWinner() {
                                        winner = win
                                        return
                                    }

                                    //引き分け判定実行
                                    checkDraw()

                                    //プレイヤー交代実行
                                    playerFlg.toggle()
                                }
                            }
                        }
                    }
                }
                .padding(20)

                //スペース
                Spacer()
                    .frame(height: 50)

                //リセットボタン表示
                Button(action: {
                    resetGame()
                }) {
                    Text("Reset Game")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill( (winner != nil || draw) ? Color.red : Color.gray )
                        )
                        .scaleEffect(pulse ? 1.02 : 0.98)   // ← ピクピク
                        .animation(
                            pulse ?
                            Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                            : Animation.default,
                            value: pulse
                        )

                }
                .padding(.bottom, 100)
                .onChange(of: winner) {
                    pulse = (winner != nil || draw)
                }
                .onChange(of: draw) {
                    pulse = draw || winner != nil
                }
            }
            .onChange(of: playerFlg) { _, newValue in
                //CPU戦で×番(CPU)になったら少し間を置いて着手
                if case .vsCPU = mode, newValue == false, winner == nil, !draw {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        cpuMove()
                    }
                }
            }
            .navigationTitle(screenTitle)
            .navigationBarTitleDisplayMode(.inline)

            // -----------------------------
            // 勝敗 or 引き分け表示（ZStack の最前面）
            // -----------------------------
            if winner != nil || draw {
                Color.black.opacity(0.6)
                    .frame(height: 100)
                    .allowsHitTesting(false)

                VStack {
                    if let w = winner {
                        HStack {
                            Text("Winner")
                                .font(.system(size: 70, weight: .bold))
                                .foregroundColor(.yellow)
                                .shadow(color: .orange, radius: 10, x: 0, y: 0)
                            Text(w)
                                .font(.system(size: 70, weight: .bold))
                                .foregroundColor(.yellow)
                                .shadow(color: .orange, radius: 10, x: 0, y: 0)
                        }
                    } else if draw {
                        Text("Draw")
                            .font(.system(size: 70, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .transition(.scale)
                .scaleEffect(winner != nil ? 1.1 : 1.0) // 勝者だけ少し弾む
                .animation(.interpolatingSpring(stiffness: 100, damping: 10), value: winner)
            }
        }
    }

    // ◯ × 切り替え
    func tapAction() -> String {
        return playerFlg ? "◯" : "×"
    }

    // 勝者判定（board省略時は現在の盤面を判定）
    func checkWinner(_ board: [String]? = nil) -> String? {
        let b = board ?? cells
        for p in winPatterns {
            if b[p[0]] != "" &&
                b[p[0]] == b[p[1]] &&
                b[p[1]] == b[p[2]] {
                return b[p[0]]
            }
        }
        return nil
    }

    // 空いているマスの一覧
    func availableMoves(_ board: [String]) -> [Int] {
        board.indices.filter { board[$0].isEmpty }
    }

    // markが置けば勝てるマスを探す
    func findWinningMove(for mark: String, in board: [String]) -> Int? {
        for m in availableMoves(board) {
            var testBoard = board
            testBoard[m] = mark
            if checkWinner(testBoard) == mark {
                return m
            }
        }
        return nil
    }

    // CPUの着手
    func cpuMove() {
        guard case .vsCPU(let difficulty) = mode else { return }
        guard winner == nil, !draw else { return }

        let cpuMark = "×"
        let humanMark = "◯"
        let moves = availableMoves(cells)
        guard !moves.isEmpty else { return }

        let move: Int
        switch difficulty {
        case .easy:
            // 完全ランダム
            move = moves.randomElement()!
        case .normal:
            // 勝てるならその手、ブロックできるならブロック、それ以外はランダム
            if let winMove = findWinningMove(for: cpuMark, in: cells) {
                move = winMove
            } else if let blockMove = findWinningMove(for: humanMark, in: cells) {
                move = blockMove
            } else {
                move = moves.randomElement()!
            }
        case .hard:
            // ミニマックス法で最善手（負けない）
            move = bestMove(cells, cpuMark: cpuMark, humanMark: humanMark)
        }

        cells[move] = cpuMark

        if let win = checkWinner() {
            winner = win
            return
        }

        checkDraw()
        playerFlg.toggle()
    }

    // ミニマックス法で最善手を求める
    func bestMove(_ board: [String], cpuMark: String, humanMark: String) -> Int {
        var bestScore = Int.min
        var move = availableMoves(board).first ?? 0
        for m in availableMoves(board) {
            var newBoard = board
            newBoard[m] = cpuMark
            let score = minimax(newBoard, isMaximizing: false, cpuMark: cpuMark, humanMark: humanMark)
            if score > bestScore {
                bestScore = score
                move = m
            }
        }
        return move
    }

    func minimax(_ board: [String], isMaximizing: Bool, cpuMark: String, humanMark: String) -> Int {
        if let w = checkWinner(board) {
            return w == cpuMark ? 10 : -10
        }
        if availableMoves(board).isEmpty {
            return 0
        }

        if isMaximizing {
            var best = Int.min
            for m in availableMoves(board) {
                var newBoard = board
                newBoard[m] = cpuMark
                best = max(best, minimax(newBoard, isMaximizing: false, cpuMark: cpuMark, humanMark: humanMark))
            }
            return best
        } else {
            var best = Int.max
            for m in availableMoves(board) {
                var newBoard = board
                newBoard[m] = humanMark
                best = min(best, minimax(newBoard, isMaximizing: true, cpuMark: cpuMark, humanMark: humanMark))
            }
            return best
        }
    }

    // 引き分け判定
    func checkDraw() {
        if cells.allSatisfy({ !$0.isEmpty }) {   // 全部埋まってる？
            draw = true
        }
    }

    // 全リセット
    func resetGame() {
        cells = Array(repeating: "", count: 9)
        playerFlg = true
        winner = nil
        draw = false
        pulse = false
    }

    //振動
    func playHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}


#Preview {
    GameView()
}
