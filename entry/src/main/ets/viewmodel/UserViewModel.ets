import { HttpUtils, BACK_END_HOST } from '../common/network/HttpUtils';
import preferences from '@ohos.data.preferences';
import { PlaylistData } from '../model/PlaylistData';
import { MusicInfo } from '../model/MusicData';

@Observed
export class UserViewModel {
    id: number = -1;
    username: string;
    qq_id: string;
    netease_id: string;
    email: string;
    create_at: string;
    authorization: string = '';
    http: HttpUtils = new HttpUtils();
    qqPlaylists: PlaylistData[];
    neteasePlaylists: PlaylistData[];
    playlistSongs: Map<string, MusicInfo[]> = new Map();

    destroy() {
        this.http.destroy();
    }

    get isLogged() {
        return AppStorage.Get<boolean>('isLogged');
    }

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
        const pref = await preferences.getPreferences(context, 'HM-Music')
        if (await pref.has('id'))
            this.id = await pref.get('id', -1) as number;
        if (await pref.has('username'))
            this.username = await pref.get('username', '') as string;
        if (await pref.has('email'))
            this.email = await pref.get('email', '') as string;
        if (await pref.has('qq_id'))
            this.qq_id = await pref.get('qq_id', null) as string;
        if (await pref.has('netease_id'))
            this.netease_id = await pref.get('netease_id', null) as string;
        if (await pref.has('create_at'))
            this.create_at = await pref.get('create_at', '') as string;
        if (await pref.has('auth'))
            this.authorization = await pref.get('auth', '') as string;

        if (this.id !== -1)
            AppStorage.Set('isLogged', true);
    }

    public async login(username: string, password: string) {
        if (await this.http.login(username, password)) {
            await this.saveData();
            AppStorage.Set('isLogged', true);
            return true;
        }

        return false;
    }

    public async bindPlatform(platform: string, platformId: string) {
        const ret = await this.http.bindPlatform(platform, platformId);
        return ret;
    }

    // 退出登录
    public async logout() {
        AppStorage.Set('isLogged', false);
    }

    // 加载用户歌单
    public async loadPlaylist() {
        await this.loadData(getContext(this));

        // 加载歌单
        this.qqPlaylists = await this.http.getQQPlaylists(this.qq_id);
        this.neteasePlaylists = await this.http.getNetEasePlaylists(this.netease_id);

        // 加载歌单歌曲
        this.qqPlaylists.forEach(async item => {
            const type = 'qq-' + item.id;
            let songs: MusicInfo[] = [];
            let page: number = 1;

            while (true) {
                try {
                    const data = await this.http.getQQPlaylistSongs(item.id, page);
                    if (data.length === 0) break;
                    page++;
                    songs.push(...data);
                } catch (err) {
                    console.error('UserViewModel', JSON.stringify(err));
                }
            }

            this.playlistSongs.set(type, songs);
        });

        this.neteasePlaylists.forEach(async item => {
            const type = 'netease-' + item.id;
            const songs = await this.http.getNetEasePlaylistSongs(item.id);
            this.playlistSongs.set(type, songs);
        });
    }
}

export const globalUser = new UserViewModel();