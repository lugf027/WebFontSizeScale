export class ParamInfo {
  name: string = '';
  url: string = '';

  constructor(name: string, url: string) {
    this.name = name;
    this.url = url;
  }
}

@Entry
@ComponentV2
struct WebFontSizeScalePage {
  @Local paramInfo: ParamInfo = this.getUIContext().getRouter().getParams() as ParamInfo;

  aboutToAppear(): void {
    console.log(`aboutToAppear targetUrl:${JSON.stringify(this.paramInfo)}`)
  }

  build() {
    RelativeContainer() {
      Text(this.paramInfo.name)
        .id('WebFontSizeScalePageHelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
        })
    }
    .height('100%')
    .width('100%')
  }
}