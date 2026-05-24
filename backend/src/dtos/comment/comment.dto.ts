// Shared comment DTO

export type CommentDTO = {
  id: string;
  reportId: string;
  userId: string;
  userName: string;
  details: string;
  createdAt: Date;
  updatedAt: Date;
};
