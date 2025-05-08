import mediaQuery from '@ohos.mediaquery';
import { BreakpointConstants } from './constants/BreakpointConstants';

declare interface BreakPointTypeOption<T> {
    sm?: T,
    md?: T,
    lg?: T,
}

export class BreakpointType<T> {
    options: BreakPointTypeOption<T>;

    constructor(option: BreakPointTypeOption<T>) {
        this.options = option;
    }

    getValue(currentPoint: string): T {
        return this.options[currentPoint] as T;
    }
}

/**
 * 媒体查询-断点系统
 */
export class BreakpointSystem {
    private currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
    // small
    private smListener: mediaQuery.MediaQueryListener;
    // medium
    private mdListener: mediaQuery.MediaQueryListener;
    // large
    private lgListener: mediaQuery.MediaQueryListener;

    /**
     * 更新当前断点
     * @param breakpoint
     */
    private updateCurrentBreakpoint(breakpoint: string): void {
        if (this.currentBreakpoint !== breakpoint) {
            this.currentBreakpoint = breakpoint;
            AppStorage.SetOrCreate<string>(BreakpointConstants.CURRENT_BREAKPOINT, this.currentBreakpoint);
        }
    }

    /**
     * 注册事件
     */
    public register(): void {
        this.smListener = mediaQuery.matchMediaSync(BreakpointConstants.RANGE_SM);
        this.smListener.on('change', (result: mediaQuery.MediaQueryResult) => {
            if (result.matches) {
                // console.log(`small`);
                this.updateCurrentBreakpoint(BreakpointConstants.BREAKPOINT_SM);
            }
        });

        this.mdListener = mediaQuery.matchMediaSync(BreakpointConstants.RANGE_MD);
        this.mdListener.on('change', (result: mediaQuery.MediaQueryResult) => {
            if (result.matches) {
                // console.log(`medium`);
                this.updateCurrentBreakpoint(BreakpointConstants.BREAKPOINT_MD);
            }
        });

        this.lgListener = mediaQuery.matchMediaSync(BreakpointConstants.RANGE_LG);
        this.lgListener.on('change', (mediaQueryResult: mediaQuery.MediaQueryResult) => {
            if (mediaQueryResult.matches) {
                // console.log(`large`);
                this.updateCurrentBreakpoint(BreakpointConstants.BREAKPOINT_LG);
            }
        });
    }

    public unregister(): void {
        this.smListener.off('change');
        this.mdListener.off('change');
        this.lgListener.off('change');
    }
}