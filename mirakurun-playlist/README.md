## Mirakurun Playlist Generator

MirakurunのAPIからVLC Media Playerで使えるプレイリストを生成します。

### 依存コマンド

- bash 5
- curl
- jq

### 使い方

```bash
# ダウンロード
curl -sL "https://raw.githubusercontent.com/Hayao0819/Hayao-Tools/master/mirakurun-playlist/mirakurun-playlist.sh" > mirakurun-playlist.sh

# 使い方を表示
bash ./mirakurun-playlist.sh -h

# プレイリストを作成
bash ./mirakurun-playlist.sh <IP アドレス>
```


### 参考

- [Raspberry Pi 4で64ビットMirakurun DVRチューナサーバを動かしてみました \| 日記というほどでも](https://denor.jp/raspberry-pi-4%E3%81%A764%E3%83%93%E3%83%83%E3%83%88mirakurun-dvr%E3%83%81%E3%83%A5%E3%83%BC%E3%83%8A%E3%82%B5%E3%83%BC%E3%83%90%E3%82%92%E5%8B%95%E3%81%8B%E3%81%97%E3%81%A6%E3%81%BF%E3%81%BE%E3%81%97#VLC)
- [Mirakurun/api\.yml at master · Chinachu/Mirakurun](https://github.com/Chinachu/Mirakurun/blob/master/api.yml)
- [mirakurun を使って VLC でテレビを視聴する。 \| 妄想日記 by 妄想エンジン](https://www.mousou.org/node/428)
