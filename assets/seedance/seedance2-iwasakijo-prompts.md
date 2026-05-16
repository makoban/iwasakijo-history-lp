# Seedance 2 岩崎城 映画CM用プロンプト

作成日: 2026-05-16  
目的: 岩崎城を「天守ではなく、土塁・空堀・土橋で守る土の城」として、短尺の歴史映像CMにする。

## 使う参照画像

Seedance 2では、下記画像を各シーンの参照画像として入れてください。画像内に文字は入れていないので、テロップは動画編集側で載せるのが安全です。

- `assets/seedance/scene-01-building-earthworks.png`: 土塁・空堀を築く場面
- `assets/seedance/scene-02-roadside-market.png`: 岩崎の街道沿い市場・城下の気配
- `assets/seedance/scene-03-battle-dawn.png`: 岩崎城の戦い、早朝の緊張
- `assets/seedance/scene-04-earth-castle-final.png`: 「土の城だった」を伝えるラスト全景

## 史実寄せの共通ルール

- 岩崎城の戦国期描写では、天守・白壁の城・高い石垣を出さない。
- 城は土塁、空堀、土橋、木柵、小さな櫓・物見台で構成する。
- 現在の岩崎城の城型展望塔は、戦国期の復元天守としては扱わない。
- 城下町は大都市にせず、街道沿いの小さな市場、農村、陶器、荷駄、旅人の規模感にする。
- 合戦は血しぶきや炎上で見せず、地形、足止め、朝霧、兵の圧力で迫力を出す。
- 「岩崎城の抵抗が長久手の戦いにつながったと伝わる」という表現にし、断定しすぎない。

## 共通ネガティブプロンプト

各シーンの最後に足してください。

```text
Negative prompt: tenshu castle tower, white plaster castle keep, stone castle walls, Osaka castle, Himeji castle, huge fantasy fortress, European medieval castle, modern buildings, modern roads, cars, electric poles, concrete, asphalt, guns, cannons, fireworks, explosions, gore, blood splatter, fantasy armor, anime style, cartoon style, readable text, subtitles, signs, logos, watermark, inaccurate oversized city, excessive fire, chaotic camera shake
```

## 全体マスタープロンプト

複数シーンを同じ質感でつなぐ時の基本プロンプトです。

```text
Cinematic historical film commercial, museum-grade reconstruction of Iwasaki Castle in late Sengoku Japan around 1584. Show Iwasaki Castle not as a tall tenshu tower, but as a compact earthwork hill castle controlling the road between Owari and Mikawa. Use earthen ramparts, dry moats, narrow earth bridges, wooden palisades, small watch platforms, rural fields, low hills, roadside market life, and the tension of the Komaki-Nagakute campaign. Dramatic but historically grounded, realistic Japanese period clothing and tools, natural light, rich atmosphere, no fantasy, no modern objects, no readable text.
```

## 30秒CM構成

### Cut 1: 0-5秒 現在の思い込みを崩す導入

参照画像: `scene-04-earth-castle-final.png`

```text
Use the reference image as the main visual. A slow cinematic push-in toward a small earthwork hill castle at sunset. The camera glides over the dry moat and narrow earth bridge, revealing wooden palisades and a simple watch platform. The atmosphere is solemn and powerful, like the opening shot of a historical film trailer. No castle tower, no stone walls, no modern structures, no text in the image.
```

編集テロップ案:

```text
岩崎城は、
天守ではなく
土の城だった。
```

### Cut 2: 5-11秒 土の城を築く

参照画像: `scene-01-building-earthworks.png`

```text
Use the reference image. Workers and ashigaru shape the earthen ramparts of Iwasaki Castle with baskets, wooden tools, and packed soil. The camera starts low inside the dry moat, then rises slowly to reveal the earth bridge, wooden palisades, and a small watch platform. Make the movement steady and cinematic, with dust, morning light, and realistic human labor. Emphasize that the castle is made from earth and terrain, not stone or a tall keep.
```

編集テロップ案:

```text
土塁、空堀、土橋。
地形そのものが守りだった。
```

### Cut 3: 11-17秒 尾張と三河を結ぶ道

参照画像: `scene-02-roadside-market.png`

```text
Use the reference image. A slow tracking shot through a modest roadside market near Iwasaki in late Sengoku Japan. Farmers, travelers, horses, pottery sellers, baskets, simple thatched houses, and a dirt road leading toward the earthwork castle on the hill. The scene is lively but small-scale and historically restrained. The castle remains visible in the distance as a strategic point on the road between Owari and Mikawa.
```

編集テロップ案:

```text
尾張と三河を結ぶ道。
この丘は、人と軍勢の通り道を見ていた。
```

### Cut 4: 17-25秒 岩崎城の戦い

参照画像: `scene-03-battle-dawn.png`

```text
Use the reference image. Dawn mist around Iwasaki Castle during the Komaki-Nagakute campaign in 1584. Ashigaru with spears and banners advance through the dry moat and toward the narrow gate, while defenders hold the wooden palisade above the earthen rampart. The camera moves with urgency but remains readable, showing the terrain, the bottleneck, and the pressure of a small castle delaying a passing army. No gore, no exaggerated flames, no fantasy action.
```

編集テロップ案:

```text
天正12年、羽柴方の中入軍。
岡崎へ急ぐ軍勢を、小さな城が止めた。
```

### Cut 5: 25-30秒 ラストコピー

参照画像: `scene-04-earth-castle-final.png`

```text
Use the reference image. Return to a wide cinematic view of the earthwork castle at sunset. The camera pulls back slowly, showing layered earthen ramparts, the dry moat, the earth bridge, and the road spreading into the fields below. Quiet, powerful, historically grounded ending shot. Leave clean space in the sky and left side for later text overlay. No text generated inside the video.
```

編集テロップ案:

```text
城は落ちた。
しかし、その足止めは長久手へつながったと伝わる。

岩崎城
日進の丘に残る、土の記憶。
```

## 60秒版に伸ばす場合

30秒版のCut 2とCut 4を厚くします。

### 追加Cut A: 土橋と空堀の防御

参照画像: `scene-01-building-earthworks.png`

```text
Close cinematic movement along the narrow earth bridge of a Sengoku earthwork castle. The camera passes between wooden palisades, then tilts down into a deep dry moat. Show why attackers are forced into a narrow path. Historically grounded, quiet tension, detailed soil texture, no stone walls, no castle keep, no modern objects.
```

テロップ案:

```text
敵を広く入れない。
狭い道へ誘い込む。
```

### 追加Cut B: 決戦へ向かう遅れ

参照画像: `scene-03-battle-dawn.png`

```text
After the clash at Iwasaki Castle, show a tense cinematic transition: marching soldiers delayed on a misty road, flags moving through the morning haze, the earthwork castle behind them. The camera looks back toward the castle, then forward toward Nagakute. The feeling is not victory celebration, but lost time and rising pressure.
```

テロップ案:

```text
失われた時間。
その先に、長久手の決戦が待っていた。
```

## ナレーション原稿案 30秒

```text
岩崎城は、天守ではなく、土の城だった。
土塁、空堀、土橋。
地形を使い、道を押さえた小さな城。

天正12年。
羽柴方の中入軍が、家康の本拠・岡崎を目指す。
その道の途中に、岩崎城があった。

城は落ちた。
しかし、この抵抗が軍勢を足止めし、
長久手の戦いへつながったと伝わる。

日進の丘に残る、土の記憶。
岩崎城。
```

## ナレーション原稿案 60秒

```text
いま岩崎城と聞くと、城型の建物を思い浮かべるかもしれない。
けれど戦国の岩崎城は、天守ではなく、土の城だった。

土塁を積み、空堀を掘り、土橋で道を絞る。
石の城ではない。
地形そのものを武器にした城だった。

この丘は、尾張と三河を結ぶ道を見下ろしていた。
人が通り、荷が動き、そして軍勢も通った。

天正12年、小牧・長久手の戦い。
羽柴方の中入軍は、徳川家康の本拠・岡崎を目指す。
その途中に、岩崎城があった。

小さな城の抵抗。
城は落ち、城兵は討たれたと伝わる。
しかし、その足止めが、長久手での決戦へつながった。

日進の丘に残る、土塁と空堀。
岩崎城は、いまも土の記憶を語っている。
```

## 編集で入れる文字の注意

Seedance 2側に日本語文字を生成させると崩れやすいので、映像生成時は「no readable text」を入れ、完成編集で文字を重ねてください。

推奨の文字表現:

- 太めの明朝体または筆文字風。読みやすさ優先。
- 白文字だけでなく、薄い黒シャドウを入れる。
- スマホ用は1行12文字前後まで。
- 「岩崎城は、天守ではなく土の城だった。」は、2から3行に分ける。

## 根拠メモ

- 現在の城型建物は戦国期の天守復元ではなく、昭和62年の城址公園整備に伴う展望塔。
- 岩崎城跡には土塁、空堀、土橋、井戸、礎石建物、掘立柱建物などの遺構が記録されている。
- 天正12年（1584）の岩崎城の戦いは、小牧・長久手の戦いの中で羽柴方の三河中入軍と関わる。
- 細かな発言や戦功評価は後世史料に依存する部分があるため、映像では「伝わる」として扱う。

参照した主な資料:

- 岩崎城公式ウェブサイト「岩崎城の歴史」
- 岩崎城公式ウェブサイト「岩崎城の戦い」
- 岩崎城公式ウェブサイト「丹羽氏について」
- 日進市「にっしんの文化財」
- 日進市「にっしんの戦国時代」
- 全国文化財総覧「岩崎城跡 発掘調査報告書」1987
- 全国文化財総覧「岩崎城跡」瀬戸市埋蔵文化財センター調査報告43、2011
- 長久手市観光交流協会「小牧・長久手の戦いから見る天下取り」
