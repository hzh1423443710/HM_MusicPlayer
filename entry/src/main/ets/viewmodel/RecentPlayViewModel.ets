import { MusicInfo, PlaylistType } from '../model/MusicData';
import { DataSource } from './SongDataSource';
import { MediaService } from '../common/MediaService';

const TAG = 'RecentPlayViewModel';

@Observed
export class RecentPlayViewModel {
    songDataSource: DataSource<MusicInfo> = new DataSource<MusicInfo>();
    playlistType: string = PlaylistType.RECENT;
    title: string = '最近播放';
    brief: string = '0首';
    private media: MediaService = MediaService.getInstance();
    private isLoading: boolean = false;

    get musicList(): MusicInfo[] {
        return this.songDataSource.items;
    }

    get Length(): number {
        return this.songDataSource.items.length;
    }

    public refreshQueue() {
        try {
            if (this.isLoading) return;

            this.isLoading = true
            const playlist = this.media.getPlaylist(this.playlistType);
            this.brief = playlist.length + '首';

            this.songDataSource.clearData();
            this.songDataSource.setData(playlist);
        } catch (e) {
            console.error(TAG, `${this.refreshQueue.name} ${e}`)
        } finally {
            this.isLoading = false;
        }
    }
}

export const recentPlayViewModel = new RecentPlayViewModel();