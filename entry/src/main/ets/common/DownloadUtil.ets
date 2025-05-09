import picker from '@ohos.file.picker';
import request from '@ohos.request';
import fs from '@ohos.file.fs';
import promptAction from '@ohos.promptAction';

const TAG = 'DownloadUtil';

/**
 * 替换文件名中的特殊字符
 * @param name
 * @returns
 */
function getSafeFileName(name: string): string {
    return name.replace(/[\\/:*?"<>|]/g, '_');
}

/**
 * 保存成功后，返回保存文档的URI
 * @param name
 * @returns
 */
async function getPickerURI(name: string) {
    try {
        let URI = null;
        let audioSaveOptions = new picker.AudioSaveOptions();
        audioSaveOptions.newFileNames = [`${getSafeFileName(name)}.mp3`];

        let audioPicker = new picker.AudioViewPicker();
        await audioPicker.save(audioSaveOptions).then((AudioSaveResult) => {
            URI = AudioSaveResult[0];
        }).catch((err) => {
            console.error(TAG, 'AudioViewPicker.save failed with err: ' + err);
        });

        return URI;
    } catch (err) {
        console.error(TAG, 'AudioViewPicker failed with err: ' + err);
    }
}

/**
 * 下载音频文件
 * @param url
 * @param saveURI
 */
function downloadAudio(context: Context, url: string, saveURI: string) {
    try {
        // 临时文件
        let tmpPath = context.cacheDir + '/music.mp3';

        const downloadConfig: request.DownloadConfig = {
            url: url,
            filePath: tmpPath
        };
        promptAction.showToast({ message: '开始下载...' });

        request.downloadFile(context, downloadConfig, (err, downloadTask) => {
            if (err) {
                console.error(TAG, '下载任务创建失败:', JSON.stringify(err));
                return;
            }

            downloadTask.on("progress", (size, total) => {
                // const progress = Math.floor(size * 100 / total);
                // console.log(TAG, `下载进度: ${progress}%`);
            });

            downloadTask.on("complete", async () => {
                try {
                    let file_src = fs.openSync(tmpPath, fs.OpenMode.READ_ONLY);
                    const len = fs.statSync(tmpPath).size;
                    let buffer = new ArrayBuffer(len);
                    fs.readSync(file_src.fd, buffer, { offset: 0, length: len });
                    fs.closeSync(file_src);

                    fs.unlink(tmpPath).catch(e => {
                        console.error(TAG, `unlink ${e}}`)
                    });

                    let file_dst = fs.openSync(saveURI, fs.OpenMode.READ_WRITE);
                    fs.writeSync(file_dst.fd, buffer);
                    fs.closeSync(file_dst);

                    promptAction.showToast({ message: '下载成功' });
                } catch (e) {
                    console.log(TAG, `complete: ${e}`)
                }
            });

            downloadTask.on("fail", (err) => {
                console.error(TAG, '下载失败:', JSON.stringify(err));
                promptAction.showToast({ message: '下载失败，请重试' });
            });
        });
    } catch (err) {
        console.error(TAG, '下载异常:', JSON.stringify(err));
        promptAction.showToast({ message: '下载出错' });
    }
}

export { getPickerURI, downloadAudio }