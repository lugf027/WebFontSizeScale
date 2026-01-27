import { webview } from "@kit.ArkWeb";

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
  private controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    console.log(`aboutToAppear targetUrl:${JSON.stringify(this.paramInfo)}`)
  }

  build() {
    Column() {
      Row() {
        Text(this.paramInfo.name)
          .fontSize(22)
          .fontColor('#000000');
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(50)

      Web({
        src: this.paramInfo.url,
        controller: this.controller
      })
        .width('100%')
        .layoutWeight(1)
        .javaScriptAccess(true)
        .databaseAccess(true)
        .imageAccess(true)
        .onlineImageAccess(true)
        .mixedMode(MixedMode.All)
        .zoomAccess(true)
        .backgroundColor(Color.White)
        .fileAccess(true)
        .metaViewport(true)
        .darkMode(WebDarkMode.Auto)
        .domStorageAccess(true)
        .multiWindowAccess(false)
        .runJavaScriptOnDocumentStart([]) // 这个会按数组顺序注入js脚本
        .onPageBegin(async (event) => {
          if (event) {

          }
        });
    }
    .height('100%')
    .width('100%')
  }
}


function getCommonJSScaleCode(): string {
  const fontScale = 1.5
  return `
    (function() {
        // 确认当前执行时机：DOM 元素已创建，但内容未加载
        console.log('=== Font Scale Script Execution Timing Check ===');
        console.log('- document.documentElement exists:', !!document.documentElement);
        console.log('- document.readyState:', document.readyState);
        console.log('- document.body exists:', !!document.body);
        console.log('- document.head exists:', !!document.head);
        console.log('- DOM content loaded:', document.readyState !== 'loading');
         console.log('=== Font Scale Script Execution Timing Check End ===');

        // 在 atDocumentStart 时机，应该满足以下条件：
        // 1. document.documentElement 存在（DOM 根元素已创建）
        // 2. document.readyState 为 'loading'（内容还在加载中）
        // 3. document.body 可能还不存在（内容未完全加载）

        if (!document.documentElement) {
            console.warn('document WARNING: document.documentElement is null now');
        }

        if (document.readyState !== 'loading') {
            console.warn('TIMING WARNING: document.readyState is not "loading" now, actual:', document.readyState);
        }

        // 设置网页字体缩放比例
        window.imaSetFontScale = function(scale) {
            console.log('==============================');
            console.log('setCommonJSScaleCode start, scale:', scale);
            console.log('- Before - style:', document.documentElement.style);
            console.log('- Before - webkitTextSizeAdjust:', document.documentElement.style.webkitTextSizeAdjust);
            console.log('- Before - textSizeAdjust:', document.documentElement.style.textSizeAdjust);

            // 在 atDocumentStart 时机，document.documentElement 已经确保存在
            document.documentElement.style.webkitTextSizeAdjust = (scale * 100) + '%';
            document.documentElement.style.textSizeAdjust = (scale * 100) + '%';

            console.log('==============================');
            console.log('setCommonJSScaleCode finish, scale:', scale);
            console.log('- After - style:', document.documentElement.style);
            console.log('- After - webkitTextSizeAdjust:', document.documentElement.style.webkitTextSizeAdjust);
            console.log('- After - textSizeAdjust:', document.documentElement.style.textSizeAdjust);
            console.log('==============================');
        };

        // 初始化时应用缩放
        console.log('Applying initial font scale at atDocumentStart:', ${fontScale});
        window.imaSetFontScale(${fontScale});

        // 验证缩放是否成功应用
        const appliedWebkitScale = document.documentElement.style.webkitTextSizeAdjust;
        const appliedTextScale = document.documentElement.style.textSizeAdjust;
        console.log('==============================');
        console.log('Font scale applied successfully:');
        console.log('- webkitTextSizeAdjust:', appliedWebkitScale);
        console.log('- textSizeAdjust:', appliedTextScale);
        console.log('=== End Font Scale Script ===');
    })();
`.trim()
}