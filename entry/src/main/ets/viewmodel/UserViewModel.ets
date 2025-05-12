import { HttpUtils, BACK_END_HOST } from '../common/network/HttpUtils';

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

    avatar() {
        return `http://${BACK_END_HOST}/user/avatar/${this.id}`;
    }

    // 持久化存储 Authorization 到用户首选项
    private saveAuth() {

    }

    public async login(username: string, password: string) {
        const http = new HttpUtils();
        if (await http.login(username, password)) {
            this.isLogged = true;
            this.saveAuth();
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