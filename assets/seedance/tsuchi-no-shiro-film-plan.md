# 短編映画「土の城」構成案

作成日: 2026-05-16  
目的: 岩崎城を「天守の城」ではなく「地形で守った土の城」として伝える、映画予告風の短編映像にする。

## まず結論

いま生成した20秒ラフは、映像素材としては使えるが、映画としては弱い。理由は、各カットが独立していて、次の3つが足りないため。

- 時間の流れ: 土を築く、道を見張る、軍勢が来る、城が止める、現在に残る、という流れが見えない。
- 視点: 誰の物語かが曖昧。今回は「岩崎城そのもの」を主人公にする。
- 音の設計: 各動画の音がばらばらなので、BGMは最初から入れず、効果音だけで空気をつなぐ。

## 作品コンセプト

タイトル:

```text
土の城
```

コピー:

```text
岩崎城は、天守ではなく、地形で戦った。
```

一般向けの伝え方:

```text
今の岩崎城を見ると、城型の建物を思い浮かべる。
でも戦国の岩崎城は、白い天守の城ではなかった。
土を盛り、堀を掘り、道を絞る。
尾張と三河を結ぶ道を押さえた、小さな土の城だった。
```

## 映像の骨格

映画としては、以下の5章にする。

1. 誤解
   - 現在の城型建物を連想させるが、すぐに否定する。
   - テロップ: 「岩崎城は、天守ではなかった。」

2. 土
   - 人が土を運び、堀を掘り、木柵を立てる。
   - テロップ: 「土塁、空堀、土橋。」

3. 道
   - 城下町ではなく、街道沿いの小さな市場と往来を見せる。
   - テロップ: 「尾張と三河を結ぶ道。」

4. 足止め
   - 軍勢が通る。狭い土橋、堀、木柵で圧を受ける。
   - テロップ: 「小さな城が、軍勢の時間を奪った。」

5. 記憶
   - 現在に戻る。土塁と空堀が残る。
   - テロップ: 「日進の丘に残る、土の記憶。」

## 推奨尺

最初は30秒版で作る。長すぎると説明動画になり、短すぎると「土の城」が伝わらない。

## 30秒版タイムライン

| 秒数 | 画 | 意味 | テロップ | 音 |
|---:|---|---|---|---|
| 0-3 | 暗い画面から土の城の稜線 | まず世界観に入れる | 土の城 | 低い風、遠い鳥 |
| 3-7 | 土塁を作る手元、籠、鍬、土 | 城は建物でなく土木だった | 土を積み、堀を掘る。 | 土を掘る音、足音 |
| 7-11 | 空堀を低い位置から見上げる | 地形の強さ | ここは、地形で守る城だった。 | 風、木柵のきしみ |
| 11-15 | 街道市場、荷駄、陶器、旅人 | なぜここに城が必要か | 尾張と三河を結ぶ道。 | 人の声、馬の足音 |
| 15-19 | 朝霧の軍勢、旗、槍 | 戦いの接近 | 天正12年、軍勢が通る。 | 遠い太鼓、鎧の擦れ |
| 19-24 | 土橋へ押し寄せる兵、上から見下ろす城兵 | 足止めの核心 | 小さな城が、時間を奪った。 | 槍、足音、息づかい |
| 24-28 | 軍勢が霧へ去る、城は静かになる | 落城よりも「遅れ」が残る | その遅れは、長久手へつながったと伝わる。 | 音を一度落とす |
| 28-30 | 夕景の土の城、黒へ | タイトル回収 | 岩崎城 | 風だけ |

## Seedance 2で作り直す方針

単発の絵を4枚動かすだけではつながらない。次は「前のカットの最後を次のカットの最初に使う」前提で作る。

やり方:

1. Cut 1を生成し、「最後のフレームを返す」をONにする。
2. Cut 2は、Cut 1の最後のフレームを参照画像として入れる。
3. 以後、Cut 3、Cut 4も同じようにつなぐ。
4. 各カットは5秒にするが、編集では2.5〜4秒に短く切る。
5. BGMは入れない。Seedanceの音声も使わず、後で効果音だけを敷く。

## カット設計

### Cut 1: タイトル導入

目的:
「これは城紹介ではなく、映画だ」と最初に見せる。

画:
夕暮れ、土の稜線、木柵、空堀。天守なし。

Seedanceプロンプト:

```text
Use the reference image as the first frame. Create a cinematic opening shot for a historical short film titled "Tsuchi no Shiro" about Iwasaki Castle in 1584. Begin with a quiet sunset over a compact earthwork hill castle, no tenshu tower, no stone walls. The camera slowly glides along the dry moat and earthen rampart, revealing wooden palisades and a narrow earth bridge. The mood is solemn, grounded, and cinematic, like the first shot of a period film. No readable text, no subtitles, no logos, no modern objects, no fantasy.
```

効果音:
低い風、遠い鳥、木柵の小さなきしみ。

### Cut 2: 土を積む

目的:
「城は建物ではなく、土木だった」と見せる。

画:
手元、足元、籠、鍬。人が土を運ぶ。派手さより重さ。

Seedanceプロンプト:

```text
Continue from the previous final frame. Move into a close, grounded reconstruction of workers and ashigaru building Iwasaki Castle as an earthwork fortification. Show hands carrying soil in baskets, wooden tools striking earth, packed ramparts being shaped, and the dry moat being deepened. The camera stays low and tactile, then rises slightly to reveal the palisade and earth bridge. No castle tower, no stone walls, no modern objects, no readable text. Historically plausible, serious, cinematic, no fantasy.
```

効果音:
土を掘る音、籠を置く音、荒い息、足音。

### Cut 3: 地形で守る

目的:
土塁・空堀・土橋が防御装置だと理解させる。

画:
空堀の底から見上げる。狭い土橋。上の木柵。

Seedanceプロンプト:

```text
Continue from the previous final frame. Show the defensive design of a Sengoku earthwork castle. The camera moves from the bottom of a deep dry moat upward toward a narrow earth bridge and wooden gate, making the terrain feel like a trap. Emphasize steep earthen ramparts, limited approach routes, wooden palisades, and the absence of a tower. Clear readable movement, museum-grade historical reconstruction, no stone walls, no modern objects, no readable text, no fantasy.
```

効果音:
風が堀を抜ける音、木柵の音、遠い足音。

### Cut 4: 道を押さえる

目的:
岩崎城がそこにある理由を見せる。

画:
街道、市場、陶器、荷駄。奥に土の城。

Seedanceプロンプト:

```text
Continue from the previous final frame. Transition to the road below Iwasaki Castle in late Sengoku Japan. A modest roadside market, pottery, baskets, farmers, travelers, horses, and simple thatched houses. The earthwork castle watches from the hill in the background. The scene should feel like a small strategic waypoint between Owari and Mikawa, not a large city. Warm natural light, restrained human activity, realistic period clothing, no readable text, no modern objects.
```

効果音:
馬の足音、人のざわめき、陶器が触れる音。

### Cut 5: 軍勢が来る

目的:
日常が戦に変わる瞬間。

画:
市場の音が消え、朝霧、槍、旗、足音。

Seedanceプロンプト:

```text
Continue from the previous final frame. The mood shifts from daily roadside life to dawn tension. Through morning mist, ashigaru and banners move along the road toward Iwasaki Castle during the Komaki-Nagakute campaign of 1584. The camera tracks low beside feet and spear shafts, then reveals the earthwork castle ahead. No gore, no firestorm, no fantasy armor, no modern objects, no readable text. Serious cinematic tension.
```

効果音:
市場のざわめきが消える、足音、槍の金属音、遠い太鼓。

### Cut 6: 土橋で止める

目的:
「小さな城が軍勢の時間を奪った」を映像で見せる。

画:
土橋へ押し寄せる兵。堀で道が狭い。上から守る城兵。

Seedanceプロンプト:

```text
Continue from the previous final frame. Show the decisive pressure point at Iwasaki Castle: attackers are forced toward a narrow earth bridge and wooden gate while defenders hold the palisade above the earthen rampart. The camera shows the bottleneck clearly, with soldiers compressed by the dry moat and steep earthworks. Focus on delay, pressure, and terrain, not gore. No blood splatter, no exaggerated fire, no tenshu tower, no stone walls, no modern objects, no readable text.
```

効果音:
足音が密になる、槍、短い掛け声、木柵に当たる音。

### Cut 7: 静けさ

目的:
戦いの後、勝敗より「残った意味」を見せる。

画:
霧、空堀、捨てられた籠や旗。城は静か。

Seedanceプロンプト:

```text
Continue from the previous final frame. After the clash, show a quiet aftermath without gore. Morning mist over the dry moat, wooden palisades, scattered footprints, a fallen spear, and the earthwork castle standing silently. The camera slowly pulls back toward the road leading away to Nagakute. The mood is solemn and historical, suggesting that lost time mattered. No gore, no bodies, no fire, no modern objects, no readable text.
```

効果音:
音を引く。風、遠くへ消える足音。

### Cut 8: 現在へ戻る

目的:
観光・地域の記憶へつなげる。

画:
現在の土塁・空堀風の静かな丘。白い天守ではなく、土を見る。

Seedanceプロンプト:

```text
Create a quiet closing shot that returns to the memory of Iwasaki Castle today. Do not show a modern castle tower as the main subject. Focus on the shape of the earth: rampart, dry moat, path, grass, trees, and the hill. The camera moves slowly as if a visitor is walking through the remains. The tone is reflective and cinematic. No readable text, no people looking at camera, no logos, no fantasy.
```

効果音:
現代の自然音。風、鳥、足音。

## テロップ設計

テロップは短く、映画の予告のように切る。説明文を長くしない。

```text
岩崎城は、
天守ではなかった。
```

```text
土を積み、
堀を掘り、
道を絞る。
```

```text
尾張と三河を結ぶ道。
```

```text
天正12年。
軍勢が通る。
```

```text
小さな城が、
時間を奪った。
```

```text
その遅れは、
長久手へつながったと伝わる。
```

```text
土の城
岩崎城
```

## ナレーション案

ナレーションを入れるなら、説明しすぎない。

```text
岩崎城は、天守ではなかった。

土を積み、堀を掘り、道を絞る。
それは、地形で戦う城だった。

尾張と三河を結ぶ道。
天正12年、軍勢はこの丘の前を通る。

小さな城は落ちた。
しかし、失われた時間があった。

その遅れは、長久手へつながったと伝わる。

日進の丘に残る、土の記憶。
岩崎城。
```

## 音の方針

BGMは今は入れない。

理由:

- シーンごとに生成された音楽はつながらない。
- 映像の編集テンポが決まる前にBGMを入れると、後で切りにくい。
- まず効果音だけで映画の流れを作る方が強い。

使う音:

- 風
- 土を掘る音
- 籠を置く音
- 木柵のきしみ
- 馬の足音
- 人のざわめき
- 遠い太鼓
- 槍や甲冑の擦れる音
- 戦い後の静けさ

BGMは最後にSunoなどで1曲だけ生成する。曲調は「和風」ではなく、映画音楽寄りにする。

Suno用の方向:

```text
Dark cinematic historical documentary score, slow build, deep taiko-like low percussion, shakuhachi-like breathy woodwind texture, restrained strings, no vocals, no pop beat, no cheerful melody, 80 bpm, solemn, tense, grounded, suitable for a Japanese Sengoku period historical film trailer about an earthwork castle.
```

## CapCutでの編集方針

CapCutは使ってよい。むしろ短尺の映画予告には向いている。

ただし、CapCutで解決するのは「編集の質」であり、「物語の弱さ」ではない。先に上のカット構成でSeedance素材を作り直し、その後にCapCutで組む。

CapCut構成:

- Video 1: Seedance生成映像
- Video 2: 黒フェード、暗幕、タイトル文字
- Text: 太い明朝体または筆文字風
- Audio 1: 効果音
- Audio 2: ナレーション
- Audio 3: 最後にSuno BGM

編集ルール:

- 1カットを長く使いすぎない。2.5〜4秒で切る。
- 合戦は派手さより「土橋で詰まる」ことを見せる。
- テロップは1画面1メッセージ。
- BGMなし版で一度完成させて、テンポ確認後にBGMを作る。

## 次にやること

1. この構成でSeedance 2を再生成する。
2. 生成時は「最後のフレームを返す」を使い、次カットへつなぐ。
3. 8カットをCapCutまたはローカル編集で仮組みする。
4. 効果音だけ入れた版を作る。
5. 最後にSunoで1本のBGMを作り、全体に敷く。
