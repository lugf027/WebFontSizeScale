import hilog from "@ohos.hilog";

const DOMAIN = 0;

export class MyLog {
  public static i(tag: string, msg: string) {
    hilog.info(DOMAIN, tag, msg);
  }

  public static w(tag: string, msg: string) {
    hilog.info(DOMAIN, tag, msg);
  }

  public static e(tag: string, msg: string) {
    hilog.info(DOMAIN, tag, msg);
  }
}