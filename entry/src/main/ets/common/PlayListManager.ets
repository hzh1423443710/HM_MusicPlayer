import { PlayListType } from '../model/MusicData';
import { MediaService } from './MediaService';

export class PlayListManager {
    private mediaService: MediaService = MediaService.getInstance();
    private viewModel:Map<PlayListType,>

    private constructor() {
    }

    public static getInstance(): PlayListManager {
        let playListManager: PlayListManager | undefined = AppStorage.Get('playListManager');
        if (!playListManager) {
            playListManager = new PlayListManager();
            AppStorage.SetOrCreate('playListManager', playListManager);
        }

        return playListManager;
    }
}