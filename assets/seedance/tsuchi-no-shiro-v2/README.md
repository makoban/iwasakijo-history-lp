# 土の城 Seedance2 用素材 v2

岩崎城を「天守の城」ではなく「土の城」として伝えるための、映像生成前素材です。
Seedance2 には `cut-*.png` の8枚をカット順に入れ、文字は `text-cards/` の完成フレームを後編集で重ねます。

## 映像用カット画像

1. `cut-01-opening-earth-castle.png`  
   丘陵上の土塁・空堀・木柵・物見のある岩崎城。冒頭の世界観。
2. `cut-02-building-earthworks.png`  
   土を積み、堀を掘り、柵を組む築城作業。
3. `cut-03-dry-moat-defense.png`  
   空堀と土橋で敵の進路を絞る防御構造。
4. `cut-04-roadside-market.png`  
   尾張と三河を結ぶ道沿いの人の動き。合戦前の生活感。
5. `cut-05-army-approaches.png`  
   夜明け前に軍勢が近づく緊張。
6. `cut-06-earth-bridge-bottleneck.png`  
   土橋と門で敵を詰まらせる山場。
7. `cut-07-palisade-clash.png`  
   木柵際の激しい衝突。迫力担当の主カット。
8. `cut-08-aftermath-road.png`  
   戦いの後、静かな土の城に戻る余韻。

## 後編集用の文字カード

- `text-cards/text-01-title.png`  
  「土の城」
- `text-cards/text-02-no-tenshu.png`  
  「岩崎城は、天守ではなかった。」
- `text-cards/text-03-earthworks.png`  
  「土を積み、堀を掘り、道を絞る。」
- `text-cards/text-04-delay.png`  
  「小さな城が、時間を奪った。」
- `text-cards/text-05-nagakute.png`  
  「その遅れは、長久手へつながった。そう伝わる。」

## 生成済み動画

- `videos/tsuchi-no-shiro-v2-seedance2.mp4`  
  8枚の参照画像をまとめて入れた Seedance2 生成クリップ。5.042秒、1280x720、H.264 / AAC。
- `videos/tsuchi-no-shiro-v2-last-frame.png`  
  Seedance2の「最後のフレームを返す」で取得した次カット接続用フレーム。
- `videos/tsuchi-no-shiro-v2-preview.png`  
  動画確認用のプレビューサムネイル。

## 迫力強化用の合戦カット

- `videos/battle/battle-01-earth-bridge-bottleneck.mp4`  
  土橋と門へ敵が押し込まれる低い目線の合戦カット。足元、泥、槍、木の圧力を強めた素材。
- `videos/battle/battle-01-earth-bridge-bottleneck-last-frame.png`  
  上記カットの最後のフレーム。
- `videos/battle/battle-01-earth-bridge-bottleneck-preview.png`  
  上記カットの確認用プレビュー。
- `videos/battle/battle-02-palisade-clash.mp4`  
  木柵際で槍が交差し、土塁上の守備側と下の攻撃側が衝突する山場カット。
- `videos/battle/battle-02-palisade-clash-last-frame.png`  
  上記カットの最後のフレーム。
- `videos/battle/battle-02-palisade-clash-preview.png`  
  上記カットの確認用プレビュー。

## 編集方針

- Seedance2 では文字を出さない。日本語字幕・ロゴ・看板は生成しない。
- 旗は無地にする。家紋、漢字、読める印は入れない。
- 天守・石垣中心の近世城郭にしない。土塁、空堀、土橋、木柵を主役にする。
- BGMは入れない。足音、土を掘る音、木柵、遠い鬨の声など効果音だけで組み、BGMは後から1本で作る。
- まずは各カット5秒前後で作り、最後のフレームを次カットの参照にしてつなぐ。
