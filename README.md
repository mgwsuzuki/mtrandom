# mtrandom
RTL implementation of Mersenne Twister

メルセンヌツイスタのRTL実装。

## rtl/mt32

32bit版メルセンヌツイスタのRTL実装。
seedを与えて内部状態を初期化するロジックも入っている。
本家で公開されたCのコードでseedを与えて初期化した内部状態とRTLでの内部状態が一致していることを確認している。
また1000個の乱数を発生させてCとRTLが一致していることを確認している。
スループットは1random/clkである。
XilinxのVivadoで論理合成可能で、ターゲットをkintex7として250MHz以上で動作する。
