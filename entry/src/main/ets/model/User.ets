export class User {
    id: number;
    username: string;
    qq_id: string;
    netease_id: string;
    email: string;
    create_at: string;
    authorization: string;

    toString(): string {
        return `${this.id} ${this.username} ${this.email}`
    }
}