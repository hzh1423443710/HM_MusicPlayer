import { PlayControlConstants } from '../common/constants/PlayControlConstants';
import { PlayControlModel } from '../model/PlayControlModel';


const playControl: PlayControlModel[] = [
    new PlayControlModel(
        $r('app.media.ic_list_cycle'),
        PlayControlConstants.PLAY_MODE
    ),
    new PlayControlModel(
        $r('app.media.ic_public_play_last'),
        PlayControlConstants.PREVIOUS
    ),
    new PlayControlModel(
        $r('app.media.ic_play_big'),
        PlayControlConstants.PLAY
    ),
    new PlayControlModel(
        $r('app.media.ic_public_play_next'),
        PlayControlConstants.NEXT
    ),
    new PlayControlModel(
        $r('app.media.ic_music_list'),
        PlayControlConstants.PLAY_LIST
    )
]

export { playControl }