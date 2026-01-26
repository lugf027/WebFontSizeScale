import { router } from '@kit.ArkUI';
import { ParamInfo } from './WebFontSizeScalePage';

interface WebUrlItem {
  title: string;
  url: string;
}

@Entry
@ComponentV2
struct Index {
  @Local webUrlList: WebUrlItem[] = [
    { title: '字节头条', url: 'https://m.toutiao.com/article/7598492576735396358/?upstream_biz=toutiao_pc' },
    { title: '腾讯新闻', url: 'https://view.inews.qq.com/a/20251229A065AF00?scene=ima' },
  ];

  build() {
    Column() {
      Row() {
        Text('测试缩放')
          .fontSize(22)
          .fontColor('#000000');
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(50)

      List() {
        ForEach(this.webUrlList, (item: WebUrlItem) => {
          ListItem() {
            Row() {
              Text(item.title)
                .fontSize(18)
                .fontColor('#000000');
            }
            .justifyContent(FlexAlign.Start)
            .height(50)
            .width('100%')
            .onClick(() => {
              router.pushUrl({
                url: 'pages/WebFontSizeScalePage',
                params: new ParamInfo(item.title, item.url),
              });
            });
          }
          .margin({ left: 16, right: 16 });
        });
      }
      .width('100%');
    }
    .height('100%')
    .width('100%')
  }
}