import wantAgent from '@ohos.app.ability.wantAgent';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import common from '@ohos.app.ability.common';

/**
 * 后台管理
 */
export class BackgroundUtil {
    /**
     * Start background task.
     *
     * @param context
     */
    public static startContinuousTask(context?: common.UIAbilityContext): void {
        if (!context) {
            console.error('this avPlayer: ', `context undefined`);
            return
        }
        let wantAgentInfo: wantAgent.WantAgentInfo = {
            wants: [
                {
                    bundleName: context.abilityInfo.bundleName,
                    abilityName: context.abilityInfo.name
                }
            ],
            operationType: wantAgent.OperationType.START_ABILITY,
            requestCode: 0,
            wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
        };

        wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: Object) => {
            try {
                backgroundTaskManager.startBackgroundRunning(context,
                    backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(() => {
                    console.info('this avPlayer: ', 'startBackgroundRunning succeeded');
                }).catch((error: Error) => {
                    console.error('this avPlayer: ', `startBackgroundRunning failed Cause: ${JSON.stringify(error)}`);
                });
            } catch (error) {
                console.error('this avPlayer: ', `startBackgroundRunning failed. Error cause : ${JSON.stringify(error)}`);
            }
        });
    }

    /**
     * Stop background task.
     *
     * @param context
     */
    public static stopContinuousTask(context: common.UIAbilityContext): void {
        try {
            backgroundTaskManager.stopBackgroundRunning(context).then(() => {
                console.info('this avPlayer: ', 'stopBackgroundRunning succeeded');
            }).catch((error: Error) => {
                console.error('this avPlayer: ', `stopBackgroundRunning failed Cause: ${JSON.stringify(error)}`);
            });
        } catch (error) {
            console.error('this avPlayer: ', `stopBackgroundRunning failed. Error cause : ${JSON.stringify(error)}`);
        }
    }
}