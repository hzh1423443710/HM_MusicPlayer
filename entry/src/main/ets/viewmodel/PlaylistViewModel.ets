import { HttpUtils } from '../common/network/HttpUtils';
import { MusicInfo } from '../model/MusicData';
import { DataSource } from './SongDataSource';
import { globalUser } from '../viewmodel/UserViewModel'

const TAG = 'PlaylistViewModel';

@Observed
export class PlaylistViewModel {
    private http: HttpUtils = new HttpUtils();
    songDataSource: DataSource<MusicInfo> = new DataSource<MusicInfo>();
    id: string;
    platform: string;
    name: string;
    brief: string;
    isLoading: boolean = false;
    playlistType: string;

    // 设置歌单信息
    public setPlaylistInfo(id: string, platform: string, name: string, count: number) {
        this.id = id;
        this.platform = platform;
        this.name = name;
        this.playlistType = this.platform + '-' + this.id;
        this.brief = `${count}首`;

        try {
            const data: MusicInfo[] = globalUser.playlistSongs.get(this.playlistType);
            this.songDataSource.setData(data);
        } catch (err) {
            console.error(TAG, JSON.stringify(err));
        }
    }

    public async refreshPlaylist() {
        if (this.isLoading) return;
        this.isLoading = true;

        let songs: MusicInfo[] = [];

        if (this.platform === 'qq') {
            let page: number = 1;
            while (true) {
                const data = await this.http.getQQPlaylistSongs(this.id, page++);
                if (data.length === 0) break;
                songs.push(...data);
            }
        } else if (this.platform === 'netease') {
            songs = await this.http.getNetEasePlaylistSongs(this.id);
        }

        this.songDataSource.clearData();
        this.songDataSource.setData(songs);
        globalUser.playlistSongs.set(this.playlistType, songs);
        this.brief = this.songDataSource.items.length + '首';
    }

    public destroy() {
        this.http.destroy();
    }
}

export const playlistViewModel = new PlaylistViewModel();