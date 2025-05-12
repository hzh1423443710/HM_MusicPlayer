import { HttpUtils, BACK_END_HOST } from '../common/network/HttpUtils';
import preferences from '@ohos.data.preferences';

@Observed
export class UserViewModel {
    isLogged: boolean = false;
    id: number;
    username: string;
    qq_id: string;
    netease_id: string;
    email: string;
    create_at: string;
    authorization: string = '';

    public avatar() {
        return `http://${BACK_END_HOST}/user/avatar/${this.id}`;
    }

    // 持久化存储用户数据
    private async saveData() {
        const pref = await preferences.getPreferences(getContext(this), 'HM-Music')
        await pref.put('id', this.id);
        await pref.put('username', this.username);
        await pref.put('email', this.email);
        if (this.qq_id)
            await pref.put('qq_id', this.qq_id);
        if (this.netease_id)
            await pref.put('netease_id', this.netease_id);
        await pref.put('create_at', this.create_at);
        await pref.put('auth', this.authorization);
        await pref.flush();
    }

    // 加载用户数据
    public async loadData(context: Context) {
        try {
            const pref = await preferences.getPreferences(context, 'HM-Music')
            this.id = await pref.get('id', 0) as number;
            this.username = await pref.get('username', '') as string;
            this.email = await pref.get('email', '') as string;
            this.qq_id = await pref.get('qq_id', null) as string;
            this.netease_id = await pref.get('netease_id', null) as string;
            this.create_at = await pref.get('create_at', '') as string;
            this.authorization = await pref.get('auth', '') as string;

            if (this.id !== 0)
                this.isLogged = true;
        } catch (err) {
            console.error(this.loadData.name, err.message);
        }
    }

    public async login(username: string, password: string) {
        const http = new HttpUtils();
        if (await http.login(username, password)) {
            await this.saveData();
            this.isLogged = true;
            console.error(this.loadData.name, this.id, this.username, this.email, this.qq_id, this.netease_id);
            http.destroy();
            return true;
        }

        http.destroy();
        return false;
    }

    public async bindPlatform(platform: string, platformId: string) {
        const http = new HttpUtils();
        const ret = await http.bindPlatform(platform, platformId);
        http.destroy();
        return ret;
    }

    // 退出登录
    public async logout() {
        this.isLogged = false;
    }
}

export const globalUser = new UserViewModel();