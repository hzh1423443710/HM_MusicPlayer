import { User } from '../model/User';

@Observed
export class UserViewModel {
    isLogged: boolean = false;
    user: User;

    // 持久化存储 Authorization 到用户首选项
    public saveAuth() {

    }
}

export const globalUser = new UserViewModel();