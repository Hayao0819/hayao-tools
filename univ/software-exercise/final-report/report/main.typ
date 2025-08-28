#import "template.typ": project
#import "@preview/codelst:2.0.2": sourcecode

#show: project.with(title: "ソフトウェア演習1 レポート5" ,author:"伊藤 駿", affiliation: "群馬大学情報学部 3年")

#show quote: it => block(
  fill: luma(95%),
  inset: 8pt,
  stroke: (left: 2pt + blue),
  radius: 4pt,
  width: 100%,
  it.body
)

= ソースコード

ソースコードは以下に格納されている.

#link("https://github.com/Hayao0819/zash/tree/0564f6f3ec190de74605541aa3f7df1063305cad/go")[https://github.com/Hayao0819/zash/tree/0564f6f3ec190de74605541aa3f7df1063305cad/go]

= 本レポートについて

本レポートは #link("https://typst.app/")[Typst]を用いて作成されている。

以下のリンクでレポートのソースコード及びビルド結果について確認できる。

#link("https://typst.app/project/rw1VwQUoKwL98PjRSEkVZK")[https://typst.app/project/rw1VwQUoKwL98PjRSEkVZK]

= 用語説明

== シェル

シェルは、ユーザーとOS（オペレーティングシステム）の間を仲介するプログラムのことである。ユーザーがキーボードから入力したコマンドを解釈し、OSの機能やアプリケーションを起動・制御する役割を担っている。

シェルは大きく分けて2種類ある。ひとつはコマンドをテキストで入力するCUI（Character User Interface）シェルで、BashやZshなどがこれにあたる。もうひとつはマウス操作でアイコンをクリックするGUI（Graphical User Interface）シェルで、WindowsのエクスプローラーやmacOSのFinderがこれにあたる。プログラミングやシステム管理の分野では、主にCUIシェルを指すことが多い。

== システムコール

システムコールは、アプリケーションプログラムがOSのカーネル（OSの中核部分）が持つ機能を利用するための窓口だ。アプリケーションは、メモリ管理、ファイルアクセス、デバイス制御など、OSの特権的な機能に直接アクセスすることはできない。代わりに、特定の関数や命令を呼び出すことで、カーネルに処理を依頼する。

この「依頼」がシステムコールであり、アプリケーションはカーネルモードの特権的な操作を直接実行する代わりに、安全にその恩恵を受けられる。たとえば、ファイルを開く`open()`や、データを読み込む`read()`などが代表的なシステムコールとなる。

== Intel SGX

Intel SGXは、CPUがエンクレーブと呼ばれる特別なメモリ領域を作成することを可能にする。エンクレーブ内のコードとデータは、OSやハイパーバイザを含むシステム上の他のすべてのソフトウェアから隔離され、保護される。たとえ、管理者権限を持つソフトウェアがエンクレーブのメモリにアクセスしようとしても、CPUはこれを拒否する。これにより、機密性の高い処理（例：暗号鍵の生成、個人情報の処理）を安全な環境で行うことができる。

= 作成したもの

Go言語を用いてCLIのインタラクティブシェルを実装しようとした。しかし、実装時間や技術的な都合により最後まで実装できなかった。

本レポートでは実装しようとした機能と、実際に実装したもの・実装できなかったものについてまとめる。

== 当初実装したかったもの

当初、計画していた要件は以下の通りである。

- 常に標準入力を待つ
- 入力された文字列からASTを構築
- 組み込みコマンドを実行したり、起動するバイナリ、引数、出力先、環境変数を決定しシステムコールを発行する

また、シェルとしての機能を完全なものとするため、以下の構文や機能も実装する。

- ファイルをオープンし内容を読み取る
- 読み取った内容からASTを構築
- 組み込みコマンドを実行したり、起動するバイナリ、引数、出力先、環境変数を決定しシステムコールを発行する
- `if`制御文による条件分岐
- `while`制御文によるループ処理
- シェル変数のパースと展開

また、千田研究室で勉強中の知識を活かしたいと考え、Intel SGXを用いて以下の機能を実装する。

- 変数として機密情報を保持
- 状態は暗号化してSealing
- 起動時にUnsealingし、必要なプロセスにのみ情報を渡す

実装されたシェルを用いて本授業で使用されている投票システムに対しDoS攻撃を行う。昨年度に同様の授業を受講した先輩から攻撃しても良いという旨を聞いていたので、これを目標に開発を行った。

== 最終的に実装したもの

=== インタラクティブシェル

- 標準入力からの受取
- 入力文字列のパース(文字列、`"`による文字列区切り、空白による引数の分解)
- バイナリの実行
- リダイレクト

環境変数の操作については実装できなかった。

=== シェルスクリプトの実行

- ファイルを第一引数で渡して実行
- 基本的なコマンド呼び出し
- ファイルへのリダイレクト
- `while`によるループ
- コメントのパース

シェル変数や`if`文による制御は実装できなかった。また、パイプによるプロセス間通信も実装できなかった。

=== Intel SGXによる秘密保護

当初 Edgeless Systems社によるEGO(#link("https://www.edgeless.systems/products/ego")[https://www.edgeless.systems/products/ego])を用いて実装しようとしていたが、レポート締め切りまでにIntel SGXの動作環境の構築を行うことができなかった。

Intel SGXのEnclaveの起動に関して奮闘した記録は以下のスライドに掲載されている。

#link("https://www.docswell.com/s/hayao/ZEYWMG-sgx-driver")[https://www.docswell.com/s/hayao/ZEYWMG-sgx-driver]

= 動作している様子

#image("help.png")

#image("eval-hello.png")

#image("run-commands.png")

#image("while.png")

= ベンチマーク

今回作成したZashと最も利用されているBashでスクリプトの実行時間を比較する。

== 方法

ベンチマークには以下の`echo`を実行するシンプルなスクリプトを複数回実行し、実行時間を比較する。

#sourcecode[```bash
echo Hello1
echo Hello2
echo Hello3
echo Hello4
echo Hello5
echo Hello6
echo Hello7
echo Hello8
echo Hello9
echo Hello10
echo Hello11
echo Hello12
echo Hello13
echo Hello14
echo Hello15
echo Hello16
echo Hello17
echo Hello18
echo Hello19
echo Hello20
echo Hello21
echo Hello22
echo Hello23
echo Hello24
echo Hello25
echo Hello26
echo Hello27
echo Hello28
echo Hello29
echo Hello30
echo Hello31
echo Hello32
echo Hello33
echo Hello34
echo Hello35
echo Hello36
echo Hello37
echo Hello38
echo Hello39
echo Hello40
echo Hello41
echo Hello42
echo Hello43
echo Hello44
echo Hello45
echo Hello46
echo Hello47
echo Hello48
echo Hello49
echo Hello50
echo Hello51
echo Hello52
echo Hello53
echo Hello54
echo Hello55
echo Hello56
echo Hello57
echo Hello58
echo Hello59
echo Hello60
echo Hello61
echo Hello62
echo Hello63
echo Hello64
echo Hello65
echo Hello66
echo Hello67
echo Hello68
echo Hello69
echo Hello70
echo Hello71
echo Hello72
echo Hello73
echo Hello74
echo Hello75
echo Hello76
echo Hello77
echo Hello78
echo Hello79
echo Hello80
echo Hello81
echo Hello82
echo Hello83
echo Hello84
echo Hello85
echo Hello86
echo Hello87
echo Hello88
echo Hello89
echo Hello90
echo Hello91
echo Hello92
echo Hello93
echo Hello94
echo Hello95
echo Hello96
echo Hello97
echo Hello98
echo Hello99
echo Hello100
```]

このスクリプトをRust製のベンチマークツールHyperfineを用いて複数回実行し、ベンチマークを行う。

Hyperfineは以下で公開されている。

#link("https://github.com/sharkdp/hyperfine")[https://github.com/sharkdp/hyperfine]

これらの処理を自動化したスクリプトが以下である。

== 結果

#image("benchmark-running.png")

Bashのほうが圧倒的に高速であり、私の作成したものは数百倍も遅かった。

#image("execute-time.png")

赤軸が私の作成したシェルの実行時間であり、下の青線がBashの実行時間である。

= 考察

== 実装が間に合わなかった理由

かなり初期の頃から実装を進めていたが、パーサーとレクサーの実装にかなりの時間がかかった。

結局当初の実装は全て破棄し、BNFをベースにパーサーを作り直した。

また、ASTから実際にコマンドライン引数を組み立てるランタイム部分にかなり苦戦し、その実装は今も非常に汚くバグも多い状態になっている。

== 実行時間の差について

Go言語はC言語に比較した際に非効率であり、バイナリサイズにも非常に差があることが要因として挙げられる。

詳細に実行時間を分析すると、スクリプトの読み取りと解析と実際の実行の双方で時間がかかっており根本的な構造がボトルネックとなっている。

= 終わり


投票システムは非常に単純でCGIに対してPOSTリクエストを以下のように送れば投票数を増やせた。

#sourcecode[```bash
while true; do
    curl -X POST http://gadget.inf.gunma-u.ac.jp/cgi-bin/jikken1_2025/vote/vote.cgi -d mode=vote -d namber=9 -d no=1 2> /dev/null
done
```]

これは私の稚拙なシェルでも実行可能な単純なものである。

実行時間のボトルネックによりあまり多くのリクエストは送信できなかったが、それでも最終的に5555票を投じることができた。

#image("result.png")
