# このリポジトリについて
このリポジトリは、宇宙マイクロ波背景放射（CMB）の温度揺らぎから、円同士の相関を取るための解析コードになります。
<br>
このソースコードを使用することで、宇宙空間が3次元トーラス構造を持つかどうか、探ることができます。※宇宙がホライズンよりも非常にコンパクトであること（小さいこと）を想定。

# 詳細
プログラム言語：Fortran90
<br>
使用ツール：OpenMP、Healpix
<br>
利用環境、開発環境：CentOS、Linux、Cygwin(windows10)
<br>

# 参考サイト
https://www.cosmos.esa.int/web/planck
<br>
https://qiita.com/github-nakasho/items/6d2e06a3caca1f00f58a
<br>
https://mphitchman.com/geometry/section8-3.html
<br>

# コンパイル例
相関を取るための実行ファイルが作成されます。
<br>
gfortran -fopenmp -I/usr/local/lib/Healpix_3.20/include cmb_cits_3.f90 cmb_cits_2.f90 cmb_cits_1.f90 cmb_cits_main.f90 -o ./correlation.out -L/usr/local/lib/Healpix_3.20/lib -L/usr/local/cfitsio -lhealpix -lgif -lcfitsio
<br>
./correlation.outの実行ファイルを実行することで、計算が開始されます。
<br>
gfortran -fopenmp -I/usr/local/lib/Healpix_3.20/include cmb_output.f90 -o ./map.out -L/usr/local/lib/Healpix_3.20/lib -L/usr/local/cfitsio -lhealpix -lgif -lcfitsio
<br>
./map.outの実行ファイルを実行することで、データの解像度を変更することができます。
<br>
※環境が異なると、同じプロンプト内容で正しく開始できる保証はありません。

# cmb_cits_main.f90
プログラムを実行するメインプログラム。<br>
デフォルトでは以下の通りの値が入力されている。<br>
- オイラー回転させる回数：rotation=3000000回（※解析が終了するまでに時間を要するため、開発やテストでは試行回数を減らしてください）
- OpemMPで利用するスレッドの数：thread=30スレッド（※当時、100万円するコンピュータを利用しており、スレッドが最大40スレッドあったため、30と指定しています。通常は1,2など少ない数を入力して良い）
- 結果として取得するヒストグラムデータのパラメータ：hi_p=100
これを実行すると、cmb_cits_1.f90が実行されます。<br>

# cmb_cits_1.f90
向き合う同士の温度揺らぎの相関を取るためのモジュール関数<br>
これを実行すると、cmb_cits_2.f90、cmb_cits_3.f90が実行されます。<br>
より詳細な情報は、現在、準備中。<br>

# cmb_cits_2.f90
極座標(θ,φ)に対するランダムな値を取得するためのモジュール関数。<br>
実行することで、オイラー回転させるためのランダムな値(θm,φm)を得ることができます。<br>
※なぜこのようなランダム関数を作ったかについて。<br>
球面上でランダムな位置(θ,φ)を得る必要があり、通常のランダム関数を用いて、cmb_cits_3.f90を実行すると、密になる位置と疎になる位置が出てくる<br>
統計的に解析する場合、ランダムな位置(θ,φ)が一様でなければならないため、専用のランダム関数が必要だった。<br>

# cmb_cits_3.f90
極座標(θ,φ)の位置を、(θm,φm)分だけオイラー回転させるためのモジュール関数。<br>
極座標(θ,φ)の位置を入力することで、(θm,φm)分のオイラー回転させることができ、オイラー回転後の極座標(θ1,φ1)が得られる。<br>

# cmb_output.f90
CMBの揺らぎの解像度（ピクセルの大きさや数）を変更するためのプログラム。<br>
mapfitsの部分で、対象とするデータを変えることができます。<br>
より詳細な情報は、現在、準備中。<br>

# OpenACCについて
OpenACCを適応したソースコードも持っていますが、都合上、GitHubへ公開・保管していません。
