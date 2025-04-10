import { MusicInfo } from '../model/MusicData'

export class SongDataSource implements IDataSource {
    musics: MusicInfo[] = [];
    /**
     * 数据变化监听器
     */
    private listener: DataChangeListener[] = [];

    constructor(items?: MusicInfo[]) {
        if (items) {
            for (let i = 0; i < items.length; i++) {
                this.musics.push(items[i]);
            }
        }
    }

    totalCount(): number {
        return this.musics.length;
    }

    getData(index: number): MusicInfo {
        return this.musics[index];
    }

    addData(index: number, item: MusicInfo): void {
        this.musics.splice(index, 0, item);
        this.notifyDataAdd(index);
    }

    pushData(item: MusicInfo): void {
        this.musics.push(item);
        this.notifyDataAdd(this.musics.length - 1);
    }

    clearData(): void {
        this.musics = [];
        this.notifyDataReload();
    }

    /**
     * 注册数据变化监听器
     * @param listener
     */
    registerDataChangeListener(listener: DataChangeListener): void {
        if (this.listener.indexOf(listener) < 0) {
            this.listener.push(listener);
        }
    }

    /**
     * 注销数据变化监听器
     * @param listener
     */
    unregisterDataChangeListener(listener: DataChangeListener): void {
        const pos = this.listener.indexOf(listener);
        if (pos > 0) {
            this.listener.splice(pos, 1);
        }
    }

    notifyDataReload(): void {
        this.listener.forEach((listener: DataChangeListener) => {
            listener.onDataReloaded();
        })
    }

    notifyDataAdd(index: number): void {
        this.listener.forEach((listener: DataChangeListener) => {
            listener.onDataAdd(index);
        })
    }

    notifyDataChanged(index: number): void {
        this.listener.forEach((listener: DataChangeListener) => {
            listener.onDataChange(index);
        })
    }

    notifyDataDeleted(index: number): void {
        this.listener.forEach((listener: DataChangeListener) => {
            listener.onDataDelete(index);
        })
    }

    notifyDataMove(from: number, to: number) {
        this.listener.forEach((listener: DataChangeListener) => {
            listener.onDataMove(from, to);
        })
    }
}