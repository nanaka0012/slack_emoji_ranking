# slack_emoji_ranking
slackでリアクションに使われてる絵文字のランキングを出すやつ  
各チャンネルの最新1000件の投稿の合計から集計する

## 使い方
dotenvが必要なので、入れてない人は`gem install dotenv`  
`.env`を作成して、取得したSlack API Tokenを記述する

```
SLACK_API_TOKEN=your Slack API Token
```