import { PlayControlConstants } from '../common/constants/PlayControlConstants';

@Observed
export class PlayControlModel {
    icon: Resource;
    key: PlayControlConstants;

    constructor(icon: Resource, key: PlayControlConstants) {
        this.icon = icon;
        this.key = key;
    }
}