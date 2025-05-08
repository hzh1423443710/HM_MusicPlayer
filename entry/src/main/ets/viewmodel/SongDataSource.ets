/**
 * LazyForEach 数据源
 */
export class DataSource<T> implements IDataSource {
    items: T[] = [];
    /**
     * 数据变化监听器
     */
    private listener: DataChangeListener[] = [];

    constructor(items?: T[]) {
        if (items) {
            for (let i = 0; i < items.length; i++) {
                this.items.push(items[i]);
            }
        }
    }

    totalCount(): number {
        return this.items.length;
    }

    getAllData() {
        return this.items;
    }

    setData(newItems: T[]) {
        this.items = [...newItems];
        this.notifyDataReload();
    }

    getData(index: number): T {
        return this.items[index];
    }

    addData(index: number, item: T): void {
        this.items.splice(index, 0, item);
        this.notifyDataAdd(index);
    }

    pushData(item: T): void {
        this.items.push(item);
        this.notifyDataAdd(this.items.length - 1);
    }

    clearData(): void {
        this.items = [];
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