import { webview } from "@kit.ArkWeb";
import { MyLog } from "../utils/MyLog";

export class ParamInfo {
  name: string = '';
  url: string = '';

  constructor(name: string, url: string) {
    this.name = name;
    this.url = url;
  }
}

const TAG = 'WebFontSizeScalePage'

/**
 * web的生命周期：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/web-event-sequence
 */
@Entry
@ComponentV2
struct WebFontSizeScalePage {
  @Local paramInfo: ParamInfo = this.getUIContext().getRouter().getParams() as ParamInfo;
  private controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    MyLog.i(TAG, `aboutToAppear targetUrl:${JSON.stringify(this.paramInfo)}`)
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
        .runJavaScriptOnDocumentStart([
          {
            script: getCommonJSScaleCode('runJavaScriptOnDocumentStart'),
            scriptRules: ['*'],
          }
        ]) // 这个会按数组顺序注入js脚本
        .onControllerAttached(() => {
          try {
            MyLog.i(TAG, `onControllerAttached load url:${this.paramInfo.url}`)
            this.controller.runJavaScript(getCommonJSScaleCode('onControllerAttached'), (error, data) => {
              MyLog.i(TAG, `onControllerAttached runJavaScript end, error:${JSON.stringify(error)} data:${JSON.stringify(data)}`)
            })
          } catch (error) {
            MyLog.e(TAG, `onControllerAttached loadUrl error:${error}`)
          }
        })
        .onLoadIntercept((event) => {
          MyLog.i(TAG, `onLoadIntercept ${JSON.stringify(event)}`)
          if (event) {
            this.controller.runJavaScript(getCommonJSScaleCode('onLoadIntercept'), (error, data) => {
              MyLog.i(TAG,
                `onLoadIntercept runJavaScript end, error:${JSON.stringify(error)} data:${JSON.stringify(data)}`)
            })
          }
          return false;
        })
        .onPageBegin(async (event) => {
          MyLog.i(TAG, `onPageBegin ${JSON.stringify(event)}`)
          if (event) {
            this.controller.runJavaScript(getCommonJSScaleCode('onPageBegin'), (error, data) => {
              MyLog.i(TAG, `onPageBegin runJavaScript end, error:${JSON.stringify(error)} data:${JSON.stringify(data)}`)
            })
          }
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

    }
    .height('100%')
    .width('100%')
  }
}

function getCommonJSScaleCode(step: string): string {
  const fontScale = 1.5
  return `
    (function() {
        console.log('==============================');
        console.log('==============================');
        // 确认当前执行时机：DOM 元素已创建，但内容未加载
        console.log('=== Font Scale Script Execution Timing Check (step:${step}) ===');
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
            console.log('setCommonJSScaleCode start (step:${step}), scale:', scale);
            console.log('- Before - style:', document.documentElement.style);
            console.log('- Before - webkitTextSizeAdjust:', document.documentElement.style.webkitTextSizeAdjust);
            console.log('- Before - textSizeAdjust:', document.documentElement.style.textSizeAdjust);

            // 在 atDocumentStart 时机，document.documentElement 已经确保存在
            document.documentElement.style.webkitTextSizeAdjust = (scale * 100) + '%';
            document.documentElement.style.textSizeAdjust = (scale * 100) + '%';

            console.log('==============================');
            console.log('setCommonJSScaleCode finish (step:${step}), scale:', scale);
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
        console.log('=== End Font Scale Script (step:${step}) ===');
        console.log('==============================');
        console.log('==============================');
        console.log('==============================');
    })();
`.trim()
}

/**
 * 在iOS上能缩放字体的脚本
 * 注入时机：https://developer.apple.com/documentation/webkit/wkuserscriptinjectiontime/atdocumentstart
 * 时机注释：A constant to inject the script after the creation of the webpage’s document element, but before loading any other content.
 * @returns 缩放字体，JS注入的脚本
 */
function getCommonJSSimpleScaleCode(): string {
  const fontScale = 1.5
  return `
    (function() {
        // 设置网页字体缩放比例
        window.imaSetFontScale = function(scale) {
            document.documentElement.style.webkitTextSizeAdjust = (scale * 100) + '%';
            document.documentElement.style.textSizeAdjust = (scale * 100) + '%';
        };
        // 初始化时应用缩放
        window.imaSetFontScale(${fontScale});
    })();
`.trim()
}