# KURANTORION ReStart 8bit Remix

クランとリオン「[ReStart](https://www.youtube.com/watch?v=Uc-12KzJt0g)」を8bitアレンジしたもの。
FCなので歌は入ってません。

## How to build

Windows上でしか確認していません。

[nsd.lib](https://github.com/Shaw02/nsdlib)が必要です。
最新版をダウンロードし、以下のファイルを同じフォルダにおいてください。

* `include/nes.inc`
* `include/nsd.inc`
* `include/nsddef.inc`
* `lib/NSD.lib`

また、`make`中に`nsc.exe`を実行するため、`[nsdlibのフォルダ]\bin`にパスを通しておく必要があります。

[GNU make](https://gnuwin32.sourceforge.net/packages/make.htm)も必要になります。
いい感じにインストールしてください。

`make`を実行すると`KuranToRionReStart.nes`が出来上がるので、NESエミュレータで実行できます。
