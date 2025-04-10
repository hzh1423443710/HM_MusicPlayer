import connection from '@ohos.net.connection';
import hilog from '@ohos.hilog';
import promptAction from '@ohos.promptAction';

const TAG: string = 'ConnectionUtil';

// 网络连接能力
class ConnectionUtil {
    netConn = connection.createNetConnection();

    async isNetworkConnected(): Promise<boolean> {
        let result: boolean = false;

        await connection.getDefaultNet().then(async (handle: connection.NetHandle) => {
            if (handle.netId === 0) {
                hilog.info(0x0000, TAG, 'No Default Net');
                return;
            }

            await connection.getNetCapabilities(handle).then((cap: connection.NetCapabilities) => {
                let types: Set<number> = new Set(cap.bearerTypes);
                let arr = Array.from(types.values());

                for (let item of arr) {
                    switch (item) {
                        case connection.NetBearType.BEARER_CELLULAR:
                            result = true;
                            hilog.info(0x0000, TAG, 'CELLULAR');
                            break;
                        case connection.NetBearType.BEARER_WIFI:
                            result = true;
                            hilog.info(0x0000, TAG, 'WIFI');
                            break;
                        case connection.NetBearType.BEARER_ETHERNET:
                            result = true;
                            hilog.info(0x0000, TAG, 'ETHERNET');
                            break;
                    }
                }
            })

        })

        return result;
    }

    // 开启网络状态监听能力
    openRegister() {
        this.netConn.register((err) => {
            hilog.info(0x0000, TAG, JSON.stringify(err));
        })
    }

    // 关闭网络监听能力
    closeRegister() {
        this.netConn.unregister((err) => {
            hilog.info(0x0000, TAG, JSON.stringify(err));
        })
    }

    // 订阅具体事件
    registerEvents() {
        this.netConn.on('netAvailable', () => {
            promptAction.showToast({
                message: $r('app.string.NetAvailable'),
            });
        });

        this.netConn.on('netLost', () => {
            promptAction.showToast({
                message: $r('app.string.NetLost'),
            });
        });

        this.netConn.on('netUnavailable', () => {
            promptAction.showToast({
                message: $r('app.string.NetUnAvailable'),
            });
        });
    }
}

export default new ConnectionUtil();