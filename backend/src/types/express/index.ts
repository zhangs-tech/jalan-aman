export type UserType = {
	readonly id: string;
	readonly email?: string;
	readonly role?: string;
	readonly name?: string;
};
declare global {
	namespace Express {
		interface Request {
			user?: UserType;
		}
	}
}